//
//  UIView+NSLayoutConstraint.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 01/03/2021.
//

import UIKit


extension UIView{
    func pinTopSuperview(top: CGFloat? = 0,bottom: CGFloat? = 0, leading: CGFloat? = 0, trailing: CGFloat? = 0){
        guard let superview = self.superview else{
            fatalError("No superview")
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: top).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: bottom).isActive = true
        }
        
        if let leading = leading {
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leading).isActive = true
        }
        
        if let trailing = trailing {
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: trailing).isActive = true
        }
    }
}
