//
//  AlbumsTitleCollectionViewCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 04/03/2021.
//

import UIKit
import ArtistBrowser

class AlbumsHeaderCollectionViewCell: UICollectionViewCell {
    private var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    
    func setup(viewModel:AlbumsHeaderCellViewModel){
        titleLabel.text = viewModel.title
    }
    
    private func configure(){
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = contentView.layoutMarginsGuide
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
        ])
    }
}
