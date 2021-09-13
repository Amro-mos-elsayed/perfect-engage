//
//  DetailtableViewCell.swift

//
//  Created by MV Anand Casp iOS on 06/04/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit

class DetailtableViewCell: UITableViewCell {
    @IBOutlet weak var audicallBtn: CustomButton!
    @IBOutlet weak var videocallBtn: CustomButton!
    @IBOutlet weak var msgBtn: CustomButton!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    
    @IBOutlet weak var groupName_TxtField: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
