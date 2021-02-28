//
//  ArtistDetailViewController.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 27/02/2021.
//

import UIKit
import ArtistBrowser

class ArtistDetailViewController: UICollectionViewController {

    let numberOfTopCells = 1
    
    var viewModel: ArtistDetailViewModel! {
        didSet{
            bind()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        //layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        
        collectionView.collectionViewLayout = layout
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
        guard let cell = collectionView.cellForItem(at: IndexPath(row: index + numberOfTopCells, section: 0)) as? AlbumViewCell else {return}
        cell.onImageLoadResult(result: result)
    }
    
    func onAlbumsFilterDatesChanged(start: (text: String, date: Date)?, end: (text: String, date: Date)?) {
        guard let cell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? AlbumsDatesCollectionViewCell else {return}
        cell.set(start: start, end: end)
    }
}

extension ArtistDetailViewController: AlbumsFilterDatesViewDelegate{
    func onAlbumsFilterStartDateChange(_ date: Date) {
        viewModel.onAlbumsFilterStartDateChange(date)
    }
    
    func onAlbumsFilterEndDateChange(_ date: Date) {
        viewModel.onAlbumsFilterEndDateChange(date)
    }
}


// MARK: UICollectionViewDataSource

extension ArtistDetailViewController{
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + viewModel.numberOfAlbums + numberOfTopCells + (viewModel.loadState != .none ? 1 : 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumsDatesCollectionViewCell", for: indexPath) as! AlbumsDatesCollectionViewCell
            cell.delegate = self
            return cell
        }
        
        if indexPath.row - numberOfTopCells >= viewModel.numberOfAlbums {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCollectionViewCell", for: indexPath) as! LoadingCollectionViewCell
            cell.start()
            return cell
        }
        
        guard let album = viewModel.album(at: indexPath.row - numberOfTopCells) else {
            fatalError()
        }
        
        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCollectionCell", for: indexPath) as! TestCollectionCell
//
//        cell.titleLabel.text = album.name + "as d asd as d asd as das d as d asd as d asd as d as d asd as d as d sa dasdasdasdasdas"
//        cell.layer.borderWidth = 0
//        cell.layer.borderColor = UIColor.lightGray.cgColor
//        cell.maxWidth = collectionView.bounds.width - 10
//
//        return cell
        
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
        
        if indexPath.row < numberOfTopCells {return}
        
        if indexPath.row - numberOfTopCells == viewModel.numberOfAlbums {
            // loading cell
            viewModel.scrolledToBottom()
        }
        else{
            viewModel.preloadItem(at: indexPath.row - numberOfTopCells)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row - numberOfTopCells < viewModel.numberOfAlbums {
            viewModel.cancelItem(at: indexPath.row - numberOfTopCells)
        }
    }
}



