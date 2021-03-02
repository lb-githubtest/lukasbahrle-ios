//
//  ArtistDetailCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 01/03/2021.
//

import UIKit

class ArtistDetailInfoCell: UICollectionViewCell {
    private var imageView = UIImageView()
    private var nameLabel = UILabel()
    private var infoLabel = UILabel()
    
    var cellWidth: CGFloat = 200
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
//    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
//
//            var targetSize = targetSize
//            targetSize.width = 100
//            targetSize.height = CGFloat.greatestFiniteMagnitude
//
//            let size = super.systemLayoutSizeFitting(
//                    targetSize,
//                    withHorizontalFittingPriority: .required,
//                    verticalFittingPriority: .fittingSizeLevel
//                )
//
//            return size
//        }
    
    
    private func configure(){
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(infoLabel)
        
        imageView.backgroundColor = .yellow
        
        nameLabel.numberOfLines = 0
        infoLabel.numberOfLines = 0
        
        nameLabel.text = "Artist name"
        infoLabel.text = "orem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset."
        
        configureConstraints()
    }
    
    private func configureConstraints(){
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let margins = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            //imageView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: 300),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 0),
            nameLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0),
            infoLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
