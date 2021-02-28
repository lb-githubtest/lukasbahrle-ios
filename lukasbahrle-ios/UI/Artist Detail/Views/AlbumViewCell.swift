//
//  AlbumViewCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import UIKit
import ArtistBrowser

class AlbumViewCell: UICollectionViewCell {
    @IBOutlet private var thumbnailView: UIImageView!
    @IBOutlet private var albumNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func prepareForReuse() {
        thumbnailView.image = nil
    }
    
    private func configure(){
        
    }
    
    func set(info: PresentableAlbum){
        albumNameLabel.text = info.name
    }
    
    func onImageLoadResult(result: Result<Data, Error>){
        
        switch result {
        case .success(let data):
            self.thumbnailView.image = UIImage(data: data)
//            UIView.transition(with: self.thumbnailView,
//                          duration:0.5,
//                          options: .transitionCrossDissolve,
//                          animations: { [weak self] in self?.thumbnailView.image = UIImage(data: data) },
//                          completion: nil)
            
        default:
            break
        }
    }
}
