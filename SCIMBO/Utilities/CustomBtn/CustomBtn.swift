//
//  CustomBtn.swift
//
//
//  Created by Casp iOS on 17/02/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class CustomBtn: UIButton {
    required init(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)!
        if(self.tag == 1)
        {
            
            
             self.titleLabel?.font=UIFont.systemFont(ofSize: (self.titleLabel?.font.pointSize)!)
        }
        else
        {
            self.titleLabel?.font=UIFont.systemFont(ofSize: (self.titleLabel?.font.pointSize)!)
         }
 
    }
  
}



class CustomBtnThemeTxtColor: UIButton {
    convenience init(aDecoder: NSCoder) {
        self.init(coder: aDecoder)!
         if(self.tag == 1)
        {
            
            self.titleLabel?.font=UIFont.systemFont(ofSize: (self.titleLabel?.font.pointSize)!)
            self.setTitleColor(CustomColor.sharedInstance.themeColor, for: .normal)
        }
        else
        {
            self.titleLabel?.font=UIFont.systemFont(ofSize: (self.titleLabel?.font.pointSize)!)
            self.setTitleColor(CustomColor.sharedInstance.themeColor, for: .normal)

        }
        
    }
    
  
    
}
class CustomBtnBackgroundColor: UIButton {
    convenience init(aDecoder: NSCoder) {
        self.init(coder: aDecoder)!
        if(self.tag == 1)
        {
            self.titleLabel?.font=UIFont.systemFont(ofSize: (self.titleLabel?.font.pointSize)!)

            self.backgroundColor=CustomColor.sharedInstance.themeColor
         }
        else
        {
            self.titleLabel?.font=UIFont.systemFont(ofSize: (self.titleLabel?.font.pointSize)!)
            self.backgroundColor=CustomColor.sharedInstance.themeColor
            
        }
        
    }
    
    
    
}


