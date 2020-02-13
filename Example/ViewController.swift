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

    var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewUsers.delegate = self
        self.tableViewUsers.dataSource = self

        self.loadUsers()
    }

    @available(iOS 13, *)
    @IBAction func refreshUsers(_ sender: Any) {

        let users = [
            [
                "name" : "Test",
                "favorite": false
            ],
            [
                "name" : "Another user",
                "favorite": true
            ]
        ]

        NSPersist.shared.insertAsync(User.self, values: users) { didInsert in
            self.loadUsers()
        }
    }

    @IBAction func addUserAction(_ sender: Any) {
        self.alertAddUser()
    }

    @IBAction func deleteAllAction(_ sender: Any) {
        NSPersist.shared.request(User.self) { (request) in
            //request.predicate = NSPredicate(format: "name = %@", "s")
        }.deleteAsync { (didDelete) in
            if didDelete {
                self.loadUsers()
            }
        }

    }

    func loadUsers() {
        NSPersist
            .shared
            .request(User.self)
            .getAsync { [weak self] (users) in
                guard let self = self else { return }
                self.users = users
                self.tableViewUsers.reloadData()
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
        cell.accessoryType = users[indexPath.row].favorite ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        user.favorite = !user.favorite
        user.save()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        // Do any additional setup after loading the view.
    }
}

extension ViewController {

    func alertAddUser() {

        let alert = UIAlertController(title: "Add User", message: nil, preferredStyle: .alert)

        alert.addTextField { (textField) in

        }
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let user = User(context: .main)
            user.name = alert.textFields?.first?.text
            user.save()

            self.loadUsers()
        }
        alert.addAction(addAction)

        self.present(alert, animated: true, completion: nil)
    }

}
