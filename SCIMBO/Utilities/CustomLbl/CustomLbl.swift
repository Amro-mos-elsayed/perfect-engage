//
//  CustomLbl.swift
//
//
//  Created by Casp iOS on 17/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class CustomLbl: UILabel {
    required init(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)!
 
        }
 }
class CustomLblFonttextColor: UILabel {
    required init(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)!
        if(self.tag == 1)
        {
            self.font=UIFont.systemFont(ofSize: self.font.pointSize)
            self.textColor=CustomColor.sharedInstance.themeColor
        }
        else
        {
            self.font=UIFont.systemFont(ofSize: self.font.pointSize)
            self.textColor=CustomColor.sharedInstance.themeColor

            
        }
    }
    
    
}

class CustomLblFont: UILabel {
    required init(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)!
        if(self.tag == 1)
        {
            self.font=UIFont.systemFont(ofSize: self.font.pointSize)
        }
        else
        {
            self.font=UIFont.systemFont(ofSize: self.font.pointSize)
        }
    }
    
   
}

