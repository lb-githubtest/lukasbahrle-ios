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
}


public typealias Token = String

public protocol TokenLoader{
    typealias Result = Swift.Result<Token, Error>
    
    func load(completion: @escaping (Result) -> Void)
}

class RemoteTokenLoader: TokenLoader{
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient){
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (TokenLoader.Result) -> Void) {
        
    }
}

class LoadTokenFromRemoteTests: XCTestCase {

    func test_init_doesNotResquestData(){
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requests.isEmpty)
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        

    }
    
    // MARK: Helpers
    
    private func makeSUT(url: URL = URL.any()) -> (RemoteTokenLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteTokenLoader(url: url, client: client)
        
        return (sut, client)
    }

}


extension URL{
    static func any() -> URL{
        return URL(string: "any-url")!
    }
}
