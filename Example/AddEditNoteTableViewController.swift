//
//  AddEditNoteTableViewController.swift
//  Example
//
//  Created by Martin Stamenkovski INS on 2/18/20.
//

import UIKit

class AddEditNoteTableViewController: UITableViewController {
    
    @IBOutlet weak var textFieldTitle: UITextField!
    @IBOutlet weak var textFieldNote: UITextField!
    
    var note: NSExampleNote?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let note = note {
            self.textFieldTitle.text = note.title
            self.textFieldNote.text = note.body
            self.navigationItem.title = "Edit Note"
        }
    }
    
    
    @IBAction func doneAction(_ sender: Any) {
        guard !(textFieldTitle.text?.isEmpty ?? true) else { return }
        guard !(textFieldNote.text?.isEmpty ?? true) else { return }
        
        guard !updateNote() else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        let note = NSExampleNote(context: .main)
        note.title = textFieldTitle.text
        note.body = textFieldNote.text
        note.createdAt = Date()
        note.updatedAt = Date()
        note.save()
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension AddEditNoteTableViewController {
    
    private func updateNote() -> Bool {
        if let note = note {
            note.title = textFieldTitle.text
            note.body = textFieldNote.text
            note.updatedAt = Date()
            note.save()
            return true
        }
        return false
    }
}
