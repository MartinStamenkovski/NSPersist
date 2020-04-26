//
//  FavoritesTableViewController.swift
//  Example
//
//  Created by Martin Stamenkovski on 2/21/20.
//
import UIKit
import NSPersist

class FavoritesTableViewController: UITableViewController {

    var favorites: [NSExampleNote] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fetchFavorites()
    }
    
    func fetchFavorites() {
        NSPersist.shared.fetch(NSExampleNote.self, completion: { (request) in
            request.predicate = NSPredicate(format: "favorite = %d", true)
            request.sortDescriptors = [.init(key: "createdAt", ascending: false)]
        }).getAsync { [weak self] notes in
            if let notes = notes {
                self?.favorites = notes
                self?.tableView.reloadData()
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteTableViewCell", for: indexPath)
        cell.textLabel?.text = favorites[indexPath.row].title
        return cell
    }

}
