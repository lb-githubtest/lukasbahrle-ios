//
//  SearchArtistViewModel.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 25/02/2021.
//

import Foundation

public enum LoadState: Equatable{
    case none
    case waiting
    case loading
    case error(PresentableSearchArtistError)
    
    public var isError: Bool {
        switch self {
        case .error(_):
            return true
        default:
            return false
        }
    }
}


public struct PresentableSearchArtistError: Equatable{
    public let info: String
    public let retry: String
}


public protocol SearchArtistNavigator: class{
    func didSelect(artist: Artist)
}

public class SearchArtistViewModel{

    public var title:String {
        "Artist Browser"
    }
    
    public var searchPlaceholder: String {
        "Artist name"
    }
    
    public var numberOfSearchResults: Int {
        return dataModel.count
    }
    
    public func searchResult(at index: Int) -> SearchArtistResultCellViewModel? {
        guard index < dataModel.count else {return nil}
        let artist = dataModel[index]
        return SearchArtistResultCellViewModel(artist: artist, imageLoader: imageDataLoader)
    }
   
    public var onSearchResultsCollectionUpdate: (() -> Void)?
    
    public var searchLoadState: Observable<ContentLoadState> = Observable(ContentLoadState.loaded(canLoadMore: false, countAdded: 0))
    
    
    private var dataModel = [Artist]()

    private let searchArtistLoader: SearchArtistLoader
    private let imageDataLoader: ImageDataLoader
    
    private var input:String = ""
    
    private var currentTask: CancellableTask?
    private var itemLoadingTasks = [Int: CancellableTask]()
    
    private weak var navigator: SearchArtistNavigator?
    
    
    public init(searchArtistLoader: SearchArtistLoader, imageDataLoader: ImageDataLoader, navigator: SearchArtistNavigator) {
        self.searchArtistLoader = searchArtistLoader
        self.imageDataLoader = imageDataLoader
        self.navigator = navigator
    }

    func viewDidLoad() {}

    public func inputTextChanged(input: String) {
        guard !input.isEmpty else {return}
        self.input = input
        dataModel = []

        search(input: input, loadedItems: 0)
    }
    
    public func scrolledToBottom(){
        loadNextPage()
    }
    
    public func selectArtist(at index: Int) {
        navigator?.didSelect(artist: dataModel[index])
    }
    
    public func retryLoad(){
        search(input: input, loadedItems: dataModel.count)
    }
    
    private func loadNextPage() {
        guard searchLoadState.value != .loading, searchLoadState.value.canLoadMore else {return}
        
        search(input: input, loadedItems: dataModel.count)
    }
    
    private func search(input: String, loadedItems: Int){
        
        guard !input.isEmpty else {
            print("input is empty")
            return
        }
        
        searchLoadState.value = .loading
        currentTask?.cancel()
        
        print("Search: \(input)")
        
        currentTask = searchArtistLoader.load(text: input, loadedItems: loadedItems) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result{
                    case .success(let artistList):
                        self?.onArtistListLoaded(artists: artistList)
                    case .failure(let error):
                        self?.onArtistListLoadError(error: error)
                }
            }
        }
    }
    
    private func onArtistListLoaded(artists: ArtistList){
        dataModel.append(contentsOf: artists.items)
        
        searchLoadState.value = .loaded(canLoadMore: artists.canLoadMore, countAdded: artists.items.count)
    }
    
    private func onArtistListLoadError(error: Error){
        print(error)
        searchLoadState.value = .failed
//        loadState = .error(PresentableSearchArtistError(info: "Couldn't connect to the server", retry: "Tap to retry"))
        
    }
    

}
