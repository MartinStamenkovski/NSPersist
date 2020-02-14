//
//  FavoritesTableViewController.swift
//  CoreDataStack
//
//  Created by Martin Stamenkovski on 2/9/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import UIKit
import NSPersist

class FavoritesTableViewController: UITableViewController {
    
    var users: [NSExampleUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadUsers()
    }
    
    @IBAction func removeFavoritesAction(_ sender: Any) {
        self.updateAllUsers()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoritesCell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }
    
    func loadUsers() {
        NSPersist
            .shared
            .request(NSExampleUser.self) { (request) in
                request.predicate = NSPredicate(format: "favorite == true")
        }.getAsync {[weak self] (users) in
            guard let self = self else { return }
            self.users = users!
            self.tableView.reloadData()
        }
    }
    
    
    
    func updateAllUsers() {
        NSPersist.shared.update(NSExampleUser.self) { (batch) in
            batch.predicate = NSPredicate(format: "favorite == true")
            batch.propertiesToUpdate = ["favorite" : false]
        }.updateBatchAsync { didUpdate in
            if didUpdate {
                self.loadUsers()
            }
        }
    }
    
}
