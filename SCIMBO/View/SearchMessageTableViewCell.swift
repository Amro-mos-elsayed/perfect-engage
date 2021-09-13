//
//  SearchMessageTableViewCell.swift
//
//
//  Created by PremMac on 29/09/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class SearchMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image_button: UIButton!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
