//
//  MyStatusTableViewCell.swift
//  WhatsAppStatus
//
//  Created by raguraman on 29/03/18.
//  Copyright © 2018 raguraman. All rights reserved.
//

import UIKit
protocol MyStatusTableViewCellDelegate : class {
    func didClickCamera()
    func didClickText()
}

class MyStatusTableViewCell: UITableViewCell {
    
    override func layoutSubviews() {
        
    }
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var textStatusButton: UIButton!
    @IBOutlet weak var statusIndicatorView: StatusIndicatorView!
    @IBOutlet weak var plusIcon: UIImageView!
    @IBOutlet weak var currentUserImg: UIImageView!
    
    @IBOutlet weak var cameraStatusButton: UIButton!
    
    @IBOutlet weak var addToMyStatusLabel: UILabel!
    
    @IBOutlet weak var myStatusLabel: UILabel!
    
    weak var delegate:MyStatusTableViewCellDelegate?
    
    @IBAction func didClickCameraButton(_ sender: UIButton) {
        delegate?.didClickCamera()
    }
    
    @IBAction func didClickEditButton(_ sender: UIButton) {
        delegate?.didClickText()
    }    
}
