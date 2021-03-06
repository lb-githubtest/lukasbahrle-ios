//
//  AlbumCellViewModel.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 02/03/2021.
//

import Foundation

public class AlbumCellViewModel{
    public let id:String
    public let name:String
    public var image: ImageStateObservable
    
    internal init(album: Album, imageLoader: ImageDataLoader) {
        self.id = album.id
        self.name = album.name
        image = ImageStateObservable(imageURL: album.thumbnail, imageLoader: imageLoader)
    }
    
    public func preload(){
        image.preload()
    }
    
    public func cancel(){
        image.cancel()
    }
}
