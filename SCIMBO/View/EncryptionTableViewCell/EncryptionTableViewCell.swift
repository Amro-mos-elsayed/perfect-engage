//
//  EncryptionTableViewCell.swift
//
//  Created by CasperoniOS on 14/06/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit

class EncryptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var wrapperview: UIView!
    @IBOutlet weak var msgLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        wrapperview.layer.cornerRadius = 5.0
        wrapperview.clipsToBounds = true
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

