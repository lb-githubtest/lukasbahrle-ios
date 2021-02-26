//
//  LoadTokenFromRemoteTests.swift
//  ArtistBrowserTests
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import XCTest
import ArtistBrowser



class LoadTokenFromRemoteTests: XCTestCase {

    func test_init_doesNotResquestData(){
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requests.isEmpty)
    }
    
    func test_load_requestDataFromURL(){
        let url = URL(string: "https://test/path")!
        let (sut, client) = makeSUT(request: {URLRequest(url:  url)})
       
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
        
        let (sut, client) = makeSUT(request: {URLRequest.any()})
        
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
    
    private func makeSUT(request: @escaping () -> URLRequest = {URLRequest.any()}) -> (RemoteTokenLoader, HTTPClientSpy){
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




