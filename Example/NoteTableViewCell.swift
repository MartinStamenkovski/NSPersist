//
//  NoteTableViewCell.swift
//  Example
//
//  Created by Martin Stamenkovski on 2/21/20.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageViewHeart: UIImageView!
    
    var onHeartTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageViewHeart.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onHeartTapped(sender:)))
        self.imageViewHeart.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func onHeartTapped(sender: UIImageView) {
        self.onHeartTapped?()
    }

}
