//
//  StatusIndicatorView.swift
//  WhatsUpStatusIndeicator
//
//  Created by raguraman asokan on 31/03/18.
//  Copyright © 2018 raguraman asokan. All rights reserved.
//


import UIKit

@IBDesignable class StatusIndicatorView: UIView {
    
    @IBInspectable var numberOfStatus:CGFloat = 5{
        didSet{
            setNeedsDisplay()
        }
    }
    @IBInspectable var indicatorPadding:CGFloat = 0.01{
        didSet{
            setNeedsDisplay()
        }
    }
    @IBInspectable var viewedStatusCount:CGFloat = 0{
        didSet{
            setNeedsDisplay()
        }
    }
    @IBInspectable var defaultStatusColour:UIColor = CustomColor.sharedInstance.themeColor {
        didSet{
            setNeedsDisplay()
        }
    }
    @IBInspectable var viewedStatusColour:UIColor = UIColor.gray{
        didSet{
            setNeedsDisplay()
        }
    }
    @IBInspectable var statusBarThickness:CGFloat = 5{
        didSet{
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius: CGFloat = max(bounds.width, bounds.height)
        let singleBarLength = ((.pi * 2) / CGFloat(numberOfStatus))
        let paddingInRad = ((.pi * 2) * indicatorPadding)
        
        for i in 0..<Int(numberOfStatus){
            var startAngle: CGFloat = (singleBarLength * CGFloat(i)) + paddingInRad
            var endAngle: CGFloat = ((singleBarLength * CGFloat(i+1))-paddingInRad)
            
            if numberOfStatus == 1{
                startAngle = 0
                endAngle = singleBarLength
            }
            
            let path = UIBezierPath(arcCenter: center,
                                    radius: radius/2 - CGFloat(statusBarThickness)/2,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: true)
            
            path.lineWidth = CGFloat(statusBarThickness)
            if i < Int(viewedStatusCount){
                viewedStatusColour.setStroke()
            }
            else{
                defaultStatusColour.setStroke()
            }
            
            path.stroke()
        }
        
    }

}
