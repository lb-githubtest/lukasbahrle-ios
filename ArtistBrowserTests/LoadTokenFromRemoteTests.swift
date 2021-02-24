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
}


public typealias Token = String

public protocol TokenLoader{
    typealias Result = Swift.Result<Token, Error>
    
    func load(completion: @escaping (Result) -> Void)
}

class RemoteTokenLoader: TokenLoader{
    public enum Error: Swift.Error {
        case connectivity
    }
    
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient){
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (TokenLoader.Result) -> Void) {
        client.get(request: request()) { result in
            completion(.failure(Error.connectivity))
        }
    }
    
    private func request() -> URLRequest{
        var request = URLRequest(url: url)
        return request
    }
}

class LoadTokenFromRemoteTests: XCTestCase {

    func test_init_doesNotResquestData(){
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requests.isEmpty)
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteTokenLoader.Error.connectivity), when: {
            client.complete(with: NSError.any())
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
