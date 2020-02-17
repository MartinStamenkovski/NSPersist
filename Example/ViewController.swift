//
//  ViewController.swift
//  Example
//
//  Created by Martin Stamenkovski on 2/8/20.
//  Copyright © 2020 Martin Stamenkovski. All rights reserved.
//

import UIKit
import NSPersist

class ViewController: UIViewController {
    
    @IBOutlet weak var tableViewUsers: UITableView!
    
    var users: [NSExampleUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableViewUsers.delegate = self
        self.tableViewUsers.dataSource = self
        
        self.loadUsers()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dogsVC = segue.destination as? DogsTableViewController {
            dogsVC.userName = sender as? String
        }
    }
    
    @IBAction func refreshUsers(_ sender: Any) {
        
        let user = NSExampleUser(context: .main)
        user.name = "Test"
        
        ["Casper", "Doggy", "Max"].forEach { (name) in
            let dog = NSExampleDog(context: .main)
            dog.name = name
            user.addToNsexampledog(dog)
        }
    
        NSPersist.shared.saveContext()
        
        self.loadUsers()
    }
    
    @IBAction func addUserAction(_ sender: Any) {
        self.alertAddUser()
    }
    
    @IBAction func deleteAllAction(_ sender: Any) {
        NSPersist
            .shared
            .request(NSExampleUser.self)
            .deleteAsync { (didDelete) in
                if didDelete {
                    self.loadUsers()
                }
        }
    }
    
    func loadUsers() {
        NSPersist
            .shared
            .request(NSExampleUser.self)
            .getAsync { [weak self] (users) in
                guard let self = self else { return }
                if let users = users {
                    self.users = users
                    self.tableViewUsers.reloadData()
                }
        }
    }
    
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userTableViewCell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        //cell.accessoryType = users[indexPath.row].favorite ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "segueDogs", sender: users[indexPath.row].name)
    }
}

extension ViewController {
    
    func alertAddUser() {
        
        let alert = UIAlertController(title: "Add User", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let user = NSExampleUser(context: .main)
            user.name = alert.textFields?.first?.text
            user.save()
            self.users.append(user)
            self.tableViewUsers.reloadData()
        }
        alert.addAction(addAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
