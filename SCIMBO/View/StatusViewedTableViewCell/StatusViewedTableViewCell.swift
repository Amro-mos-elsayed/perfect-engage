//
//  StatusViewedTableViewCell.swift
//  whatsUpStatus
//
//  Created by raguraman on 02/04/18.
//  Copyright © 2018 raguraman. All rights reserved.
//

import UIKit

class StatusViewedTableViewCell: UITableViewCell {

    @IBOutlet weak var statusViewedTime: UILabel!
    @IBOutlet weak var statusViewedDate: UILabel!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var personImg: CustomimageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}
