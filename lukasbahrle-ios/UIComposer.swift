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
        URLSessionHTTPClient(session: URLSession(configuration: .default))
    }()
    
    private lazy var remoteTokenLoader: TokenLoader = {
        let tokenCache = TokenCache(store: KeychainTokenStore())
        
        let tokenRequest = TokenRequest(builder: TokenRequestBuilder(), credentialsLoader: {
            Credentials(username: "80684ef2c87a4ce19f2e9f6b87edea97", password: "e0341c48219d481591187ff1dfdee64b")
        })
        
        let url = URL(string: "https://accounts.spotify.com/api/token")!
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

        let vc = UIComposer.makeArtistBrowserViewController(navigator: self, searchArtistLoader: searchArtistLoader, imageLoader: imageLoader)
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
       
        
        
        let vc = UIComposer.makeArtistDetailViewController(artist: artist, albumsLoader: albumsLoader, imageLoader: imageLoader)
        navigationController.pushViewController(vc, animated: true)
    }
}


class UIComposer{
    static func makeArtistBrowserViewController(navigator: SearchArtistNavigator, searchArtistLoader: SearchArtistLoader, imageLoader: ImageDataLoader) -> ArtistBrowserViewController{
        
        let viewModel = SearchArtistViewModel(searchArtistLoader: searchArtistLoader, imageDataLoader: imageLoader, navigator: navigator)
        let controller = ArtistBrowserViewController(viewModel: viewModel)
        
        return controller
    }
    
    static func makeArtistDetailViewController(artist: Artist, albumsLoader: AlbumsLoader, imageLoader: ImageDataLoader) -> ArtistDetailViewController{
        
        let viewModel = ArtistDetailViewModel(artist: artist, albumsLoader: albumsLoader, imageDataLoader: imageLoader)
        let controller = ArtistDetailViewController(viewModel: viewModel)
        
        return controller
    }
}




public class RemoteTokenLoaderWithCachingBehaviour: TokenLoader{
    let tokenLoader: TokenLoader
    let tokenCache: TokenSaver
    
    public init(tokenLoader: TokenLoader, tokenCache: TokenSaver){
        self.tokenLoader = tokenLoader
        self.tokenCache = tokenCache
    }
    
    public func load(completion: @escaping (TokenLoader.Result) -> Void) {
        tokenLoader.load { [weak self] (result) in
            print("on token load result:")
            print(result)
            
            
            guard let token = try? result.get() else{
                print("TOKEN error")
                completion(result)
                return
            }
            
            print("TOKEN: \(token)")
            
            self?.tokenCache.save(token: token) { _ in
                completion(result)
            }
        }
    }
}
