//
//  RemoteSearchArtistLoaderTests.swift
//  ArtistBrowserTests
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import XCTest
import ArtistBrowser

public struct Artist: Equatable{
    public let name:String
    
    public init(name:String){
        self.name = name
    }
}

struct ArtistList: Equatable{
    public let items:[Artist]
    public let offset: Int
    public let total: Int
    
    public init(items:[Artist], offset: Int, total: Int){
        self.items = items
        self.offset = offset
        self.total = total
    }
}

protocol SearchArtistLoader{
    typealias Result = Swift.Result<ArtistList, Error>
    
    func load(completion: @escaping (Result) -> Void)
}

class RemoteSearchArtistLoader: SearchArtistLoader {
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case unauthorized
    }
    
    let request: Request
    let client: HTTPClient
    
    public init(request: Request, client: HTTPClient){
        self.request = request
        self.client = client
    }
    
    func load(completion: @escaping (SearchArtistLoader.Result) -> Void) {
        client.get(request: request.get()) { result in
            
            switch result{
            case .failure(_):
                completion(.failure(Error.connectivity))
            case let .success((data, httpResponse)):
                completion(self.map(data, from: httpResponse))
            }
            
        }
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> SearchArtistLoader.Result {
        do {
            let list = try RemoteSearchArtistMapper.map(data, from: response)
            return .success(list)
        } catch {
            return .failure(error)
        }
    }
}

extension HTTPURLResponse {
    var isOK: Bool {
        statusCode == 200
    }
    
    var isUnauthorized: Bool {
        statusCode == 401
    }
}

class RemoteSearchArtistMapper{
    private struct Root: Codable{
        let artists: ArtistListRemoteResponse
        
        func toModel() -> ArtistList{
            artists.toModel()
        }
    }
    
    private struct ArtistListRemoteResponse: Codable{
        let items: [RemoteArtist]
        let limit: Int
        let offset: Int
        let total: Int
        
        func toModel() -> ArtistList{
            ArtistList(items: self.items.map{$0.toModel()}, offset: offset, total: total)
        }
    }
    
    private struct RemoteArtist: Codable{
        let name: String
        func toModel() -> Artist{
            Artist(name: name)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> ArtistList {
        
        if response.isUnauthorized {
            throw RemoteSearchArtistLoader.Error.unauthorized
        }
        
        guard response.isOK, let artistListResponse = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteSearchArtistLoader.Error.invalidData
        }
        return artistListResponse.toModel()
    }
}

class RemoteSearchArtistLoaderTests: XCTestCase {

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
    
    func test_load_deliversUnauthorizedErrorOn401HTTPResponse() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.unauthorized), when: {
            client.complete(withStatusCode: 401, data: Data.anyJSONData())
        })
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(withStatusCode: 200, data: Data.anyInvalidJsonData())
        })
    }

    // MARK: Helpers

    private func makeSUT(request: Request = BasicRequest.any()) -> (RemoteSearchArtistLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteSearchArtistLoader(request: request, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteSearchArtistLoader, toCompleteWith expectedResult: SearchArtistLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
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
    
    private func failure(_ error: RemoteSearchArtistLoader.Error) -> SearchArtistLoader.Result {
        return .failure(error)
    }
    
}
