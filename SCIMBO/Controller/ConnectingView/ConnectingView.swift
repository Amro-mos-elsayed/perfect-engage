//
//  ConnectingView.swift
//  SCIMBO
//
//  Created by Nirmal's Mac Mini on 01/07/19.
//  Copyright © 2019 CASPERON. All rights reserved.
//

import UIKit

class ConnectingView: UIView {

    @IBOutlet var hint_lbl:UILabel!
    @IBOutlet var activity_view:UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadFromNibNamed("ConnectingView")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        
        hint_lbl.text = "connecting.."
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }

    
}
