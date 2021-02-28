//
//  UIComposer.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import UIKit
import ArtistBrowser


class AppCoordinator{
    private let navigationController: UINavigationController
    
    init(){
        navigationController = UINavigationController()
    }
    
    func start() -> UIViewController{
        let vc = UIComposer.makeArtistBrowserViewController(navigator: self)
        navigationController.setViewControllers([vc], animated: false)
        return navigationController
    }
}

extension AppCoordinator: SearchArtistNavigator{
    func didSelect(artist: Artist) {
        let vc = UIComposer.makeArtistDetailViewController(artist: artist)
        navigationController.pushViewController(vc, animated: true)
    }
}




class UIComposer{
    static func makeArtistBrowserViewController(navigator: SearchArtistNavigator) -> ArtistBrowserViewController{
        let bundle = Bundle(for: ArtistBrowserViewController.self)
        let storyboard = UIStoryboard(name: "ArtistBrowser", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ArtistBrowserViewController
        
        let searchArtistLoader = RemoteSearchArtistLoader(request: { input, loadedItems in
            var builder = SearchArtistRequestBuilder()
            builder.set(input: input, loadedItems: loadedItems)
            let request = SearchArtisRequest(builder: builder)
            
            return request.get()
        }, client: URLSessionHTTPClient(session: URLSession(configuration: .ephemeral)))
        
        let imageLoader = RemoteImageDataLoader(client: URLSessionHTTPClient(session: URLSession(configuration: .ephemeral)))
        
        let viewModel = SearchArtistViewModel(searchArtistLoader: searchArtistLoader, imageDataLoader: imageLoader, navigator: navigator)
        
        controller.viewModel = viewModel
        
        return controller
    }
    
    static func makeArtistDetailViewController(artist: Artist) -> ArtistDetailViewController{
        
        let bundle = Bundle(for: ArtistDetailViewController.self)
        let storyboard = UIStoryboard(name: "ArtistDetail", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ArtistDetailViewController
        
        
        let albumsLoader = RemoteAlbumsLoader(request: { loadedItems in
            var builder = AlbumsRequestBuilder()
            builder.set(artistId: artist.id, loadedItems: loadedItems)
            let request = SearchArtisRequest(builder: builder)
            
            return request.get()
        }, client: URLSessionHTTPClient(session: URLSession(configuration: .ephemeral)))
        
        let imageLoader = RemoteImageDataLoader(client: URLSessionHTTPClient(session: URLSession(configuration: .ephemeral)))
        
        
        let viewModel = ArtistDetailViewModel(artist: artist, albumsLoader: albumsLoader, imageDataLoader: imageLoader)
        controller.viewModel = viewModel
        
        return controller
    }
}
