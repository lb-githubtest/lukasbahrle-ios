//
//  SearchArtistViewModel.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 25/02/2021.
//

import Foundation

public enum LoadState{
    case none
    case waiting
    case loading
    case error
}


public protocol SearchArtistViewModelObserver: NSObject {
    func onLoadingStateChange()
    func onArtistListUpdated()
    func onItemPreloadCompleted(result: Result<Data, Error>)
}


protocol SearchArtistViewModelType {
    associatedtype PresentableArtistData
    
    var observer: SearchArtistViewModelObserver? {get set}
    
    var dataModel: [PresentableArtistData] {get}
    var loadState: LoadState {get}
    
    func viewDidLoad()
    
    func inputTextChanged(input: String)
    func loadNextPage()
    
    func preloadItem(at index: Int)
    func cancelItem(at index: Int)
}



public struct PresentableArtist{
    let name: String
    let thumbnail: URL?
}




public class SearchArtistViewModel: SearchArtistViewModelType{
    
    private(set) var dataModel = [PresentableArtist]()

    private(set) var loadState: LoadState = .none

    private let searchArtistLoader: SearchArtistLoader
    private let imageDataLoader: ImageDataLoader
    
    private var input:String = ""
    private var pagesLoaded = 0
    
    private var currentTask: CancellableTask?
    private var itemLoadingTasks = [Int: CancellableTask]()
    
    weak var observer: SearchArtistViewModelObserver?
    
    init(searchArtistLoader: SearchArtistLoader, imageDataLoader: ImageDataLoader) {
        self.searchArtistLoader = searchArtistLoader
        self.imageDataLoader = imageDataLoader
    }

    func viewDidLoad() {
        
    }

    func inputTextChanged(input: String) {
        self.input = input
        self.pagesLoaded = 0
        dataModel = []

        search(input: input, page: pagesLoaded)
    }
    
    func loadNextPage() {
        guard loadState != .loading else {return}
        
        search(input: input, page: pagesLoaded)
    }

    func preloadItem(at index: Int) {
        guard itemLoadingTasks[index] == nil else {
            return
        }
        
        guard let imageURL = dataModel[index].thumbnail else {
            return
        }
        
        itemLoadingTasks[index] = imageDataLoader.load(from: imageURL, completion: { [weak self] result in
            self?.observer?.onItemPreloadCompleted(result: result)
            self?.itemLoadingTasks[index] = nil
        })
    }

    func cancelItem(at index: Int) {
        itemLoadingTasks[index]?.cancel()
        itemLoadingTasks[index] = nil
    }
    
    private func search(input: String, page: Int){
        loadState = .loading
        currentTask?.cancel()
        
        currentTask = searchArtistLoader.load(text: input, page: page) { [weak self] (result) in
            switch result{
                case .success(let artistList):
                    self?.onArtistListLoaded(artists: artistList)
                case .failure(let error):
                    self?.onArtistListLoadError(error: error)
            }
        }
    }
    
    private func onArtistListLoaded(artists: ArtistList){
        pagesLoaded = pagesLoaded + 1
        dataModel.append(contentsOf: artists.items.map{
            PresentableArtistData(name: $0.name, thumbnail: $0.thumbnail)
        })
        
        loadState = artists.canLoadMore ? .waiting : .none
    }
    
    private func onArtistListLoadError(error: Error){
        loadState = .error
    }
    

}
