//
//  SearchArtistResultCellViewModel.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 02/03/2021.
//

import Foundation

public class SearchArtistResultCellViewModel{
    public let artistName:String
    public var image: ImageStateObservable
    
    internal init(artist: Artist, imageLoader: ImageDataLoader) {
        self.artistName = artist.name
        self.image = ImageStateObservable(imageURL: artist.thumbnail, imageLoader: imageLoader)
    }
    
    public func preload(){
        image.preload()
    }
    
    public func cancel(){
        image.cancel()
    }
}



