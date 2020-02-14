//
//  DogsTableViewController.swift
//  Example
//
//  Created by Martin Stamenkovski INS on 2/14/20.
//

import UIKit
import NSPersist

class DogsTableViewController: UITableViewController {

    var userName: String!
    
    var dogs: [NSExampleDog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dogs = NSPersist.shared.request(NSExampleDog.self) { (request) in
            request.predicate = NSPredicate(format: "nsexampleuser.name = %@", self.userName)
        }.get()
        
        self.tableView.reloadData()
    }

   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dogs.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dogTableViewCell", for: indexPath)
        cell.textLabel?.text = dogs[indexPath.row].name
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dogs[indexPath.row].delete { success in
                if success {
                    self.dogs.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}
