//
//  ImageStateObservable.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 03/03/2021.
//

import Foundation


public enum ImageState{
    case notLoaded
    case loading
    case failed
    case loaded(data:Data)
    
    var loaded: Bool {
        switch self {
        case .loaded(data: _):
            return true
        default:
            return false
        }
    }
}

public class ImageStateObservable{
    public let imageURL: URL?
    
    public var state: Observable<ImageState> = Observable(ImageState.notLoaded)
    
    private let imageLoader: ImageDataLoader
    private var imageLoaderTask: CancellableTask?
    
    internal init(imageURL: URL?, imageLoader: ImageDataLoader) {
        self.imageLoader = imageLoader
        self.imageURL = imageURL
    }
    
    public func preload(){
        
        guard !state.value.loaded, imageLoaderTask == nil, let url = imageURL else {return}
        
        state.value = .loading
        
        imageLoaderTask = imageLoader.load(from: url, completion: { [weak self](result) in
            switch result{
            case .success(let data):
                self?.state.value = .loaded(data: data)
            case .failure(_):
                self?.state.value = .failed
            }
        })
    }
    
    public func cancel(){
        state.valueChanged = nil
        imageLoaderTask?.cancel()
        imageLoaderTask = nil
    }
}
