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

    
    private lazy var client: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var remoteTokenLoader: TokenLoader = {
        let tokenRequest = TokenRequest(builder: TokenRequestBuilder(), credentialsLoader: {
            Credentials(username: "80684ef2c87a4ce19f2e9f6b87edea97", password: "e0341c48219d481591187ff1dfdee64b")
        })
        
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        let remoteLoader = RemoteTokenLoader(request: {tokenRequest.get()}, client: client)
            
        return remoteLoader
//        return RemoteTokenLoaderWithCachingBehaviour(tokenLoader: remoteLoader, tokenCache: tokenCache)
    }()
    
    private lazy var authClient: AuthorizedHTTPClient = {
        
        let tokenCache = TokenCache(store: KeychainTokenStore())
        
        let tokenLoader = TokenLoaderFallback(primary: tokenCache, fallback: remoteTokenLoader)
        return AuthorizedHTTPClient(client: client, tokenLoader: tokenLoader, tokenRefreshLoader: remoteTokenLoader)
    }()
    
    init(){
        navigationController = UINavigationController()
    }
    
    func start() -> UIViewController{
        
        let searchArtistLoader = RemoteSearchArtistLoader(request: { input, loadedItems in
                    var builder = SearchArtistRequestBuilder()
                    builder.set(input: input, loadedItems: loadedItems)
                    let request = SearchArtisRequest(builder: builder)
        
                    return request.get()
                }, client: authClient)

        let vc = UIComposer.makeArtistBrowserViewController(navigator: self, searchArtistLoader: searchArtistLoader)
        navigationController.setViewControllers([vc], animated: false)
        return navigationController
    }
}

extension AppCoordinator: SearchArtistNavigator{
    func didSelect(artist: Artist) {
        
        let albumsLoader = RemoteAlbumsLoader(request: { loadedItems in
            var builder = AlbumsRequestBuilder()
            builder.set(artistId: artist.id, loadedItems: loadedItems)
            let request = SearchArtisRequest(builder: builder)
            
            return request.get()
        }, client: authClient)
       
        
        
        let vc = UIComposer.makeArtistDetailViewController(artist: artist, albumsLoader: albumsLoader)
        navigationController.pushViewController(vc, animated: true)
    }
}




class UIComposer{
    static func makeArtistBrowserViewController(navigator: SearchArtistNavigator, searchArtistLoader: SearchArtistLoader) -> ArtistBrowserViewController{
        let bundle = Bundle(for: ArtistBrowserViewController.self)
        let storyboard = UIStoryboard(name: "ArtistBrowser", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ArtistBrowserViewController
        let imageLoader = RemoteImageDataLoader(client: URLSessionHTTPClient(session: URLSession(configuration: .ephemeral)))
        
        let viewModel = SearchArtistViewModel(searchArtistLoader: searchArtistLoader, imageDataLoader: imageLoader, navigator: navigator)
        
        controller.viewModel = viewModel
        
        return controller
    }
    
    static func makeArtistDetailViewController(artist: Artist, albumsLoader: AlbumsLoader) -> ArtistDetailViewController{
        
        let bundle = Bundle(for: ArtistDetailViewController.self)
        let storyboard = UIStoryboard(name: "ArtistDetail", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ArtistDetailViewController
        
        let imageLoader = RemoteImageDataLoader(client: URLSessionHTTPClient(session: URLSession(configuration: .ephemeral)))
        
        let viewModel = ArtistDetailViewModel(artist: artist, albumsLoader: albumsLoader, imageDataLoader: imageLoader)
        controller.viewModel = viewModel
        
        return controller
    }
}
