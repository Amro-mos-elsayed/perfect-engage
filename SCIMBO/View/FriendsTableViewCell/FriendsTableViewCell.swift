//
//  FriendsTableViewCell.swift
//  WhatsAppStatus
//
//  Created by raguraman on 29/03/18.
//  Copyright © 2018 raguraman. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statusTextLabel: UILabel!
    @IBOutlet weak var friendsImg: UIImageView!
    
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomHalfLineView: UIView!
    
    @IBOutlet weak var blurview: UIView!

    @IBOutlet weak var friendStatusIndicator: StatusIndicatorView!
    
    @IBOutlet weak var friendName: UILabel!
    
    @IBOutlet weak var statusUpdatedLabel: UILabel!
}
