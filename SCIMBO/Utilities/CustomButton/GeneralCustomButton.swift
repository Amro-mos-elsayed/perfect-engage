//
//  CustomButton.swift
//  RideShare Rental
//
//  Created by MV Anand Casp iOS on 05/12/17.
//  Copyright © 2017 RideShare Rental. All rights reserved.
//

import UIKit
enum customAlignment: String {
    case left = "left" // lowercase to make it case-insensitive
    case right = "right"
    case center = "center"
    case justify = "justify"
    case none = "none"
}
@objc enum Shape: Int {
    case None
    case Rectangle
    case Triangle
    case Circle
    
    init(named shapeName: String) {
        switch shapeName.lowercased() {
        case "rectangle": self = .Rectangle
        case "triangle": self = .Triangle
        case "circle": self = .Circle
        default: self = .None
        }
    }
}



class GeneralCustomButton: UIButton {
    
    required init(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)!
//         if(self.tag == 10)
//        {
//
//          self.titleLabel?.font=UIFont(name: Theme.fontName.Regular, size: (self.titleLabel?.font.pointSize)!)
//        }
//        else if(self.tag == 11)
//        {
//            self.titleLabel?.font=UIFont(name: Theme.fontName.Bold, size: (self.titleLabel?.font.pointSize)!)
//        }
//        else if(self.tag == 12)
//        {
//            self.titleLabel?.font=UIFont(name: Theme.fontName.SemiBold, size: (self.titleLabel?.font.pointSize)!)
//        }
//        else if(self.tag == 13)
//        {
//            self.titleLabel?.font=UIFont(name: Theme.fontName.Heavy, size: (self.titleLabel?.font.pointSize)!)
//        }
//
//        else if(self.tag == 14)
//        {
//            self.titleLabel?.font=UIFont(name: Theme.fontName.Light, size: (self.titleLabel?.font.pointSize)!)
//        }
        
    }
     var alignmentname = customAlignment.none // default shape

     @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    override func layoutSubviews() {
        if isRoundedCorner{
            layer.cornerRadius = self.frame.size.height/2;
        }
    }
    
    @IBInspectable var isAddTextColor: Bool = false {
        didSet {
            if(isAddTextColor)
            {
//                self.setTitleColor(Theme.appConfigration.appThemeColour, for: .normal)
            }
        }
    }

    
    
    @IBInspectable var isAddShadow: Bool = false {
        didSet {
            if(isRoundedCorner)
            {
                let shadowLayer = UIView(frame: self.frame)
                shadowLayer.backgroundColor = UIColor.clear
                shadowLayer.layer.shadowColor = UIColor.darkGray.cgColor
                shadowLayer.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: self.cornerRadius).cgPath
                shadowLayer.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
                shadowLayer.layer.shadowOpacity = 0.5
                shadowLayer.layer.shadowRadius = 1
                shadowLayer.layer.masksToBounds = true
                shadowLayer.clipsToBounds = false
                self.superview?.addSubview(shadowLayer)
                self.superview?.bringSubviewToFront(self)
            }
        }
    }


    
    @IBInspectable var Alignment: String? {
        willSet {
            // Ensure user enters a valid shape while making it lowercase.
            // Ignore input if not valid.
            if let newShape = customAlignment(rawValue: newValue?.lowercased() ?? "") {
                alignmentname = newShape
                if(alignmentname == customAlignment.right)
                {
                    self.titleLabel?.textAlignment = .right
                 }
               else if(alignmentname == customAlignment.left)
                {
                    self.titleLabel?.textAlignment = .left
                }
               else if(alignmentname == customAlignment.justify)
                {
                    self.titleLabel?.textAlignment = .justified
                }
               else if(alignmentname == customAlignment.none)
                {
                    self.titleLabel?.textAlignment = .natural
                }
               else if(alignmentname == customAlignment.center)
                {
                    self.titleLabel?.textAlignment = .center
                }



            }
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
                layer.cornerRadius = self.frame.size.height/2;
                self.clipsToBounds = true;
            }
         }
    }
    
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
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
