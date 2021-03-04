//
//  ArtistDetailCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 01/03/2021.
//

import UIKit
import ArtistBrowser

class ArtistDetailInfoCell: UICollectionViewCell {
    private var imageView = UIImageView()
    private var nameLabel = UILabel()
    private var infoLabel = UILabel()
    
    private var viewModel: ArtistInfoCellViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    public func setup(viewModel: ArtistInfoCellViewModel){
        self.viewModel = viewModel
        
        nameLabel.text = viewModel.artistName
        infoLabel.text = viewModel.artistInfo
        
        viewModel.image.state.valueChanged = { [weak self] state in
            self?.onImageStateChanged(state)
        }
    }
    
    
    private func onImageStateChanged(_ state: ImageState){
        switch state {
        case .loaded(data: let data):
            onImageThumbnailDateLoaded(data)
        default:
            break
        }
    }
    
    private func onImageThumbnailDateLoaded(_ data: Data){
        imageView.image = UIImage(data: data)
    }
    
    private func reset(){
        imageView.image = nil
        viewModel?.cancel()
        viewModel = nil
    }
    
    
    private func configure(){
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(infoLabel)
        
        imageView.backgroundColor = .lightGray
        
        nameLabel.set(style: .largeTitle)
        infoLabel.set(style: .subheadline)
        
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
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }
}



extension ArtistDetailInfoCell: CellPreloadable{
    func preload() {
        
        viewModel?.preload()
    }
    
    func cancelLoad() {
        viewModel?.cancel()
    }
}


extension UILabel {
    func set(style: UIFont.TextStyle, numberOfLines: Int = 0, dynamicType: Bool = true){
        self.numberOfLines = numberOfLines
        self.font = UIFont.preferredFont(forTextStyle: style)
        self.adjustsFontForContentSizeCategory = dynamicType
    }
}
