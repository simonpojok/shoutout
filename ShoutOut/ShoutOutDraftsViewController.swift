//
//  ViewController.swift
//  ShoutOut

import UIKit
import CoreData

class ShoutOutDraftsViewController: UIViewController,
									UITableViewDataSource,
									UITableViewDelegate,
                                    ManagedObjectContextDependentType,
                                    NSFetchedResultsControllerDelegate
{
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<ShoutOut>!

	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        configureFetchedResultsController()
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let alertController = UIAlertController(
                title: "Loading ShoutOuts Failed",
                message: "There was a problem loading the list of ShoutOuts drafts. Please try again.",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil
            )
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
	}
    
    func configureFetchedResultsController() {
        let shoutOutFetchedRequest = NSFetchRequest<ShoutOut>(entityName: ShoutOut.entityName)
        let lastNameSortDescriptor = NSSortDescriptor(key: #keyPath(ShoutOut.toEmployee.lastName), ascending: true)
        let firstNameSortDescriptor = NSSortDescriptor(key: #keyPath(ShoutOut.toEmployee.lastName), ascending:  true)
        shoutOutFetchedRequest.sortDescriptors = [lastNameSortDescriptor, firstNameSortDescriptor]
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: shoutOutFetchedRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.fetchedResultsController.delegate = self
    }
	
	// MARK: TableView Data Source methods
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return nil
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections {
            return sections[section].numberOfObjects
        }
        return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath)
        
        let shoutOut = self.fetchedResultsController.object(at: indexPath)
		
        cell.textLabel?.text = "\(shoutOut.toEmployee.firstName) \(shoutOut.toEmployee.lastName)"
        cell.detailTextLabel?.text = "\(shoutOut.shoutCategory)"
		
		return cell
	}
	
	// MARK: TableView Delegate methods
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "shoutOutDetails":
            let destinationVC = segue.destination as! ShoutOutDetailsViewController
            destinationVC.managedObjectContext = self.managedObjectContext
            
            let selectedindexPath = self.tableView.indexPathForSelectedRow!
            let selectedShoutOut = self.fetchedResultsController.object(at: selectedindexPath)
            destinationVC.shoutOut = selectedShoutOut
        case "addShoutOut":
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.viewControllers[0] as! ShoutOutEditorViewController
            destinationVC.managedObjectContext = self.managedObjectContext
        default:
            break
        }
	}
    
    // MARK: NSFetchedResultsControllerDeligate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let inserIndexPath = newIndexPath {
                self.tableView.insertRows(at: [inserIndexPath], with: .fade)
            }
        case .delete:
            if let deletedIndexPath = indexPath {
                self.tableView.deleteRows(at: [deletedIndexPath], with: .fade)
            }
        case .move:
            
            if let deletedIndexPath = indexPath {
                self.tableView.deleteRows(at: [deletedIndexPath], with: .fade)
            }
            
            if let inserIndexPath = newIndexPath {
                self.tableView.insertRows(at: [inserIndexPath], with: .fade)
            }
        case .update:
            if let updateIndexPath = indexPath {
                let cell = self.tableView.cellForRow(at: updateIndexPath)
                let updatedShoutOut = self.fetchedResultsController.object(at: updateIndexPath)
                cell?.textLabel?.text = "\(updatedShoutOut.toEmployee.firstName) \(updatedShoutOut.toEmployee.lastName)"
                cell?.detailTextLabel?.text = updatedShoutOut.message
            }
        @unknown default:
            print("Error")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}
