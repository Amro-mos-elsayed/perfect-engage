//
//  ReplyDetailView.swift
//
//
//  Created by MV Anand Casp iOS on 21/08/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
protocol ReplyDetailViewDelegate : class {
    func PassCloseAction()
}

class ReplyDetailView: UIView {
    @IBOutlet weak var user_status_Lbl: UILabel!
    @IBOutlet weak var close_Btn: UIButton!
    @IBOutlet weak var message_Lbl: UILabel!
    @IBOutlet weak var name_Lbl: UILabel!
    @IBOutlet weak var thumbnail_Image: UIImageView!
    weak var Delegate:ReplyDetailViewDelegate?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
     }
    override func awakeFromNib() {
        close_Btn.layer.cornerRadius = close_Btn.frame.size.width/2
        close_Btn.clipsToBounds = true
        close_Btn.addTarget(self, action: #selector(self.CloserReplyDetail), for: .touchUpInside)
        close_Btn.layer.borderColor = UIColor.darkGray.cgColor
        close_Btn.layer.borderWidth = 1.0
        thumbnail_Image.layer.cornerRadius = 5.0
        thumbnail_Image.clipsToBounds = true
        name_Lbl.semanticContentAttribute = .forceLeftToRight
        message_Lbl.semanticContentAttribute = .forceLeftToRight
    }

    @objc func CloserReplyDetail()
    {
        self.Delegate?.PassCloseAction()
    }
}
