//
//  MediaCollectionViewCell.swift
//
//
//  Created by Casp iOS on 07/04/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class MediaCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var play_img: UIImageView!
    @IBOutlet weak var MediaImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        MediaImageView.layer.cornerRadius = 3.0
        MediaImageView.clipsToBounds = true
        // Initialization code
    }

}
