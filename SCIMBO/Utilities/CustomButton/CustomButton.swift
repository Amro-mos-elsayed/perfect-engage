//
//  CustomButton.swift
//  Plumbal
//
//  Created by Casperon Tech on 07/11/15.
//  Copyright © 2015 Casperon Tech. All rights reserved.
//

import UIKit

//MARK: - Custom Button


let PlumberThemeColor = UIColor(red: 68/255.0, green: 85/255.0, blue: 165/255.0, alpha: 1)
let PlumberLightThemeColor = UIColor(red: 248/255.0, green: 130/255.0, blue: 4/255.0, alpha: 0.75)
let PlumberBackGroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)
let PlumberLightGrayColor = UIColor(red: 225/255.0, green: 225/255.0, blue: 225/255.0, alpha: 1)
let PlumberGreenColor = UIColor(red: 0/255.0, green: 126/255.0, blue: 112/255.0, alpha: 1)
let PlumberBlueColor = UIColor(red: 40/255.0, green: 203/255.0, blue: 249/255.0, alpha: 1)
let plumberPlaceHolderColor = UIColor(red:213.0/255.0, green:212.0/255.0, blue:210.0/255.0, alpha: 1.0)
let plumberwalkThroughTextColor = UIColor(red:34.0/255.0, green:34.0/255.0, blue:34.0/255.0, alpha: 1.0)


let PlumberSmallFont =  UIFont.systemFont(ofSize: 15)
let PlumberlargeBoldFont = UIFont.boldSystemFont(ofSize: 15)
let PlumberMediumFont = UIFont.systemFont(ofSize: 14)
let PlumberLargeFont = UIFont.systemFont(ofSize: 16)
let PlumberSmallBoldFont = UIFont.boldSystemFont(ofSize: 14)
let PlumberMediumBoldFont = UIFont.boldSystemFont(ofSize: 14)
let PlumberLargeBoldFont = UIFont.boldSystemFont(ofSize: 16)
let PlumberMediumPoppinsFont = UIFont.systemFont(ofSize: 22)
let PlumberMediumPoppinsFontButton = UIFont.systemFont(ofSize: 17)

let PlumberRegularPoppinsFont = UIFont.systemFont(ofSize: 12)
let PlumberBoldPoppinsFont = UIFont.boldSystemFont(ofSize: 20)


class CustomButton: UIButton {
    enum customAlignment: String {
        case left = "left" // lowercase to make it case-insensitive
        case right = "right"
        case center = "center"
        case justify = "justify"
        case none = "none"
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
         self.backgroundColor = CustomColor.sharedInstance.themeColor
        self.setTitleColor(UIColor.white, for: UIControl.State())
        self.titleLabel?.font = PlumberLargeFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

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
    
    
    
 
        var alignmentname = customAlignment.none // default shape
        
        @IBInspectable var cornerRadius: CGFloat = 0 {
            didSet {
                layer.cornerRadius = cornerRadius
                layer.masksToBounds = cornerRadius > 0
            }
        }
        
        @IBInspectable var isAddTextColor: Bool = false {
            didSet {
                if(isAddTextColor)
                {
                    self.setTitleColor(CustomColor.sharedInstance.themeColor, for: .normal)
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
                    self.backgroundColor = CustomColor.sharedInstance.themeColor
                }
            }
        }
        
        
        @IBInspectable var isRoundedCorner: Bool = false {
            didSet {
                if(isRoundedCorner)
                {
                    layer.cornerRadius = self.frame.size.width/2;
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

class CustomButtonSmall: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.backgroundColor = CustomColor.sharedInstance.themeColor
        self.setTitleColor(UIColor.white, for: UIControl.State())
        self.titleLabel?.font = PlumberMediumFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
}

class CustomBorderButtonSmall: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.borderWidth = 1.0
        self.layer.borderColor = CustomColor.sharedInstance.themeColor.cgColor
        self.backgroundColor = UIColor.clear
        self.setTitleColor(UIColor.black, for: UIControl.State())
        self.titleLabel?.font = PlumberMediumFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
}




class CustomButtonThemeColor: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.blue, for: UIControl.State())
        self.titleLabel?.font = PlumberLargeBoldFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

    }
}
class CustomButtonTitle: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.backgroundColor = PlumberLightGrayColor
        self.setTitleColor(UIColor.black, for: UIControl.State())
        self.titleLabel?.font = PlumberLargeFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

    }
}

