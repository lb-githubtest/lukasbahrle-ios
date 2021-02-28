//
//  SceneDelegate.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 21/02/2021.
//

import UIKit
import ArtistBrowser

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        appCoordinator = AppCoordinator()
        window?.rootViewController = appCoordinator?.start()
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    
    

}



struct SearchArtisRequest: Request{
    var builder: RequestBuilder
    
    
}


struct SearchArtistRequestBuilder: RequestBuilder {
    var baseURL: URL = URL(string: "https://api.spotify.com/v1/")!
    
    var path: String =  "search"
    
    var httpMethod: HTTPMethod = .GET
    
    var params: [URLQueryItem]? = [
        URLQueryItem(name: "type", value: "artist"),
        URLQueryItem(name: "limit", value: "7")
    ]
    
    var headers: [String : String]? =  ["Authorization": "Bearer BQAbMPVweJCNmTr4tAkpnAOT32wnlRUadIeykG3OTfhJfyDHj-6TognFYKtHQEcl4OjYH1QZmtik1pVWk9c"]
    
    var body: Data?
    

    mutating func set(input: String, loadedItems: Int){
        var queryParams = params!
        queryParams.append(URLQueryItem(name: "q", value: input))
        queryParams.append(URLQueryItem(name: "offset", value: "\(loadedItems)"))
        
        params = queryParams
    }
    
}




struct AlbumsRequestBuilder: RequestBuilder {
    var baseURL: URL = URL(string: "https://api.spotify.com/v1/")!
    
    var path: String =  ""
    
    var httpMethod: HTTPMethod = .GET
    
    var params: [URLQueryItem]? = [
        URLQueryItem(name: "limit", value: "5")
    ]
    
    var headers: [String : String]? =  ["Authorization": "Bearer BQAbMPVweJCNmTr4tAkpnAOT32wnlRUadIeykG3OTfhJfyDHj-6TognFYKtHQEcl4OjYH1QZmtik1pVWk9c"]
    
    var body: Data?
    
    mutating func set(artistId: String, loadedItems: Int){
        
        path = "artists/\(artistId)/albums"
        
        var queryParams = params!
        queryParams.append(URLQueryItem(name: "offset", value: "\(loadedItems)"))
        
        params = queryParams
    }
    
}
