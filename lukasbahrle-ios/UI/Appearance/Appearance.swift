//
//  Appearance.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 07/03/2021.
//

import UIKit

struct Appearance{
    static var backgroundColor: UIColor{
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return .white
        }
    }
    
    static var imageBackground: UIColor{
        if #available(iOS 13.0, *) {
            return UIColor.secondarySystemBackground
        } else {
            return .lightGray
        }
    }
}
