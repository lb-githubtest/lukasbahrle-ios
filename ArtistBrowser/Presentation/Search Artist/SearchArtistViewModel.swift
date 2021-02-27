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


public protocol SearchArtistViewModelObserver: NSObject {
    func onLoadingStateChange(value: LoadState, previous: LoadState)
    func onArtistListUpdated()
    func onItemPreloadCompleted(index: Int, result: Result<Data, Error>)
}


protocol SearchArtistViewModelType {
    associatedtype PresentableArtistData
    
    var observer: SearchArtistViewModelObserver? {get set}
    
    var numberOfArtists: Int {get}
    func artist(at index: Int) -> PresentableArtistData?
    
    var loadState: LoadState {get}
    
    var title: String {get}
    var searchPlaceholder: String {get}
    
    func viewDidLoad()
    
    func inputTextChanged(input: String)
    func scrolledToBottom()
    
    func preloadItem(at index: Int)
    func cancelItem(at index: Int)
    
    func selectArtist(at index: Int)
    func retryLoad()

}



public struct PresentableArtist{
    public let name: String
    public let thumbnail: URL?
}

public struct PresentableSearchArtistError: Equatable{
    public let info: String
    public let retry: String
}




public protocol SearchArtistNavigator: class{
    func didSelect(artist: Artist)
}



public class SearchArtistViewModel: SearchArtistViewModelType{

    public var title:String {
        "Artist Browser"
    }
    
    public var searchPlaceholder: String {
        "Artist name"
    }
    
    public var numberOfArtists: Int {
        return dataModel.count
    }
    
    public func artist(at index: Int) -> PresentableArtist? {
        guard index < dataModel.count else {return nil}
        let artist = dataModel[index]
        return PresentableArtistData(name: artist.name, thumbnail: artist.thumbnail)
    }
   
    public private(set) var loadState: LoadState = .none {
        didSet{
            observer?.onLoadingStateChange(value: loadState, previous: oldValue)
        }
    }
    
    public weak var observer: SearchArtistViewModelObserver?
    
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

    func viewDidLoad() {
        
    }

    public func inputTextChanged(input: String) {
        guard !input.isEmpty else {return}
        self.input = input
        dataModel = []

        search(input: input, loadedItems: 0)
    }
    
    public func scrolledToBottom(){
        loadNextPage()
    }
    
    public func preloadItem(at index: Int) {
        guard itemLoadingTasks[index] == nil, index < dataModel.count else {
            return
        }
        
        guard let imageURL = dataModel[index].thumbnail else {
            return
        }
        
        itemLoadingTasks[index] = imageDataLoader.load(from: imageURL, completion: { [weak self] result in
            DispatchQueue.main.async {
                self?.observer?.onItemPreloadCompleted(index: index, result: result)
                self?.itemLoadingTasks[index] = nil
            }
        })
    }

    public func cancelItem(at index: Int) {
        itemLoadingTasks[index]?.cancel()
        itemLoadingTasks[index] = nil
    }
    
    public func selectArtist(at index: Int) {
        print("selectArtist: \(index)")
        navigator?.didSelect(artist: dataModel[index])
    }
    
    public func retryLoad(){
        search(input: input, loadedItems: dataModel.count)
    }
    
    private func loadNextPage() {
        guard loadState != .loading, loadState != .none, dataModel.count > 0 else {return}
        search(input: input, loadedItems: dataModel.count)
    }
    
    private func search(input: String, loadedItems: Int){
        
        guard !input.isEmpty else {
            print("input is empty")
            return
        }
        
        loadState = .loading
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
        
        loadState = artists.canLoadMore ? .waiting : .none
        
        observer?.onArtistListUpdated()
    }
    
    private func onArtistListLoadError(error: Error){
        loadState = .error(PresentableSearchArtistError(info: "Couldn't connect to the server", retry: "Tap to retry"))
        
    }
    

}
