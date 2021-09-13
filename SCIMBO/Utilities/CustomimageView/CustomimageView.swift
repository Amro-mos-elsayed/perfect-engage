//
//  CustomimageView.swift
//  RideShare Rental
//
//  Created by MV Anand Casp iOS on 06/12/17.
//  Copyright © 2017 RideShare Rental. All rights reserved.
//

import UIKit

class CustomimageView: UIImageView {
    
    override func layoutSubviews() {
        if(isRoundedCorner)
        {
            layer.cornerRadius = self.bounds.size.height/2
        }
    }

  
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var isAddbackgroudColor: Bool = false {
        didSet {
            if(isAddbackgroudColor)
            {
//                self.backgroundColor = Theme.appConfigration.appThemeColour
            }
        }
    }
    @IBInspectable var isRoundedCorner: Bool = false {
        didSet {
            if(isRoundedCorner)
            {
                layer.cornerRadius = self.bounds.size.height/2;
                //self.backgroundColor = .red
                print("heightValue \(self.bounds.size)")
                self.clipsToBounds = true;
            }
        }
    }
    
 
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }

}
