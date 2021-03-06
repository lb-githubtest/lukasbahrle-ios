//
//  LoadingTableViewCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 26/02/2021.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    private var indicator:UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()

    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        indicator.startAnimating()
    }
    
    private func configure(){
        selectionStyle = .none
        
        contentView.addSubview(indicator)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            indicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            indicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    
}
