//
//  MessageDetailHeaderView.swift
//
//
//  Created by MV Anand Casp iOS on 18/08/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class MessageDetailHeaderView: UIView {

    @IBOutlet weak var profile_img: UIImageView!
    @IBOutlet weak var date_lbl: UILabel!
    @IBOutlet weak var name_lbl: UILabel!
    
    required init(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)!
        
        
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
