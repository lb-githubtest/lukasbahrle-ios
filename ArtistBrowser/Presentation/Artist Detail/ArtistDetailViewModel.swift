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
    
    var observer: SearchArtistViewModelObserver? {get set}
    
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
    public let thumbnail: String
}

struct Album{
    let id: String
    let name: String
    let thumbnail: String
}

public class ArtistDetailViewModel: ArtistDetailViewModelType{
    
    public var observer: SearchArtistViewModelObserver?
    
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
    
    public init(artist: Artist){
        self.artist = artist
        self.title = artist.name
        
        print("Detail of: \(artist.name)")
        
        albumsDataModel = [
            Album(id: "1", name: "AAA", thumbnail: ""),
            Album(id: "2", name: "BBB", thumbnail: ""),
            Album(id: "3", name: "CCC", thumbnail: ""),
            Album(id: "4", name: "DDD", thumbnail: ""),
            Album(id: "5", name: "EEE", thumbnail: ""),
            Album(id: "6", name: "FFF", thumbnail: ""),
            Album(id: "7", name: "GGG", thumbnail: "")
        ]
    }
    
    public func viewDidLoad() {
        
    }
    
    public func scrolledToBottom() {
        
    }
    
    public func preloadItem(at index: Int) {
        
    }
    
    public func cancelItem(at index: Int) {
        
    }
    
    public func retryLoad() {
        
    }
    
    public func reorderAlbum(from: Int, to: Int) {
        let album = albumsDataModel[from]
        albumsDataModel.remove(at: from)
        albumsDataModel.insert(album, at: to)
    }
    
}
