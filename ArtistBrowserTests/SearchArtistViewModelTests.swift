//
//  SearchArtistViewModelTests.swift
//  ArtistBrowserTests
//
//  Created by Lukas Bahrle Santana on 25/02/2021.
//

import XCTest
import ArtistBrowser

class SearchArtistViewModelTests: XCTestCase {
    
    private typealias ObservedMessage = SearchArtistViewModelObserverSpy.Message

    func test_searchArtist_dispatchesInLoadingStateAndNoErrorState(){
        let loader = SearchArtistLoaderSpy()
        let obszerver = SearchArtistViewModelObserverSpy()
        let sut = SearchArtistViewModel(loader: loader)
        sut.observer = obszerver
        
        sut.searchArtist(input: "")
        
        XCTAssertEqual(obszerver.messages.count, 2)
        XCTAssertTrue(obszerver.messages.contains(ObservedMessage.loading(true)), "The observer has received the loading message")
        XCTAssertTrue(obszerver.messages.contains(ObservedMessage.error(nil)), "The observer has received an empty error message")
    }

    
    // MARK: Helpers
    
    
}


class SearchArtistLoaderSpy: SearchArtistLoader{
    private var requests = [(SearchArtistLoader.Result) -> Void]()
    
    func load(completion: @escaping (SearchArtistLoader.Result) -> Void) {
        requests.append(completion)
    }
    
    func complete(with error: Error, at index: Int = 0) {
        requests[index](.failure(error))
    }
    
    func complete(with artists: ArtistList, at index: Int = 0) {
        requests[index](.success(artists))
    }
}

class SearchArtistViewModelObserverSpy: SearchArtistViewModelObserver{
    enum Message: Equatable{
        case loading(Bool)
        case error(String?)
        case data(ArtistList)
    }
    
    var messages: [Message] = []
    
    func onLoadingStateChange(isLoading: Bool) {
        messages.append(.loading(isLoading))
    }
    
    func onArtistsLoaded(artists: ArtistList) {
        messages.append(.data(artists))
    }
    
    func onErrorStateChange(message: String?) {
        messages.append(.error(message))
    }
}
