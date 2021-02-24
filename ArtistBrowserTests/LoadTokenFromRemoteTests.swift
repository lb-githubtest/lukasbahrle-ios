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

class RemoteTokenLoader{
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient){
        self.url = url
        self.client = client
    }
}

class LoadTokenFromRemoteTests: XCTestCase {

    func test_init_doesNotResquestData(){
        let client = HTTPClientSpy()
        let sut = RemoteTokenLoader(url: URL.any(), client: client)
        XCTAssertTrue(client.requests.isEmpty)
    }

}


extension URL{
    static func any() -> URL{
        return URL(string: "any-url")!
    }
}
