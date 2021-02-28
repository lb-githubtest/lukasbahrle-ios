//
//  ArtistDetailViewController.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import UIKit
import ArtistBrowser

class ArtistDetailViewController: UICollectionViewController {

    var viewModel: ArtistDetailViewModel! {
        didSet{
            bind()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.register(LoadingCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: LoadingCollectionViewCell.self))
        
        enableDragDrop()
        
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    private func bind(){
        self.title = viewModel.title
        viewModel.observer = self
    }
    
    private func enableDragDrop(){
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
    }
}


extension ArtistDetailViewController: ArtistDetailViewModelObserver{
    func onLoadingStateChange(value: LoadState, previous: LoadState) {
        
    }
    
    func onAlbumListUpdated() {
        collectionView.reloadData()
    }
    
    func onItemPreloadCompleted(index: Int, result: Result<Data, Error>) {
        guard let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? AlbumViewCell else {return}
        cell.onImageLoadResult(result: result)
    }
    
    
}


// MARK: UICollectionViewDataSource

extension ArtistDetailViewController{
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfAlbums + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row >= viewModel.numberOfAlbums {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
            cell.start()
            return cell
        }
        
        guard let album = viewModel.album(at: indexPath.row) else {
            fatalError()
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumViewCell", for: indexPath) as! AlbumViewCell
        cell.set(info: album)
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(ArtistDetailHeaderView.self)",
                for: indexPath) as? ArtistDetailHeaderView
              else {
                fatalError("Invalid view type")
            }
        
        return headerView
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.numberOfAlbums {
            // loading cell
            viewModel.scrolledToBottom()
        }
        else{
            viewModel.preloadItem(at: indexPath.row)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row < viewModel.numberOfAlbums {
            viewModel.cancelItem(at: indexPath.row)
        }
    }
}



