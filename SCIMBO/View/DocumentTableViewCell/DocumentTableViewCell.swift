//
//  DocumentTableViewCell.swift
//
//
//  Created by MV Anand Casp iOS on 02/08/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class DocumentTableViewCell: UITableViewCell {

    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var document_nameLbl: UILabel!
    @IBOutlet weak var doc_img: UIImageView!
    @IBOutlet weak var wrapperview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        wrapperview.layer.borderColor = UIColor.lightGray.cgColor
        wrapperview.layer.borderWidth = 1.0
        wrapperview.layer.cornerRadius = 3.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
