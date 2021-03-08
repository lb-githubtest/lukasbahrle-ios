//
//  AuthorizedHTTPClient.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 02/03/2021.
//

import Foundation



public class AuthorizedHTTPClient: HTTPClient{
    
    typealias UnauthorizedCallback = () -> Void
    
    let client: HTTPClient
    let tokenLoader: TokenLoader
    let tokenRefreshLoader: TokenLoader
    
    var dispatchQueue = DispatchQueue(label: "AuthorizedHTTPClient.queue")
    
    public init(client: HTTPClient, tokenLoader: TokenLoader, tokenRefreshLoader: TokenLoader){
        self.client = client
        self.tokenLoader = tokenLoader
        self.tokenRefreshLoader = tokenRefreshLoader
    }
    
    var tasks = [UUID: RunningTask]()
    
    class RunningTask: CancellableTask {
        var id: UUID
        var isCancelled = false
        
        init(id: UUID){
            self.id = id
        }
        
        func cancel(){
            isCancelled = true
        }
    }
    
    public func get(request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> CancellableTask {
        
        let id = UUID()
        let task = RunningTask(id: id)
        tasks[id] = task
        
        dispatchQueue.async {
            self.get(id: id, request: request, tokenLoader: self.tokenLoader, completion: completion) { [weak self] in
                guard let self = self, !self.isRequestCancelled(id) else {
                    return
                }
                self.get(id: id, request: request, tokenLoader: self.tokenRefreshLoader, completion: completion)
            }
        }
        return task
    }

    
    private func get(id: UUID, request: URLRequest, tokenLoader: TokenLoader, completion: @escaping (HTTPClient.Result) -> Void, unauthorized: UnauthorizedCallback? = nil) {
        
        if isRequestCancelled(id) {return}
        
        tokenLoader.load { [weak self] (result) in
            guard let self = self else {return}
            
            guard let token = try? result.get() else {
                
                completion(.failure(RemoteTokenLoader.Error.unauthorized))
                return
            }
            
            if self.isRequestCancelled(id) {return}
            
            self.client.get(request: self.signRequest(request: request, token: token), completion: { [weak self] (result) in
                guard let self = self else {return}
                
                if self.isRequestCancelled(id) {return}
                
                if result.isUnauthorized, let unauthorized = unauthorized {
                    unauthorized()
                    return
                }
                
                completion(result)
            })
        }
    }
    
    func signRequest(request: URLRequest, token: Token) -> URLRequest {
        var request = request
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func isRequestCancelled(_ id: UUID) -> Bool{
        return tasks[id]?.isCancelled ?? false
    }
}
