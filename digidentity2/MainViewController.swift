//
//  MainViewController.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 14/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var itemTableView: UITableView!
    
    private let tableRowHeightRatio: CGFloat = 0.15
    private let tableRowMinHeight: CGFloat = 44.0
    
    // MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
        
        loadItems()
        Network.shared.fetchItems { (success, error) in
            print("Success: \(success), error: \(error)")
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
            itemTableView.reloadData()
        }
        catch let error {
            
            // FIXME: Display error
            print("Error fetching items: \(error)")
        }
    }
    
    private var didBeginChanges = false
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if !didBeginChanges {
            didBeginChanges = true
            itemTableView.beginUpdates()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        DispatchQueue.main.async {
            
            if self.itemTableView != nil {
                
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
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        itemTableView.endUpdates()
        didBeginChanges = false
    }
    
}
