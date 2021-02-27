//
//  ArtistSearchResultCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 26/02/2021.
//

import UIKit
import ArtistBrowser

class ArtistSearchResultCell: UITableViewCell {
    
    @IBOutlet private var label: UILabel!
    @IBOutlet private var thumbnail: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = nil
    }
    
    func configure(artist: PresentableArtist){
        label.text = artist.name
    }
    
    func onImageLoadResult(result: Result<Data, Error>){
        switch result {
        case .success(let data):
            UIView.transition(with: self.thumbnail,
                          duration:0.5,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in self?.thumbnail.image = UIImage(data: data) },
                          completion: nil)
            
        default:
            break
        }
    }

}
