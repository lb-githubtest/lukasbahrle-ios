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
    
    private var widthConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    func setup(viewModel:AlbumsHeaderCellViewModel, width: CGFloat){
        titleLabel.text = viewModel.title
        
        widthConstraint.constant = width
    }
    
    private func configure(){
        contentView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = contentView.layoutMarginsGuide
        
        
        widthConstraint = contentView.widthAnchor.constraint(equalToConstant: 200)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: topAnchor),
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthConstraint
            ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
        ])
    }
}
