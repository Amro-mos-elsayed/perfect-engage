//
//  CustomCellExtension.swift
//
//  Created by raguraman on 04/07/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import Foundation

extension UITextView{
    
    func numberOfLines() -> Int{
        if let fontUnwrapped = self.font{
            return Int(self.contentSize.height / fontUnwrapped.lineHeight)
        }
        return 0
    }
    
    func heightForLines(_ count:Int) -> CGFloat{
        if let fontUnwrapped = self.font{
            return CGFloat(count)*fontUnwrapped.lineHeight
        }
        return 0.0
    }
    
}

extension UITextView {
    
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        
        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
}

extension UILabel {
    
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        
        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
}

extension UIImage{
    func renderImg() -> UIImage {
        
        return self.stretchableImage(withLeftCapWidth: 21, topCapHeight: 14)
//        return self
//            .resizableImage(withCapInsets:
//                UIEdgeInsetsMake(15, 21, 19, 21),
//                            resizingMode: .stretch)
//            .withRenderingMode(.alwaysTemplate)
    }
    
}

extension UIView{
    func isHidden(value:Bool, for time:TimeInterval = 0.1){
        self.alpha = value ? 1 : 0
        UIView.animate(withDuration: time, animations: {
            self.alpha = value ? 0 : 1
        }) { (true) in
            self.isHidden = value
        }
    }
}

extension UITableView{
    func registerCell(){
        
        register(UINib(nibName: "TextTableViewCell", bundle: nil), forCellReuseIdentifier: "outgoingText")
        register(UINib(nibName: "ReciveTextTableViewCell", bundle: nil), forCellReuseIdentifier: "incomingText")
        
        register(UINib(nibName: "ImageTableViewCell", bundle: nil), forCellReuseIdentifier: "outgoingImage")
        register(UINib(nibName: "ReciveImageTableViewCell", bundle: nil), forCellReuseIdentifier: "incomingImage")
        
        register(UINib(nibName: "ReplayTableViewCell", bundle: nil), forCellReuseIdentifier: "outgoingReplay")
        register(UINib(nibName: "ReciveReplayTableViewCell", bundle: nil), forCellReuseIdentifier: "incomingReplay")
        
        register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "outgoingContact")
        register(UINib(nibName: "ReciveContactTableViewCell", bundle: nil), forCellReuseIdentifier: "incomingContact")
        
        register(UINib(nibName: "AudioTableViewCell", bundle: nil), forCellReuseIdentifier: "outgoingAudio")
        register(UINib(nibName: "ReciveAudioTableViewCell", bundle: nil), forCellReuseIdentifier: "incomingAudio")
        
        register(UINib(nibName: "URLTableViewCell", bundle: nil), forCellReuseIdentifier: "outgoingUrl")
        register(UINib(nibName: "ReciveURLTableViewCell", bundle: nil), forCellReuseIdentifier: "incomingUrl")
        
        register(UINib(nibName: "DocTableViewCell", bundle: nil), forCellReuseIdentifier: "outgoingFile")
        register(UINib(nibName: "ReciveDocTableViewCell", bundle: nil), forCellReuseIdentifier: "incomingFile")
        
    }
}
