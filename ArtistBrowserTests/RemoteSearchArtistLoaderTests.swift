//
//  RemoteSearchArtistLoaderTests.swift
//  ArtistBrowserTests
//
//  Created by Lukas Bahrle Santana on 24/02/2021.
//

import XCTest
import ArtistBrowser

class RemoteSearchArtistLoaderTests: XCTestCase {

    func test_init_doesNotResquestData(){
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requests.isEmpty)
    }
    
    func test_load_requestDataFromURL(){
        let input = "input text"
        let url = URL(string: "https://test/path")!
        let (sut, client) = makeSUT(request: {_,_ in URLRequest(url: url)})
       
        sut.load(text: input) { _ in }
        
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
    
    func test_load_deliversArtistListOn200HTTPResponseWithValidArtistListData() {
        let (sut, client) = makeSUT()
        
        let artistData_1: (id: String, name: String, thumbnail:String, genres: [String]) = ("1", "artist 1", "https://image_1.png", ["1", "2"])
        let artistData_2: (id: String, name: String, thumbnail:String, genres: [String]) = ("2", "artist 2", "https://image_2.png", ["3", "4"])
        let artistData_3: (id: String, name: String, thumbnail:String, genres: [String]) = ("3", "artist 3", "https://image_3.png", ["5", "6"])
        
        
        let artistList = ArtistList(items: [
            Artist(id: artistData_1.id, name: artistData_1.name, thumbnail: URL(string: artistData_1.thumbnail), genres: artistData_1.genres),
            Artist(id: artistData_2.id, name: artistData_2.name, thumbnail: URL(string: artistData_2.thumbnail), genres: artistData_2.genres),
            Artist(id: artistData_3.id, name: artistData_3.name, thumbnail: URL(string: artistData_3.thumbnail), genres: artistData_3.genres)
        ], canLoadMore: true)
        
        let json: [String: Any] = [
            "href": "https://api.spotify.com/v1/search?query=Ja&type=artist&offset=0&limit=20",
            "items": [
                makeArtistJson(id: artistData_1.id, name: artistData_1.name, thumbnail: artistData_1.thumbnail, genres: artistData_1.genres),
                makeArtistJson(id: artistData_2.id,name: artistData_2.name, thumbnail: artistData_2.thumbnail, genres: artistData_2.genres),
                makeArtistJson(id: artistData_3.id,name: artistData_3.name, thumbnail: artistData_3.thumbnail, genres: artistData_3.genres)
            ],
            "limit": 10,
            "next": "https://api.spotify.com/v1/search?query=Ja&type=artist&offset=20&limit=20",
            "offset": 20,
            "total": 100
        ]
        
        expect(sut, toCompleteWith: .success(artistList), when: {
            client.complete(withStatusCode: 200, data: ["artists":json].jsonData)
        })
    }

    // MARK: Helpers

    private func makeSUT(request: @escaping (String, Int) -> URLRequest = {_,_  in URLRequest.any()}) -> (RemoteSearchArtistLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteSearchArtistLoader(request: request, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteSearchArtistLoader, toCompleteWith expectedResult: SearchArtistLoader.Result, when action: () -> Void, input: String = "", file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load(text: input){ receivedResult in
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
    
    private func makeArtistJson(id: String, name: String = "Jack Harlow", thumbnail: String = "https://image.png", genres: [String] = []) -> [String: Any]{
        
        return [
            "external_urls": [
                "spotify": "https://open.spotify.com/artist/2LIk90788K0zvyj2JJVwkJ"
            ],
            "followers": [
                "total": 715334
            ],
            "genres": genres,
            "href": "https://api.spotify.com/v1/artists/2LIk90788K0zvyj2JJVwkJ",
            "id": "\(id)",
            "images": [
                [
                    "height": 640,
                    "url": "\(thumbnail)",
                    "width": 640
                ],
                [
                    "height": 320,
                    "url": "https://i.scdn.co/image/760c87212373379f77290356031d063ebfb792d2",
                    "width": 320
                ],
                [
                    "height": 160,
                    "url": "https://i.scdn.co/image/360bd37c8439b95b4258b233aa12ede454d75b48",
                    "width": 160
                ]
            ],
            "name": "\(name)",
            "popularity": 86,
            "type": "artist",
            "uri": "spotify:artist:2LIk90788K0zvyj2JJVwkJ"
        ]
        
    }
    
}
