//
//  StatusListTableViewCell.swift
//
//
//  Created by CASPERON on 14/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class StatusListTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator_View: UIActivityIndicatorView!
    @IBOutlet weak var tickImage_View: UIImageView!
    @IBOutlet weak var statusLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
