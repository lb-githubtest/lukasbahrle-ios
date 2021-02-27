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

    var viewModel: SearchArtistViewModel? {
        didSet { bind() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        // self.clearsSelectionOnViewWillAppear = false

    }
    
    private func bind(){
        guard let viewModel = viewModel else {
            fatalError("Set first the vc viewModel")
        }
        viewModel.observer = self
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
}


    
// MARK: - Table view data source

extension ArtistBrowserViewController{

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else {return 0}
        let extraLoadingCell = viewModel.loadState != .none ? 1 : 0
        return viewModel.numberOfArtists + extraLoadingCell
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else {fatalError()}
        
        if indexPath.row == viewModel.numberOfArtists {
            switch viewModel.loadState {
            case .error(let error):
                let errorCell = tableView.dequeueReusableCell(withIdentifier: "ErrorTableViewCell", for: indexPath) as! ErrorTableViewCell
                errorCell.set(model: error)
                return errorCell
            default:
                let loadingCell = tableView.dequeueReusableCell(withIdentifier: "LoadingTableViewCell", for: indexPath) as! LoadingTableViewCell
                return loadingCell
            }
        }
        
        guard let artist = viewModel.artist(at: indexPath.row) else {
            fatalError()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistSearchResultCell", for: indexPath) as! ArtistSearchResultCell
        cell.configure(artist: artist)
        return cell
    }
    

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else {fatalError()}
        
        if indexPath.row == viewModel.numberOfArtists {
            // loading cell
            viewModel.scrolledToBottom()
        }
        else{
            viewModel.preloadItem(at: indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else {fatalError()}
        
        if indexPath.row < viewModel.numberOfArtists {
            viewModel.cancelItem(at: indexPath.row)
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else {fatalError()}
        
        guard indexPath.row < viewModel.numberOfArtists else {
            //is not an artist row
            if viewModel.loadState.isError {
                viewModel.retryLoad()
            }
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

extension ArtistBrowserViewController: SearchArtistViewModelObserver{
    
    func onLoadingStateChange(value: LoadState, previous: LoadState) {
        print("onLoadingStateChange: \(viewModel?.loadState)")
        
//        guard let viewModel = viewModel, viewModel.loadState != .none else {
//            return
//        }
        
//        let loadingCellStateChanged = (value.isError && !previous.isError) || (!value.isError && previous.isError)
//
//
//        if loadingCellStateChanged, tableView.numberOfRows(inSection: 0) > 0{
//
//            let indexPath = IndexPath(item: tableView.numberOfRows(inSection: 0) - 1, section: 0)
//            tableView.reloadRows(at: [indexPath], with: .fade)
//        }
    }
    
    func onArtistListUpdated() {
        tableView.reloadData()
        
        print("onArtistListUpdated")
    }
    
    func onItemPreloadCompleted(index: Int, result: Result<Data, Error>) {
        print("Image load completed \(index)")
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ArtistSearchResultCell else {return}
        
        cell.onImageLoadResult(result: result)
    }
}
