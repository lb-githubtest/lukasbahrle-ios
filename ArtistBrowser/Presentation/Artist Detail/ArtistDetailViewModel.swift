//
//  ArtistDetailViewModel.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import Foundation


public protocol ArtistDetailViewModelObserver: NSObject {
    func onLoadingStateChange(value: LoadState, previous: LoadState)
    func onAlbumListUpdated()
    func onItemPreloadCompleted(index: Int, result: Result<Data, Error>)
}

protocol ArtistDetailViewModelType {
    associatedtype PresentableAlbumData
    
    var observer: ArtistDetailViewModelObserver? {get set}
    
    var numberOfAlbums: Int {get}
    func album(at index: Int) -> PresentableAlbumData?
    
    var loadState: LoadState {get}
    
    var title: String {get}
    
    func viewDidLoad()
    
    func scrolledToBottom()
    
    func preloadItem(at index: Int)
    func cancelItem(at index: Int)
    
    func retryLoad()
    
    func reorderAlbum(from: Int, to: Int)
}


public struct PresentableAlbum{
    public let id: String
    public let name:String
    public let thumbnail: URL?
}



public class ArtistDetailViewModel: ArtistDetailViewModelType{
    
    public var observer: ArtistDetailViewModelObserver?
    
    public var numberOfAlbums: Int {
        return albumsDataModel.count
    }
    
    public func album(at index: Int) -> PresentableAlbum? {
        guard index < albumsDataModel.count else {return nil}
        let album = albumsDataModel[index]
        return PresentableAlbum(id: album.id, name: album.name, thumbnail: album.thumbnail)
    }
    
    public var loadState: LoadState = .none
    
    public var title: String = ""
    
    private let artist: Artist
    private var albumsDataModel = [Album]()
    
    private let albumsLoader: AlbumsLoader
    private let imageDataLoader: ImageDataLoader
    
    private var currentTask: CancellableTask?
    private var itemLoadingTasks = [Int: CancellableTask]()
    
    public init(artist: Artist, albumsLoader: AlbumsLoader, imageDataLoader: ImageDataLoader){
        self.artist = artist
        self.title = artist.name
        self.albumsLoader = albumsLoader
        self.imageDataLoader = imageDataLoader
    }
    
    public func viewDidLoad() {
        loadAlbums(loadedItems: 0)
    }
    
    public func scrolledToBottom() {
        loadNextPage()
    }
    
    public func preloadItem(at index: Int) {
        guard itemLoadingTasks[index] == nil, index < albumsDataModel.count else {
            return
        }
        
        guard let imageURL = albumsDataModel[index].thumbnail else {
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
    
    public func retryLoad() {
        
    }
    
    public func reorderAlbum(from: Int, to: Int) {
        let album = albumsDataModel[from]
        albumsDataModel.remove(at: from)
        albumsDataModel.insert(album, at: to)
    }
    
    private func loadNextPage() {
        guard loadState != .loading, loadState != .none, albumsDataModel.count > 0 else {return}
        loadAlbums(loadedItems: albumsDataModel.count)
    }
    
    private func loadAlbums(loadedItems: Int){
        loadState = .loading
        currentTask?.cancel()
        
        currentTask = albumsLoader.load(loadedItems: loadedItems) { [weak self] (result) in
            
            DispatchQueue.main.async {
                switch result{
                    case .success(let albumsList):
                        self?.onAlbumListLoaded(albums: albumsList)
                    case .failure(let error):
                        self?.onAlbumListLoadError(error: error)
                }
            }
        }
    }
    
    private func onAlbumListLoaded(albums: AlbumList){
        
        albumsDataModel.append(contentsOf: albums.items)
        
        loadState = albums.canLoadMore ? .waiting : .none
        
        observer?.onAlbumListUpdated()
    }
    
    private func onAlbumListLoadError(error: Error){
        loadState = .error(PresentableSearchArtistError(info: "Couldn't connect to the server", retry: "Tap to retry"))
        
    }
    
}
