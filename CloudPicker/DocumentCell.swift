//
//  DocumentCell.swift
//  CloudPicker
//
//  Created by Slawek Kurczewski on 28/02/2020.
//  Copyright © 2020 Slawomir Kurczewski. All rights reserved.
//

import UIKit

class DocumentCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(document: CloudPicker.Document) {
        //self.titleLabel.text = document.fileURL.lastPathComponent
        print("configure cell")
    }

}
