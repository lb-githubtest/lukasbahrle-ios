//
//  ArtistBrowserViewController.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 26/02/2021.
//

import UIKit
import ArtistBrowser

class ArtistBrowserViewController: UITableViewController {
    
    var searchController: UISearchController?

    var viewModel: SearchArtistViewModel! {
        didSet { bind() }
    }
    
    private var loadingIndexPath: IndexPath {
        return IndexPath(row: 0, section: 1)
    }
    
    private var canLoadMoreAlbums: Bool {
        viewModel.searchLoadState.current.canLoadMore
    }
    
    private var isLoadingCellIsVisible: Bool {
        guard let visibleIndexPaths = self.tableView.indexPathsForVisibleRows else {
            return false
        }
        return visibleIndexPaths.contains(self.loadingIndexPath)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    private func bind(){
        guard let viewModel = viewModel else {
            fatalError("Set first the vc viewModel")
        }
        
        self.title = viewModel.title
        
        viewModel.searchLoadState.valueChanged = { [weak self] state in
            switch state {
            case .loading:
                self?.tableView.reloadData()
            case .loaded(canLoadMore:let canLoadMore, countAdded: let count):
                self?.onSearchResultsLoaded(canLoadMore: canLoadMore, countAdded: count)
            default:
                break
            }
        }
        
        viewModel.onSearchResultsCollectionUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
    }
 
    private func configure(){
        self.definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        self.title = viewModel?.title
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        configureSearchView()
    }
    
    private func configureSearchView(){
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.placeholder = viewModel?.searchPlaceholder
        searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    
    private func onSearchResultsLoaded(canLoadMore: Bool, countAdded: Int){
        
        let resultsSection = 0
        let loadingSection = 1
        let startIndex = viewModel.numberOfSearchResults - countAdded
        let endIndex = viewModel.numberOfSearchResults - 1
        var indexPaths: [IndexPath] = []
        
        tableView.performBatchUpdates {
            if endIndex >= startIndex, endIndex >= 0, startIndex >= 0 {
               for index in startIndex...endIndex{
                   indexPaths.append(IndexPath(row: index, section: resultsSection))
               }
                tableView.insertRows(at: indexPaths, with: .automatic)
           }
            
            if !canLoadMore {
                tableView.deleteSections(IndexSet([loadingSection]), with: .automatic)

            }
        } completion: { [weak self] completed in
            guard let self = self else {return}
            self.loadMoreAlbumsIfScrolledBottom()
        }
    }
    
    private func loadMoreAlbumsIfScrolledBottom(){
        if canLoadMoreAlbums &&  isLoadingCellIsVisible{
            viewModel.scrolledToBottom()
        }
    }
}


    
// MARK: - Table view data source

extension ArtistBrowserViewController{

    override func numberOfSections(in tableView: UITableView) -> Int {
        let loadingOrErrorSection = viewModel.searchLoadState.current.canLoadMore ? 1 : 0
        return 1 + loadingOrErrorSection
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == loadingIndexPath.section {
            return 1
        }
        
        return viewModel.numberOfSearchResults
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else {fatalError()}
        
        if indexPath == loadingIndexPath {
            let loadingCell: LoadingTableViewCell = tableView.dequeueReusableCell()
            return loadingCell
        }
        
        guard let item = viewModel.searchResult(at: indexPath.row) else {
            fatalError()
        }
        
        let cell: ArtistSearchResultCell = tableView.dequeueReusableCell()
        cell.setup(viewModel: item)
        return cell
    }
    

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else {fatalError()}
        
        if let cell = cell as? CellPreloadable{
            cell.preload()
        }
        
        if indexPath == loadingIndexPath {
            viewModel.scrolledToBottom()
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
        if let cell = cell as? CellPreloadable{
            cell.cancelLoad()
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else {fatalError()}
        
        guard indexPath.row < viewModel.numberOfSearchResults else {
//            //is not an artist row
//            if viewModel.loadState.isError {
//                viewModel.retryLoad()
//            }
            return
        }
        viewModel.selectArtist(at: indexPath.row)
    }
}

// MARK: - Search Controller

extension ArtistBrowserViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        //print("updateSearchResults: \(searchController.searchBar.text)")
        
        viewModel?.inputTextChanged(input: searchController.searchBar.text ?? "")
    }
}


// MARK: - ViewModel Observer

extension ArtistBrowserViewController {
    
//
//
//    func onArtistListUpdated() {
//        tableView.reloadData()
//
//        print("onArtistListUpdated")
//    }
    
//    func onItemPreloadCompleted(index: Int, result: Result<Data, Error>) {
//        print("Image load completed \(index)")
//        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ArtistSearchResultCell else {return}
//
//        cell.onImageLoadResult(result: result)
//    }
}
