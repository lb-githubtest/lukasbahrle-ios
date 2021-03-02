//
//  SearchArtistResultCellViewModel.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 02/03/2021.
//

import Foundation



public class SearchArtistResultCellViewModel{
    public enum ArtistThumbnailState{
        case notLoaded
        case loading
        case failed
        case loaded(data:Data)
    }
    
    public let artistName:String
    public let arttistThumbnail: URL?
    
    public var artistThumbnailState: Observable<ArtistThumbnailState> = Observable(ArtistThumbnailState.notLoaded)
    
    private let imageLoader: ImageDataLoader
    private var imageLoaderTask: CancellableTask?
    
    internal init(artistName: String, arttistThumbnail: URL?, imageLoader: ImageDataLoader) {
        self.artistName = artistName
        self.arttistThumbnail = arttistThumbnail
        self.imageLoader = imageLoader
    }
    
    public func preload(){
        guard imageLoaderTask == nil, let url = arttistThumbnail else {return}
        
        artistThumbnailState.value = .loading
        
        imageLoaderTask = imageLoader.load(from: url, completion: { [weak self](result) in
            switch result{
            case .success(let data):
                self?.artistThumbnailState.value = .loaded(data: data)
            case .failure(_):
                self?.artistThumbnailState.value = .failed
            }
        })
    }
    
    public func cancel(){
        artistThumbnailState.valueChanged = nil
        imageLoaderTask?.cancel()
    }
}



public class Observable<T> {
    var value: T {
        didSet {
            DispatchQueue.main.async {
                self.valueChanged?(self.value)
            }
        }
    }
    public var valueChanged: ((T) -> Void)?
    
    public init(_ value: T){
        self.value = value
    }
}
