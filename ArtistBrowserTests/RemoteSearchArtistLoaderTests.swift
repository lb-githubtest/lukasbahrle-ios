//
//  RemoteSearchArtistLoaderTests.swift
//  ArtistBrowserTests
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import XCTest
import ArtistBrowser

struct ArtistList: Equatable{}

protocol SearchArtistLoader{
    typealias Result = Swift.Result<ArtistList, Error>
    
    func load(completion: @escaping (Result) -> Void)
}

class RemoteSearchArtistLoader: SearchArtistLoader {
    public enum Error: Swift.Error {
        case connectivity
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
            default:
                break
            }
            
        }
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
