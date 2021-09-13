//
//  SearchBarTableViewCell.swift
//
//
//  Created by CASPERON on 27/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit

class SearchBarTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func configureCellWith(searchTerm:String, cellText:String){
        var pattern = searchTerm.replacingOccurrences(of: " ", with: "|")
        //var pattern = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "|")
        pattern.insert("(", at: pattern.startIndex)
        pattern.insert(")", at: pattern.endIndex)
        
        do {
            let regEx = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive,
                                                                            .allowCommentsAndWhitespace])
            let range = NSRange(location: 0, length: cellText.count)
            let displayString = NSMutableAttributedString(string: cellText)
            _ = CustomColor.sharedInstance.themeColor
            
            regEx.enumerateMatches(in: cellText, options: .withTransparentBounds, range: range, using: { (result, flags, stop) in
                if result?.range != nil {
                    // displayString.setAttributes([NSBackgroundColorAttributeName:highlightColour], range: result!.range)
                }
                
            })
            
            self.textLabel?.attributedText = displayString
            
        } catch
        {
            self.textLabel?.text = cellText
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
