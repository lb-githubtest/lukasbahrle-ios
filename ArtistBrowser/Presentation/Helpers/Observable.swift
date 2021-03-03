//
//  Observable.swift
//  ArtistBrowser
//
//  Created by Lukas Bahrle Santana on 03/03/2021.
//

import Foundation

public class Observable<T> {
    var value: T {
        didSet {
            DispatchQueue.main.async {
                self.valueChanged?(self.value)
            }
        }
    }
    public var current: T {
        return value
    }
    public var valueChanged: ((T) -> Void)?
    
    public init(_ value: T){
        self.value = value
    }
}
