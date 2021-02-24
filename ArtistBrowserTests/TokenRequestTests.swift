//
//  TokenRequestTests.swift
//  ArtistBrowserTests
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import XCTest
@testable import ArtistBrowser

class TokenRequestTests: XCTestCase {

    func test_get_doesIncludeBase64EncodedAuthorizationHeader() throws{
        let credentials = Credentials(username: "test-username", password: "test-password")
        let sut = TokenRequest(builder: BasicRequestBuilder.any(), credentialsLoader: {credentials})
        
        let request = sut.get()
        let headers = try XCTUnwrap(request.allHTTPHeaderFields)
        XCTAssertEqual(headers["Authorization"], "Basic dGVzdC11c2VybmFtZTp0ZXN0LXBhc3N3b3Jk")
    }

}
