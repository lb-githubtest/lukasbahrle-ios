//
//  AppFactory.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 08/03/2021.
//

import ArtistBrowser

class AppFactory{
    func makeArtistBrowserViewController(navigator: SearchArtistNavigator, searchArtistLoader: SearchArtistLoader, imageLoader: ImageDataLoader) -> SearchArtistViewController{
        
        let viewModel = SearchArtistViewModel(searchArtistLoader: searchArtistLoader, imageDataLoader: imageLoader, navigator: navigator)
        let controller = SearchArtistViewController(viewModel: viewModel)
        
        return controller
    }
    
    func makeArtistDetailViewController(artist: Artist, albumsLoader: AlbumsLoader, imageLoader: ImageDataLoader) -> ArtistDetailViewController{
        let viewModel = ArtistDetailViewModel(artist: artist, albumsLoader: albumsLoader, imageDataLoader: imageLoader)
        let controller = ArtistDetailViewController(viewModel: viewModel)
        
        return controller
    }
}
