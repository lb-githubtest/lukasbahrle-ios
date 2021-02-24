//
//  LoadTokenFromRemoteTests.swift
//  ArtistBrowserTests
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import XCTest
import ArtistBrowser


enum HTTPMethod: String{
    case GET = "GET"
    case POST = "POST"
}






protocol RequestBuilder{
    var baseURL: URL { get }
    var path: String { get }
    var params: [URLQueryItem]? { get }
    var headers: [String: String]? {get}
    var httpMethod: HTTPMethod {get}
    var body: Data {get}
    
    func build() -> URLRequest
}

extension RequestBuilder{
    var headers: [String: String]? {
        nil
    }
    
    var httpMethod: HTTPMethod{
        HTTPMethod.GET
    }
    
    var body: Data {
        Data()
    }
    
    var params: [URLQueryItem]? {
        nil
    }
    
    func build() -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            fatalError("URL path error")
        }
        components.queryItems = params
        
        guard let url = components.url else {
            fatalError("URL path error")
        }
        
        var request = URLRequest(url: url)
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        request.httpBody = body
        request.httpMethod = httpMethod.rawValue
        return request
    }
}


protocol Request {
    var builder: RequestBuilder { get }
    func get() -> URLRequest
}

extension Request {
    func get() -> URLRequest {
        builder.build()
    }
}


struct TokenRequest: Request {
    typealias CredentialsLoader = () -> Credentials
    
    let builder: RequestBuilder
    let credentialsLoader: CredentialsLoader
    
    init(builder: RequestBuilder, credentialsLoader: @escaping CredentialsLoader){
        self.builder = builder
        self.credentialsLoader = credentialsLoader
    }
    
    func get() -> URLRequest {
        let credentials = credentialsLoader()
        
        var request = builder.build()
        let authHeader = URLRequest.basicBase64EncodedAuthorizationHeader(username: credentials.username, password: credentials.password)
        request.addValue(authHeader.value, forHTTPHeaderField: authHeader.key)
       
        return request
    }
    
}



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

public struct Credentials{
    public let username: String
    public let password: String
    
    public init(username: String, password: String){
        self.username = username
        self.password = password
    }
}

class RemoteTokenLoader: TokenLoader{
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    let request: Request
    let client: HTTPClient
    
    init(request: Request, client: HTTPClient){
        self.request = request
        self.client = client
    }
    
    func load(completion: @escaping (TokenLoader.Result) -> Void) {
        client.get(request: request.get()) { result in
            switch result{
            case let .success((data, httpResponse)):
                completion(self.map(data, from: httpResponse))
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
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
    
    func test_load_requestDataFromURL(){
        let builder = BasicRequestBuilder(baseURL: URL(string: "https://test")!, path: "path")
        let (sut, client) = makeSUT(request: BasicRequest(builder: builder))
       
        sut.load{ _ in}
        
        XCTAssertEqual(client.requests.count, 1)
        XCTAssertEqual(client.requests[0].url, URL(string: "https://test/path"))
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
        
        let builder = BasicRequestBuilder(baseURL: URL(string: "https://test")!, path: "path")
        let (sut, client) = makeSUT(request: BasicRequest(builder: builder))
        
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
    
    private func makeSUT(request: Request = BasicRequest.any()) -> (RemoteTokenLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteTokenLoader(request: request, client: client)
        
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


extension Credentials{
    static func any() -> Credentials{
        Credentials(username: "username", password: "password")
    }
}



extension URLRequest {
    static func basicBase64EncodedAuthorizationHeader(username: String, password: String) -> (key: String, value: String){
        let encodedCredentials = Data("\(username):\(password)".utf8).base64EncodedString()
        return ("Authorization", "Basic \(encodedCredentials)")
    }
}





struct BasicRequestBuilder: RequestBuilder{
    var baseURL: URL
    var path: String
    
    static func any() -> BasicRequestBuilder{
        return BasicRequestBuilder(baseURL: URL.any(), path: "")
    }
    
}

struct BasicRequest: Request{
    var builder: RequestBuilder
    
    static func any() -> Request{
        BasicRequest(builder: BasicRequestBuilder.any())
    }
}


