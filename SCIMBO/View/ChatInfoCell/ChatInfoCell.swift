//
//  ChatInfoCell.swift
//
//
//  Created by Casp iOS on 27/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class ChatInfoCell: UITableViewCell {

    @IBOutlet weak var date_lbl: CustomBtn!
    @IBOutlet weak var Info_Btn: CustomBtn!
    override func awakeFromNib() {
        super.awakeFromNib()
        Info_Btn.layer.cornerRadius=3.0
        Info_Btn.clipsToBounds = true
        date_lbl.layer.cornerRadius=5.0
        date_lbl.clipsToBounds = true

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
