//
//  DeleteView.swift
//  SCIMBO
//
//  Created by Nirmal's Mac Mini on 05/07/19.
//  Copyright © 2019 CASPERON. All rights reserved.
//

import UIKit

class DeleteView: UIView {
    
    @IBOutlet var hint_lbl:UILabel!
    @IBOutlet weak var progressBar: SSCircularProgressView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = loadFromNibNamed("ConnectingView")
        self.showTimerProgressViaNIB()
    }
    
    required init(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)!
        self.backgroundColor = CustomColor.sharedInstance.themeColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        
        hint_lbl.text = "Deleted for Both side"
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
    // MARK: - Private Methods
    
    func showTimerProgressViaNIB() {
        progressBar.setCircleStrokeWidth(3)
        progressBar.setCircleStrokeColor(UIColor.clear, circleFillColor: UIColor.clear, progressCircleStrokeColor: UIColor.white, progressCircleFillColor: UIColor.clear)

        var second: CGFloat = 5
        progressBar.setProgressText("\(Int(second))")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (timer) in
            second -= 1
            self?.progressBar.progress = second/5
            self?.progressBar.setProgressText("\(Int(second))")
            
            if second == 0 {
                    self?.removeFromSuperview()
                second = 5
            }
        }
    }
    
   
    
}
class SSDefaultColor {
    static let circleStrokeColor: UIColor = .clear
    static let circleFillColor: UIColor = UIColor.clear
    static let progressCircleStrokeColor: UIColor = .red
    static let progressCircleFillColor: UIColor = .white
}

class SSCircularProgressView: UIView {
    
    // progress: Should be between 0 to 1
    var progress: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private var circleStrokeWidth: CGFloat = 2
    private var circleStrokeColor: UIColor = SSDefaultColor.circleStrokeColor
    private var circleFillColor: UIColor = SSDefaultColor.circleFillColor
    private var progressCircleStrokeColor: UIColor = SSDefaultColor.progressCircleStrokeColor
    private var progressCircleFillColor: UIColor = SSDefaultColor.progressCircleFillColor
    
    private var textLabel: UILabel!
    private var textFont: UIFont? = UIFont.boldSystemFont(ofSize: 13)
    private var textColor: UIColor? = UIColor.black
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    // MARK: Public Methods
    
    func setCircleStrokeWidth(_ circleStrokeWidth: CGFloat) {
        self.circleStrokeWidth = circleStrokeWidth
        setCircleStrokeColor()
    }
    
    func setCircleStrokeColor(_ circleStrokeColor: UIColor = SSDefaultColor.circleStrokeColor, circleFillColor: UIColor = SSDefaultColor.circleFillColor, progressCircleStrokeColor: UIColor = SSDefaultColor.progressCircleStrokeColor, progressCircleFillColor: UIColor = SSDefaultColor.progressCircleFillColor) {
        self.circleStrokeColor = circleStrokeColor
        self.circleFillColor = circleFillColor
        self.progressCircleStrokeColor = progressCircleStrokeColor
        self.progressCircleFillColor = progressCircleFillColor
        
        self.setNeedsDisplay()
    }
    
    func setProgressText(_ text: String) {
        textLabel.text = text
        textLabel.textColor = UIColor.white
    }
    
    func setProgressTextFont(_ font: UIFont = UIFont.boldSystemFont(ofSize: 17), color: UIColor = UIColor.black) {
        textLabel.font = font
        textLabel.textColor = color
    }
    
    // MARK: Private Methods
    
    private func setupView() {
        textLabel = UILabel(frame: self.bounds)
        textLabel.textAlignment = .center
        textLabel.font = textFont
        textLabel.textColor = textColor
        textLabel.numberOfLines = 0
        
        self.addSubview(textLabel)
    }
    
    // MARK: Core Graphics Drawing
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawRect(rect, margin: 0, color: circleStrokeColor, percentage: 1)
        drawRect(rect, margin: circleStrokeWidth, color: circleFillColor, percentage: 1)
        drawRect(rect, margin: circleStrokeWidth, color: progressCircleFillColor, percentage: progress)
        
        drawProgressCircle(rect)
    }
    
    private func drawRect(_ rect: CGRect, margin: CGFloat, color: UIColor, percentage: CGFloat) {
        
        let radius: CGFloat = min(rect.height, rect.width) * 0.5 - margin
        let centerX: CGFloat = rect.width * 0.5
        let centerY: CGFloat = rect.height * 0.5
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        let center: CGPoint = CGPoint(x: centerX, y: centerY)
        context.move(to: center)
        let startAngle: CGFloat = -.pi/2
        let piPercent =  .pi * 2 * percentage
        let endAngle: CGFloat = -.pi/2 + piPercent
        context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        context.closePath()
        context.fillPath()
    }
    
    private func drawProgressCircle(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setLineWidth(circleStrokeWidth)
        context.setStrokeColor(progressCircleStrokeColor.cgColor)
        
        let centerX: CGFloat = rect.width * 0.5
        let centerY: CGFloat = rect.height * 0.5
        let radius: CGFloat = min(rect.height, rect.width) * 0.5 - (circleStrokeWidth / 2)
        let startAngle: CGFloat = -.pi/2
        let piRation =  .pi * 2 * progress
        let endAngle: CGFloat = -.pi/2 + piRation
        let center: CGPoint = CGPoint(x: centerX, y: centerY)
        
        context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        context.strokePath()
    }
}
