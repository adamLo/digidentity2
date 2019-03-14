//
//  MainViewController.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 14/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIScrollViewDelegate {

    @IBOutlet weak var itemTableView: UITableView!
    
    @IBOutlet var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let tableRowHeightRatio: CGFloat = 0.15
    private let tableRowMinHeight: CGFloat = 44.0
    
    private var isFetchingData = false
    
    // MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
        
        toggleActivity(visible: false, footer: false)
        
        loadItems()
        
        isFetchingData = true
        Network.shared.fetchItems {[weak self] (_, error) in
            
            guard let _self = self else {return}
            
            _self.isFetchingData = false
            
            if let _error = error {
                _self.show(error: _error)
            }
        }
    }
    
    // MARK: - UI customization
    
    private func setupUI() {
        
        title = NSLocalizedString("Digidentity", comment: "Main screen title")
        
        setupTableView()
    }
    
    private func setupTableView() {
        
        itemTableView.separatorStyle = .none
        itemTableView.tableFooterView = UIView()
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Fetching items", comment: "HUD title when fetching items"), attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)])
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.addTarget(self, action: #selector(refreshInitiated(_:)), for: .valueChanged)
        itemTableView.refreshControl = refreshControl
    }
    
    private func toggleActivity(visible: Bool, footer: Bool) {
        
        if visible && itemTableView.tableFooterView != activityView && itemTableView.tableHeaderView != activityView {
            
            if !activityIndicator.isAnimating {
                activityIndicator.startAnimating()
            }
            
            activityIndicator.isHidden = false
            activityView.isHidden = false
            
            if footer {
                itemTableView.tableFooterView?.removeFromSuperview()
                itemTableView.tableFooterView = activityView
            }
            else {
                itemTableView.tableHeaderView?.removeFromSuperview()
                itemTableView.tableHeaderView = activityView
            }
        }
        else if !visible && (itemTableView.tableFooterView == activityView || itemTableView.tableHeaderView == activityView) {
            
            if activityIndicator.isAnimating {
                activityIndicator.stopAnimating()
            }
            
            activityIndicator.isHidden = true
            activityView.isHidden = true
            
            itemTableView.tableFooterView?.removeFromSuperview()
            itemTableView.tableFooterView = UIView()
            
            itemTableView.tableHeaderView?.removeFromSuperview()
            itemTableView.tableHeaderView = nil
        }
    }
    
    private func show(error: Error) {
        
        let alert = UIAlertController(title: NSLocalizedString("Error fetching items", comment: "Items fetch failure dialog title"), message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Button title"), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let items = itemsFetchedResultsController?.fetchedObjects {
            return items.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let items = itemsFetchedResultsController?.fetchedObjects as? [Item], items.count > indexPath.row, let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reuseId, for: indexPath) as? ItemCell {
            
            let item = items[indexPath.row]
            cell.setup(with: item)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return max(tableView.bounds.size.height * tableRowHeightRatio, tableRowMinHeight)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if !isFetchingData, let items = itemsFetchedResultsController?.fetchedObjects as? [Item], !items.isEmpty {
            
            var sinceId: String?
            var beforeId: String?
            
            if indexPath.row == 0 && didUserScrollSinceFetch, let _sinceId = items[0].identifier {
                
                sinceId = _sinceId
            }
            else if items.count == indexPath.row + 1, let _beforeId = items[indexPath.row].identifier {
                
                beforeId = _beforeId
            }
            
            if beforeId != nil || sinceId != nil {
                
                toggleActivity(visible: true, footer: beforeId != nil)
                isFetchingData = true
                
                Network.shared.fetchItems(since: sinceId, before: beforeId) {[weak self] (_, error) in
                    
                    guard let _self = self else {return}
                    
                    _self.toggleActivity(visible: false, footer: false)
                    _self.isFetchingData = false
                    _self.didUserScrollSinceFetch = false
                    
                    if let _error = error {
                        _self.show(error: _error)
                    }
                }
            }
        }
        else {
            
            toggleActivity(visible: false, footer: false)
        }
    }
    
    // MARK: - ScrollView
    
    private var didUserScrollSinceFetch = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !isFetchingData && !didUserScrollSinceFetch {
            didUserScrollSinceFetch = true
        }
    }
    
    // MARK: - Core Data
    
    private var itemsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?

    private func loadItems() {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Item.entityName)
        let sortOrder = NSSortDescriptor(key: Item.identifier, ascending: false)
        request.sortDescriptors = [sortOrder]
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Persistence.shared.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        itemsFetchedResultsController = controller
        
        do {
        
            try controller.performFetch()
        }
        catch let error {
            
            // FIXME: Display error
            print("Error fetching items: \(error)")
        }
    }
    
    private var changesStarted = 0
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        changesStarted += 1
        
        if changesStarted == 1 {
            itemTableView.beginUpdates()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
            switch type {
                
            case .insert:
                if let _indexPath = newIndexPath {
                    self.itemTableView.insertRows(at: [_indexPath], with: .top)
                }
                
            case .delete:
                if let _indexPath = indexPath {
                    self.itemTableView.deleteRows(at: [_indexPath], with: .none)
                }
                
            case .update:
                if let _indexPath = indexPath {
                    self.itemTableView.reloadRows(at: [_indexPath], with: .none)
                }
                
            case .move:
                if let _indexPath = indexPath {
                    self.itemTableView.deleteRows(at: [_indexPath], with: .none)
                }
                if let _indexPath = newIndexPath {
                    self.itemTableView.insertRows(at: [_indexPath], with: .none)
                }
            }

    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        changesStarted = max(changesStarted - 1, 0)
        
        if changesStarted == 0 {
            itemTableView.endUpdates()
        }
    }
    
    // MARK: - Actions
    
    @objc func refreshInitiated(_ sender: Any) {
        
        if !isFetchingData {

            var sinceId: String?
            if let firstItem = itemsFetchedResultsController?.fetchedObjects?.first as? Item, let itemId = firstItem.identifier {
                sinceId = itemId
            }
            
            isFetchingData = true
            
            Network.shared.fetchItems(since: sinceId) {[weak self] (_, error) in
                
                guard let _self = self else {return}
                
                _self.isFetchingData = false
                
                if let _error = error {
                    _self.show(error: _error)
                }
                
                if let refreshControl = _self.itemTableView.refreshControl, refreshControl.isRefreshing {
                    refreshControl.endRefreshing()
                }
            }
        }
    }
    
}
