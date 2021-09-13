//
//  MyStatusListTableViewCell.swift
//  whatsUpStatus
//
//  Created by raguraman on 02/04/18.
//  Copyright © 2018 raguraman. All rights reserved.
//

import UIKit

protocol MyStatusListTableViewCellDelegate : class {
    func viewButtonPressed(in Index: IndexPath)
    func forwardButtonPressed(in Index: IndexPath)
}

class MyStatusListTableViewCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var userImg: CustomimageView!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var viewsButton: UIButton!
    @IBOutlet weak var viewsImg: UIImageView!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var updatedTimeLabel: UILabel!
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var bottomHalfLineView: UIView!
    
    weak var delegate:MyStatusListTableViewCellDelegate?
    var indexPath = IndexPath()
    
    @IBAction func didClickForwardButton(_ sender: UIButton) {
        delegate?.forwardButtonPressed(in: indexPath)
    }
    
    @IBAction func didClickViewButton(_ sender: UIButton) {
        delegate?.viewButtonPressed(in: indexPath)
    }
    
    
}
