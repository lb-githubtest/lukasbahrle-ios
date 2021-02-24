//
//  LoadTokenFromRemoteTests.swift
//  ArtistBrowserTests
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import XCTest
import ArtistBrowser

class HTTPClientSpy: HTTPClient {
    private var messages = [(request: URLRequest, completion: (HTTPClient.Result) -> Void)]()
    
    var requests: [URLRequest] {
        return messages.map { $0.request }
    }
    
    func get(request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
        messages.append((request, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        guard let url = requests[index].url else {
            fatalError()
        }
        let response = HTTPURLResponse(
            url: url,
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success((data, response)))
    }
}


public typealias Token = String

public protocol TokenLoader{
    typealias Result = Swift.Result<Token, Error>
    
    func load(completion: @escaping (Result) -> Void)
}

class RemoteTokenLoader: TokenLoader{
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient){
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (TokenLoader.Result) -> Void) {
        client.get(request: request()) { result in
            switch result{
            case let .success((data, httpResponse)):
                completion(self.map(data, from: httpResponse))
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private func request() -> URLRequest{
        let request = URLRequest(url: url)
        return request
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> TokenLoader.Result {
        do {
            let tokenResponse = try RemoteTokenLoaderMapper.map(data, from: response)
            return .success(tokenResponse)
        } catch {
            return .failure(error)
        }
    }
}

class RemoteTokenLoaderMapper{
    struct TokenRemoteResponse: Codable{
        let access_token: String
        let token_type: String
        let expires_in: Int
        let scope: String
        
        func toModel() -> Token {
            return access_token
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> Token {
        guard response.isOK, let tokenResponse = try? JSONDecoder().decode(TokenRemoteResponse.self, from: data) else {
            throw RemoteTokenLoader.Error.invalidData
        }
        return tokenResponse.toModel()
    }
}

class LoadTokenFromRemoteTests: XCTestCase {

    func test_init_doesNotResquestData(){
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requests.isEmpty)
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            client.complete(with: NSError.any())
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: Data.anyJSONData(), at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(withStatusCode: 200, data: Data.anyInvalidJsonData())
        })
    }
    
    func test_load_deliversResultOn200HTTPResponseWithValidTokenJSON() throws{
        let (sut, client) = makeSUT()
        
        let token = "anytoken"
        let json: [String: Any] = [
            "access_token": token,
            "token_type": "Bearer",
            "expires_in": 3600,
            "scope": ""
        ]
        
        expect(sut, toCompleteWith: .success(token), when: {
            client.complete(withStatusCode: 200, data: json.jsonData)
        })
    }
    
    // MARK: Helpers
    
    private func makeSUT(url: URL = URL.any()) -> (RemoteTokenLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteTokenLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteTokenLoader, toCompleteWith expectedResult: TokenLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteTokenLoader.Error) -> TokenLoader.Result {
        return .failure(error)
    }

}


extension URL{
    static func any() -> URL{
        return URL(string: "any-url")!
    }
}


extension NSError{
    static func any() -> NSError{
        NSError(domain: "any", code: 0)
    }
}


extension Data{
    static func anyJSONData() -> Data{
        "{}".data(using: .utf8)!
    }
    
    static func anyInvalidJsonData() -> Data {
        Data("invalid json".utf8)
    }
}

extension Dictionary where Key: Any, Value:Any {
    var jsonData:Data {
        try! JSONSerialization.data(withJSONObject: self)
    }
}


public extension HTTPURLResponse{
    var isOK: Bool {
        self.statusCode == 200
    }
}
