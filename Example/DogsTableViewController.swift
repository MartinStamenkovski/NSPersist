//
//  DogsTableViewController.swift
//  Example
//
//  Created by Martin Stamenkovski INS on 2/14/20.
//

import UIKit
import NSPersist

class DogsTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var constraintUndoBottom: NSLayoutConstraint!
    var userName: String!
    
    var dogs: [NSExampleDog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.loadDogs()
        
    }
    
    func loadDogs() {
        self.dogs = NSPersist.shared.request(NSExampleDog.self) { (request) in
            request.predicate = NSPredicate(format: "nsexampleuser.name = %@", self.userName)
        }.get()
        
        self.tableView.reloadData()
    }
    
    @IBAction func undoAction(_ sender: Any) {
        
        NSPersist.undoManager.undo()
        NSPersist.undoManager.levelsOfUndo -= 1
        NSPersist.shared.saveContext()
        self.loadDogs()
        
        if NSPersist.undoManager.levelsOfUndo == 0 {
            self.constraintUndoBottom.constant = -200
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        
    }
}

extension DogsTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dogs.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dogTableViewCell", for: indexPath)
        cell.textLabel?.text = dogs[indexPath.row].name
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dogs[indexPath.row].delete { success in
                if success {
                    NSPersist.undoManager.levelsOfUndo += 1
                    self.dogs.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.constraintUndoBottom.constant = 12
                    UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
}
