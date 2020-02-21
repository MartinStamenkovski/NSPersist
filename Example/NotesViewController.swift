//
//  NotesViewController.swift
//  Example
//
//  Created by Martin Stamenkovski INS on 2/18/20.
//

import UIKit
import CoreData
import NSPersist

class NotesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSExampleNote> = {
        let notesRequest: NSFetchRequest<NSExampleNote> = NSExampleNote.fetchRequest()
        notesRequest.sortDescriptors = [.init(key: "updatedAt", ascending: false)]
        let controller = NSFetchedResultsController(fetchRequest: notesRequest, managedObjectContext: .main, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editNoteVC = segue.destination as? AddEditNoteTableViewController {
            editNoteVC.note = sender as? NSExampleNote
        }
    }
}

extension NotesViewController: NSFetchedResultsControllerDelegate {
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            break
        default:
            self.tableView.reloadData()
            break
        }
    }
}

extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteTableViewCell", for: indexPath) as! NoteTableViewCell
        let note = fetchedResultsController.object(at: indexPath)
        cell.labelTitle.text = note.title
        if #available(iOS 13.0, *) {
            let image = note.favorite ? UIImage(systemName: "heart.fill") :  UIImage(systemName: "heart")
            cell.imageViewHeart.image = image
        }
        
        cell.onHeartTapped = {
            note.favorite = !note.favorite
            note.save()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let note = fetchedResultsController.object(at: indexPath)
        note.favorite = !note.favorite
        note.save()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let note = fetchedResultsController.object(at: indexPath)
        self.performSegue(withIdentifier: "segueUpdateNote", sender: note)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            fetchedResultsController.object(at: indexPath).delete()
        }
    }
}
