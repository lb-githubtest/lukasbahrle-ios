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
            print("Cancelled request!")
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
                    
                    print("Unauthorized")
                    
                    return
                }
                
                print("Authorized")
                print(token)
                
                completion(result)
            })
        }
    }
    
    func signRequest(request: URLRequest, token: Token) -> URLRequest {
        var request = request
        print("sign reuest with token: \(token)")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func isRequestCancelled(_ id: UUID) -> Bool{
        return tasks[id]?.isCancelled ?? false
    }
    
}



//public class AuthorizedHTTPClient: HTTPClient{
//
//    typealias UnauthorizedCallback = () -> Void
//
//    let client: HTTPClient
//    let tokenLoader: TokenLoader
//    let tokenRefreshLoader: TokenLoader
//
//    private var pendingRequests = [PendingRequestTask]()
//
//    //private var tasks = [UUID: PendingRequestTask]()
//
//    public init(client: HTTPClient, tokenLoader: TokenLoader, tokenRefreshLoader: TokenLoader){
//        self.client = client
//        self.tokenLoader = tokenLoader
//        self.tokenRefreshLoader = tokenRefreshLoader
//    }
//
//
//    private class PendingRequestTask: CancellableTask {
//        private(set) var request: URLRequest?
//        private(set) var completion: ((HTTPClient.Result) -> Void)?
//
//        init(request: URLRequest, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
//            self.request = request
//            self.completion = completion
//        }
//
//        func cancel() {
//            request = nil
//            completion = nil
//        }
//    }
//
//
//
//    public func get(request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> CancellableTask {
//
//        let pendingRequest = PendingRequestTask(request: request, completion: completion)
//        pendingRequests.append(pendingRequest)
//
//        guard pendingRequests.count == 0 else {
//            return pendingRequest
//        }
//
//        tokenLoader.load { [weak self] (result) in
//
//            guard let token = try? result.get(), let signedRequest = self?.signRequest(request: request, token: token) else {
//                //completion(.failure(RemoteTokenLoader.Error.unauthorized))
//                //return
//            }
//
//        }
//    }
//
//
//    private func callPendingRequests(token: Token){
//        for pending in pendingRequests {
//            guard let request = pending.request else {
//                // cancelled
//                return
//            }
//
//            let signedRequest = signRequest(request: request, token: token)
//
//            client.get(request: signedRequest, completion: { (result) in
//                if result.isUnauthorized, let unauthorized = unauthorized {
//                    unauthorized()
//                    return
//                }
//                completion(result)
//            })
//        }
//
//        pendingRequests.removeAll()
//    }
//
//    private func get(request: URLRequest, tokenLoader: TokenLoader, completion: @escaping (HTTPClient.Result) -> Void, unauthorized: UnauthorizedCallback? = nil) {
//
//        tokenLoader.load { [weak self] (result) in
//
//            guard let token = try? result.get(), let signedRequest = self?.signRequest(request: request, token: token) else {
//                completion(.failure(RemoteTokenLoader.Error.unauthorized))
//                return
//            }
//
//            self?.client.get(request: signedRequest, completion: { (result) in
//                if result.isUnauthorized, let unauthorized = unauthorized {
//                    unauthorized()
//                    return
//                }
//                completion(result)
//            })
//        }
//    }
//
//    func signRequest(request: URLRequest, token: Token) -> URLRequest {
//        var request = request
//        print("sign reuest with token: \(token)")
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        return request
//    }
//
//}
