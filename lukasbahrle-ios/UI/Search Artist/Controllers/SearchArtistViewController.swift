//
//  ArtistBrowserViewController.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 26/02/2021.
//

import UIKit
import ArtistBrowser

class SearchArtistViewController: UIViewController {
    private let tableView = UITableView(frame: .zero)
    private var searchController: UISearchController?

    var viewModel: SearchArtistViewModel
    
    private enum Section: Int{
        case results = 0
        case loading
    }
    
    private var loadingIndexPath: IndexPath {
        return IndexPath(row: 0, section: Section.loading.rawValue)
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
    
    init(viewModel: SearchArtistViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        bind()
    }
    
    private func bind(){
        self.title = viewModel.title
        
        viewModel.searchLoadState.valueChanged = { [weak self] state in
            guard let self = self else {return}
            switch state {
            case .loading:
                self.tableView.reloadData()
            case .loaded(canLoadMore:let canLoadMore, countAdded: let count):
                self.onSearchResultsLoaded(canLoadMore: canLoadMore, countAdded: count)
            case .failed:
                self.tableView.reloadRows(at: [self.loadingIndexPath], with: .automatic)
            default:
                break
            }
        }
        
        viewModel.onSearchResultsCollectionUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
    }
 
    private func configure(){
        self.view.backgroundColor = Appearance.backgroundColor
        self.title = viewModel.title
        self.definesPresentationContext = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        configureTableView()
        configureSearchView()
    }
    
    private func configureTableView(){
        view.addSubview(tableView)
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        registerCells()
    }
    
    private func configureSearchView(){
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.placeholder = viewModel.searchPlaceholder
        searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    private func registerCells(){
        tableView.register(ArtistSearchResultCell.self)
        tableView.register(LoadingTableViewCell.self)
        tableView.register(ErrorTableViewCell.self)
    }
    
    private func onSearchResultsLoaded(canLoadMore: Bool, countAdded: Int){
        let startIndex = viewModel.numberOfSearchResults - countAdded
        let endIndex = viewModel.numberOfSearchResults - 1
        var indexPaths: [IndexPath] = []
        
        tableView.performBatchUpdates {
            if endIndex >= startIndex, endIndex >= 0, startIndex >= 0 {
               for index in startIndex...endIndex{
                   indexPaths.append(IndexPath(row: index, section: Section.results.rawValue))
               }
                tableView.insertRows(at: indexPaths, with: .automatic)
           }
            
            if !canLoadMore {
                tableView.deleteSections(IndexSet([Section.loading.rawValue]), with: .automatic)

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

extension SearchArtistViewController: UITableViewDataSource, UITableViewDelegate{

    func numberOfSections(in tableView: UITableView) -> Int {
        let loadingOrErrorSection = viewModel.searchLoadState.current.canLoadMore ? 1 : 0
        return 1 + loadingOrErrorSection
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == loadingIndexPath.section {
            return 1
        }
        return viewModel.numberOfSearchResults
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath == loadingIndexPath {
            return getLoadingCell()
        }
        
        guard let item = viewModel.searchResult(at: indexPath.row) else {
            fatalError()
        }
        
        let cell: ArtistSearchResultCell = tableView.dequeueReusableCell()
        cell.setup(viewModel: item)
        return cell
    }
    
    private func getLoadingCell() -> UITableViewCell{
        if viewModel.searchLoadState.current == .failed {
            let errorCell: ErrorTableViewCell = tableView.dequeueReusableCell()
            errorCell.setup(viewModel: viewModel.errorViewModel)
            return errorCell
        }
        else{
            let loadingCell: LoadingTableViewCell = tableView.dequeueReusableCell()
            return loadingCell
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? CellPreloadable{
            cell.preload()
        }
        
        if indexPath == loadingIndexPath {
            viewModel.scrolledToBottom()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? CellPreloadable{
            cell.cancelLoad()
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == loadingIndexPath {
            viewModel.loadingCellTap()
        }
        else if indexPath.section == Section.results.rawValue {
            tableView.deselectRow(at: indexPath, animated: true)
            viewModel.selectArtist(at: indexPath.row)
        }
    }
}

// MARK: - Search Controller

extension SearchArtistViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.inputTextChanged(input: searchController.searchBar.text ?? "")
    }
}
