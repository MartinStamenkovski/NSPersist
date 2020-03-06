//
//  FavoritesTableViewController.swift
//  Example
//
//  Created by Martin Stamenkovski on 2/21/20.
//
import UIKit
#if os(iOS)
import NSPersist
#endif
class FavoritesTableViewController: UITableViewController {

    var favorites: [NSExampleNote] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fetchFavorites()
    }
    
    func fetchFavorites() {
        self.favorites = NSPersist.shared.request(NSExampleNote.self, completion: { (request) in
            request.predicate = NSPredicate(format: "favorite = %d", true)
            request.sortDescriptors = [.init(key: "createdAt", ascending: false)]
        }).get()
        
        self.tableView.reloadData()
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
