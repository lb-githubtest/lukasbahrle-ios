//
//  LoadingCollectionViewCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 28/02/2021.
//

import UIKit

class LoadingCollectionViewCell: UICollectionViewCell {
    private var loadingView: LoadingView = LoadingView()
    
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
        start()
    }
    
    private func configure(){
        self.contentView.addSubview(loadingView)
    }
    
    func start(){
        loadingView.start()
    }
}
