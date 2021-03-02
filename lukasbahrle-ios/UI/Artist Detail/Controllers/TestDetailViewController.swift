//
//  TestDetailViewController.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 01/03/2021.
//

import UIKit

class TestDetailViewController: UIViewController {

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
    }
    
    private func configureCollectionView(){
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
        let layout = collectionView.collectionViewLayout
            if let flowLayout = layout as? UICollectionViewFlowLayout {
                flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
                //flowLayout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.size.width, height: 100)
            }
        
        collectionView.backgroundColor = .red
        collectionView.register(TestCollectionViewCell.self, forCellWithReuseIdentifier: "TestCollectionViewCell")
    }

}



extension TestDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        40
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCollectionViewCell", for: indexPath) as! TestCollectionViewCell
        cell.cellWidth = collectionView.maxCellWidth
        
        if indexPath.row > 0 && (indexPath.row % 4 == 0) {
            cell.cellWidth = collectionView.maxCellWidth * 0.45
        }
        
        if indexPath.row % 7 == 0 {
            cell.label.text = (cell.label.text ?? "") + "pap ppppsdpdf dfdf df dfpdfpdpfdpf dfpdfpdf dfpdpf dfpdfp dfjfhhpfgh pfgphpfg mm."
        }
        
        return cell
    }
}


