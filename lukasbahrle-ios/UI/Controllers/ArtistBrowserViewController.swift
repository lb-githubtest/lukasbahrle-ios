//
//  ArtistBrowserViewController.swift
//  lukasbahrle-ios
//
//  Created by Lukas Bahrle Santana on 26/02/2021.
//

import UIKit
import ArtistBrowser

class ArtistBrowserViewController: UITableViewController {

    var viewModel: SearchArtistViewModel? {
        didSet { bind() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.clearsSelectionOnViewWillAppear = false

        guard let viewModel = viewModel else {fatalError("set the vc viewModel")}
        viewModel.inputTextChanged(input: "ja")
    }
    
    private func bind(){
        guard let viewModel = viewModel else {
            fatalError("Set first the vc viewModel")
        }
        
        title = viewModel.title
        viewModel.observer = self
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else {return 0}
        let extraLoadingCell = viewModel.loadState != .none ? 1 : 0
        return viewModel.dataModel.count + extraLoadingCell
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else {fatalError()}
        
        if indexPath.row == viewModel.dataModel.count {
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistSearchResultCell", for: indexPath) as! ArtistSearchResultCell
        cell.configure(artist: viewModel.dataModel[indexPath.row])
        return cell
    }
    

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else {fatalError()}
        
        if indexPath.row == viewModel.dataModel.count {
            // loading cell
            viewModel.scrolledToBottom()
        }
        else{
            viewModel.preloadItem(at: indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else {fatalError()}
        
        if indexPath.row < viewModel.dataModel.count {
            viewModel.cancelItem(at: indexPath.row)
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else {fatalError()}
        
        guard indexPath.row < viewModel.dataModel.count else {
            //is not an artist row
            if viewModel.loadState.isError {
                viewModel.retryLoad()
            }
            return
        }
        viewModel.selectArtist(at: indexPath.row)
    }
}


extension ArtistBrowserViewController: SearchArtistViewModelObserver{
    
    func onLoadingStateChange() {
        print("onLoadingStateChange: \(viewModel?.loadState)")
        
//        guard let viewModel = viewModel, viewModel.loadState != .none else {
//            return
//        }
        
        let indexPath = IndexPath(item: tableView.numberOfRows(inSection: 0) - 1, section: 0)
        tableView.reloadRows(at: [indexPath], with: .fade)
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
