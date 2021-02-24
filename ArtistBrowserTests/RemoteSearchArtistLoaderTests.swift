//
//  RemoteSearchArtistLoaderTests.swift
//  ArtistBrowserTests
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import XCTest
import ArtistBrowser

struct ArtistList{}

protocol SearchArtistLoader{
    typealias Result = Swift.Result<ArtistList, Error>
    
    func load(completion: @escaping (Result) -> Void)
}

class RemoteSearchArtistLoader: SearchArtistLoader {
    let request: Request
    let client: HTTPClient
    
    public init(request: Request, client: HTTPClient){
        self.request = request
        self.client = client
    }
    
    func load(completion: @escaping (SearchArtistLoader.Result) -> Void) {
        client.get(request: request.get()) { _ in }
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

    // MARK: Helpers

    private func makeSUT(request: Request = BasicRequest.any()) -> (RemoteSearchArtistLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteSearchArtistLoader(request: request, client: client)
        return (sut, client)
    }
}
