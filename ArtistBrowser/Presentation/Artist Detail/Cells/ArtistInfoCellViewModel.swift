//
//  ArtistInfoCellViewModel.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 04/03/2021.
//

public class ArtistInfoCellViewModel{
    public let artistName:String
    public let artistInfo:String
    public var image: ImageStateObservable
    
    internal init(artist: Artist, imageLoader: ImageDataLoader) {
        self.artistName = artist.name
        self.artistInfo = artist.genres.joined(separator: ", ")
        
        image = ImageStateObservable(imageURL: artist.thumbnail, imageLoader: imageLoader)
    }
    
    public func preload(){
        image.preload()
    }
    
    public func cancel(){
        image.cancel()
    }
}
