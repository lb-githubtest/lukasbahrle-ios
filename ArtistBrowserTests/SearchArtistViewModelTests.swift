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
        let (sut, _, observer) = makeSUT()
        
        sut.searchArtist(input: "")
        
        XCTAssertEqual(observer.messages.count, 2)
        XCTAssertTrue(observer.messages.contains(ObservedMessage.loading(true)), "The observer has received the loading message")
        XCTAssertTrue(observer.messages.contains(ObservedMessage.error(nil)), "The observer has received an empty error message")
    }
    
    func test_searchArtist_dispatchesErrorAndNotLoading_onCompletionWithError() throws{
        let (sut, loader, observer) = makeSUT()
        
        sut.searchArtist(input: "")
        
        loader.complete(with: NSError.any())
        
        XCTAssertEqual(observer.messages.count, 4)
        let lastMessages = Array(observer.messages.suffix(2))
        
        XCTAssertTrue(lastMessages.contains(ObservedMessage.loading(false)), "The observer has received the stop loading message")
        let error = try XCTUnwrap(lastMessages.filter { item in return item.isError }.first)
        XCTAssertFalse(error.isEmptyError)
    }
    
    

    
    // MARK: Helpers
    
    private func makeSUT() -> (SearchArtistViewModel, SearchArtistLoaderSpy, SearchArtistViewModelObserverSpy){
        let loader = SearchArtistLoaderSpy()
        let observer = SearchArtistViewModelObserverSpy()
        let sut = SearchArtistViewModel(loader: loader)
        sut.observer = observer
        
        return (sut, loader, observer)
    }
    
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
        
        var isError: Bool {
            switch self {
            case .error(_):
                return true
            default:
                return false
            }
        }
        
        var isEmptyError: Bool {
            switch self {
            case .error(let message):
                return message == nil
            default:
                return true
            }
        }
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
