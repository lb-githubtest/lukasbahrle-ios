//
//  Dragable.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 04/03/2021.
//

import Foundation

protocol Draggable{
    var dragItemProvider: NSItemProviderWriting {get}
    var dragLocalObject: Any? {get}
}
