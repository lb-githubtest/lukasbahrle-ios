//
//  LoadingTableViewCell.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 26/02/2021.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    private var loadingView: LoadingView = LoadingView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingView.start()
    }
    
    private func configure(){
        selectionStyle = .none
        
        self.contentView.addSubview(loadingView)
        
        let container = UIView(frame: .zero)
        self.contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.heightAnchor.constraint(equalToConstant: 130)
        ])
        
        container.addSubview(loadingView)
    }
    
    
}