class TextColorButton: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.white, for: UIControl.State())
        self.titleLabel?.font = PlumberSmallFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

    }
}

class TextColorButtonTheme: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(CustomColor.sharedInstance.themeColor, for: UIControl.State())
        self.titleLabel?.font = PlumberMediumFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

    }
}

class TextColorButtonWhite: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.white, for: UIControl.State())
        self.titleLabel?.font = PlumberMediumFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

    }
}

class CustomButtonBold: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.black, for: UIControl.State())
        self.titleLabel?.font = PlumberMediumBoldFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

    }
}

class CustomButtonHeader:UIButton{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.white, for: UIControl.State())
        self.titleLabel?.font = PlumberLargeFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

    }
}

class CustomButtonHeaderBold:UIButton{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.white, for: UIControl.State())
        self.titleLabel?.font = PlumberLargeBoldFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
}

class CustomButtonRed: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.red, for: UIControl.State())
        self.titleLabel?.font = PlumberMediumBoldFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

        
    }
}

class CustomButtonGray: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setTitleColor(UIColor.darkGray, for: UIControl.State())
        self.titleLabel?.font = PlumberLargeBoldFont
        self.titleLabel?.adjustsFontSizeToFitWidth = true

        
    }
}

//MARK : - Custom ImageView
class CustomImageView:UIImageView
{
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.image! = image!.withRenderingMode(.alwaysTemplate)
        self.tintColor = CustomColor.sharedInstance.themeColor
        
    }
}


//MARK : - Custom ImageView
class CustomButtonImageView:UIButton
{
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.tintColor = CustomColor.sharedInstance.themeColor
        
    }
}
//MARK: - Custom TextField

class CustomTextField:UITextField{
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor = CustomColor.sharedInstance.themeColor
        self.font = PlumberMediumFont

     }
}

class CustomTextFieldBlack:UITextField{
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor = CustomColor.sharedInstance.themeColor
        self.layer.borderColor=PlumberLightGrayColor.cgColor
        self.layer.borderWidth=0.8
        self.font = PlumberMediumFont
        
    }
}

class CustomTextBlack:UITextField{
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor = CustomColor.sharedInstance.themeColor
        self.font = PlumberMediumFont
        
    }
}

class CustomTextgray:UITextField{
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor = UIColor.darkGray
        self.font = PlumberMediumFont
        
    }
}
//MARK: - Custom Label

class CustomLabel: UILabel {
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        self.font = PlumberMediumBoldFont
        self.adjustsFontSizeToFitWidth = true

    }
}
class CustomLabelLarge: UILabel {
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        self.textColor=CustomColor.sharedInstance.themeColor
        self.font = PlumberLargeBoldFont
        self.adjustsFontSizeToFitWidth = true

    }
}
class CustomLabelThemeColor: UILabel {
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        self.textColor=CustomColor.sharedInstance.themeColor
        self.font = PlumberMediumBoldFont
        self.adjustsFontSizeToFitWidth = true

    }
}

class CustomLabelGray: UILabel {
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        self.textColor=UIColor.darkGray
        self.font = PlumberMediumFont
        self.adjustsFontSizeToFitWidth = true

    }
}

class CustomLabelGraySmall: UILabel {
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        self.textColor=UIColor.darkGray
        self.font = PlumberSmallFont
        self.adjustsFontSizeToFitWidth = true

    }
}

class CustomLabelLightGray: UILabel {
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
        self.textColor=UIColor.lightGray
        self.font = PlumberMediumFont
        self.adjustsFontSizeToFitWidth = true

    }
}

class CustomLabelWhite:UILabel{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor=UIColor.white
        self.font = PlumberMediumFont
        self.adjustsFontSizeToFitWidth = true

    }
}

class CustomLabelHeader:UILabel{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor=UIColor.white
        self.font = PlumberLargeFont
        self.adjustsFontSizeToFitWidth = true
}
}

class CustomLabelRed:UILabel{
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.textColor=UIColor.red
        self.font = PlumberMediumFont
        self.adjustsFontSizeToFitWidth = true

    }
}
