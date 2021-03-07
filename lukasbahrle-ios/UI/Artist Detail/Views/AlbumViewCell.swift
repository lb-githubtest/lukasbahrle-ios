//
//  AlbumViewCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import UIKit
import ArtistBrowser

class AlbumViewCell: UICollectionViewCell {
    private var thumbnailView: UIImageView = UIImageView()
    private var dateLabel: UILabel = UILabel()
    private var nameLabel: UILabel = UILabel()
    
    private var viewModel: AlbumCellViewModel?
    
    private var widthConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    private func configure(){
        contentView.addSubview(thumbnailView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(nameLabel)
        
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.set(style: .footnote, numberOfLines: 1)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.set(style: .footnote, numberOfLines: 2)
        
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
            thumbnailView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            thumbnailView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            thumbnailView.topAnchor.constraint(equalTo: margins.topAnchor),
            thumbnailView.heightAnchor.constraint(equalTo: thumbnailView.widthAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: thumbnailView.bottomAnchor, constant: 8),
            
            nameLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 3),
        ])
    }
    
    func setup(viewModel: AlbumCellViewModel, width: CGFloat){
        self.viewModel = viewModel
        nameLabel.text = viewModel.name
        dateLabel.text = viewModel.date
        
        viewModel.image.state.valueChanged = { [weak self] state in
            self?.onThumbnailStateChanged(state)
        }
        
        widthConstraint.constant = width
    }
    
    private func onThumbnailStateChanged(_ state: ImageState){
        switch state {
        case .loaded(data: let data):
            onArtistThumbnailDateLoaded(data)
        default:
            break
        }
    }
    
    private func onArtistThumbnailDateLoaded(_ data: Data){
        thumbnailView.image = UIImage(data: data)
    }
    
    private func reset(){
        thumbnailView.image = nil
        viewModel?.cancel()
        viewModel = nil
    }
    
}


extension AlbumViewCell: CellPreloadable{
    func preload() {
        viewModel?.preload()
    }
    
    func cancelLoad() {
        viewModel?.cancel()
    }
}


extension AlbumViewCell: Draggable{
    var dragItemProvider: NSItemProviderWriting {
        (viewModel?.id ?? "") as NSString
    }
    var dragLocalObject: Any? {
        viewModel
    }
}




