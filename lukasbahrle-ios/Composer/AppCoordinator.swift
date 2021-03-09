//
//  AppCoordinator.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import UIKit
import ArtistBrowser


class AppCoordinator{
    private let navigationController: UINavigationController

    private lazy var client: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .default))
    }()
    
    private lazy var remoteTokenLoader: TokenLoader = {
        let tokenCache = TokenCache(store: KeychainTokenStore())
        
        let tokenRequest = TokenRequest(builder: TokenRequestBuilder(), credentialsLoader: {
            Credentials(username: "80684ef2c87a4ce19f2e9f6b87edea97", password: "e0341c48219d481591187ff1dfdee64b")
        })
        
        let remoteLoader = RemoteTokenLoader(request: {tokenRequest.get()}, client: client)
            
        return RemoteTokenLoaderWithCachingBehaviour(tokenLoader: remoteLoader, tokenCache: tokenCache)
    }()
    
    private lazy var authClient: AuthorizedHTTPClient = {
        let tokenCache = TokenCache(store: KeychainTokenStore())
        
        let tokenLoader = TokenLoaderFallback(primary: tokenCache, fallback: remoteTokenLoader)
        return AuthorizedHTTPClient(client: client, tokenLoader: tokenLoader, tokenRefreshLoader: remoteTokenLoader)
    }()
    
    private lazy var imageLoader: RemoteImageDataLoader = {
        RemoteImageDataLoader(client: client)
    }()
    
    private var factory: AppFactory
    
    init(factory: AppFactory = AppFactory()){
        navigationController = UINavigationController()
        self.factory = factory
    }
    
    func start() -> UIViewController{
        let searchArtistLoader = RemoteSearchArtistLoader(request: { input, loadedItems in
                    var builder = SearchArtistRequestBuilder()
                    builder.set(input: input, loadedItems: loadedItems)
                    let request = BasicRequest(builder: builder)
        
                    return request.get()
                }, client: authClient)

        let vc = factory.makeArtistBrowserViewController(navigator: self, searchArtistLoader: searchArtistLoader, imageLoader: imageLoader)
        navigationController.setViewControllers([vc], animated: false)
        return navigationController
    }
}

extension AppCoordinator: SearchArtistNavigator{
    func didSelect(artist: Artist) {
        
        let albumsLoader = RemoteAlbumsLoader(request: { loadedItems in
            var builder = AlbumsRequestBuilder()
            builder.set(artistId: artist.id, loadedItems: loadedItems)
            let request = BasicRequest(builder: builder)
            
            return request.get()
        }, client: authClient)
       
        let mainQueueAlbumsLoader = MainQueueAlbumsLoader(albumsLoader: albumsLoader)
        
        let vc = factory.makeArtistDetailViewController(artist: artist, albumsLoader: mainQueueAlbumsLoader, imageLoader: imageLoader)
        navigationController.pushViewController(vc, animated: true)
    }
}
