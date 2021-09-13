//
//  ImageTableViewCell.swift
//
//  Created by raguraman on 19/06/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit

class ImageTableViewCell: CustomTableViewCell {

    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var statusImg: UIImageView?
    
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var messageLabelBottom: NSLayoutConstraint!
    @IBOutlet weak var imageHeightConstaraint: NSLayoutConstraint!
   
    @IBOutlet weak var ViewImg: UIView!
    @IBOutlet weak var chatImg: UIImageView!
    @IBOutlet weak var gifImg: UIImageView!
    @IBOutlet weak var tailImg: UIImageView!
    @IBOutlet weak var bubleImg: UIImageView!
    @IBOutlet weak var timeLabelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var retryView: UIView?
    @IBOutlet weak var retryButton: UIButton?
    @IBOutlet weak var cellTrailing: NSLayoutConstraint?
    @IBOutlet weak var readMoreBtn: UIButton!
    @IBOutlet weak var cellMaxWidth: NSLayoutConstraint!
    @IBOutlet weak var gradientView: GradientView!
    
    @IBOutlet weak var messageTop: NSLayoutConstraint!
    
    @IBOutlet weak var videoSizeIndicatorView: UIView?
    
    @IBOutlet weak var downloadIndicator: ACPDownloadView?
    
    private var readMorePressCount = 1
    override var bubleImage: String{
        didSet{
            let imgName = messageFrame.message.isLastMessage ? bubleImage : bubleImage+"_0"
            bubleImg.image = UIImage(named:imgName)?.renderImg()
            bubleImg.tintColor = statusImg != nil ? outgoingBubbleColour : incommingBubbleColour
        }
    }
    
    override var RowIndex: IndexPath{
        didSet{
            readMoreBtn.tag = RowIndex.row
            forwardButton.tag = RowIndex.row
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        customButton.frame = ViewImg.bounds
    }

    
    
    @IBAction func didClickReadMore(_ sender: UIButton) {
        readMorePressCount += 1
        messageLabel.numberOfLines = 50*readMorePressCount
        delegate?.readMorePressed(sender: sender, count: "\(readMorePressCount)")
    }
    
    override var readCount: String{
        didSet{
            readMorePressCount = Int(readCount) ?? 1
            messageLabel.numberOfLines = 50*readMorePressCount
        }
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        customButton.frame = ViewImg.bounds

        timeLabelBottomConstraint.constant = imageHeightConstaraint.constant == 160 ? 5 : 10
        gradientView.isHidden = imageHeightConstaraint.constant == 160 ? true : false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tailImg.tintColor = chatView.backgroundColor
        
        self.addButton(to: ViewImg)
        self.addLoader(to: ViewImg)
        
        showVideoSize = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapTextview(tap:)))
        messageLabel.addGestureRecognizer(tap)

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override var showVideoSize: Bool{
        didSet{
            videoSizeIndicatorView?.isHidden = !showVideoSize
//            let img = ACPStaticImagesAlternative(#imageLiteral(resourceName: "downArrow"))
//            self.downloadIndicator?.setImages(img)
            if showVideoSize{
//                videoSizeLabel?.text = ""
                downloadIndicator?.setActionForTap { (sender, state) in
                    self.downloadButtonPressed(sender, status: state)
                }
                if(videoSizeIndicatorView != nil)
                {
                    self.view.bringSubviewToFront(videoSizeIndicatorView!)
                }
            }
            
        }
    }
    
    func sizePerMB(url: URL?) -> Double {
        guard let filePath = url?.path else {
            return 0.0
        }
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                return size.doubleValue / 1000000.0
            }
        } catch {
            print("Error: \(error)")
        }
        return 0.0
    }
    
//    override func loadingButtonPressed() {
//        super.loadingButtonPressed()
//        setTrilingConstraint(50)
//    }
    
    override func loadingButtonPressed(_ sender: UIButton) {
        super.loadingButtonPressed(sender)
        guard !sender.isSelected else{return}
        setTrilingConstraint(50)
    }
    
    override func willTransition(to state: UITableViewCell.StateMask) {
        super.willTransition(to: state)
    }
//    override func willTransition(to state: UITableViewCell.StateMask) {
//        super.willTransition(to: state)
//    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        forwardButton.isHidden = true
    }
    
    func setTrilingConstraint(_ value: Int, animated:Bool = true, with duration:TimeInterval = 0.3){
        cellTrailing?.constant = CGFloat(value)
        guard cellTrailing != nil else{return}
        let animationDuration = animated ? duration : 0
        if cellTrailing?.constant == 0{
            self.forwardButton?.isHidden = true
            self.forwardButton?.alpha = 0
            UIView.animate(withDuration: animationDuration, animations: {
                self.superview?.layoutIfNeeded()
                self.forwardButton?.alpha = 1
                self.retryView?.alpha = 0
                
            }) { (true) in
                self.retryView?.isHidden = true
            }
        }else{
            self.retryView?.isHidden = false
            self.retryView?.alpha = 0
            UIView.animate(withDuration: animationDuration, animations: {
                self.superview?.layoutIfNeeded()
                self.forwardButton?.alpha = 0
                self.retryView?.alpha = 1
                
            }) { (true) in
                self.forwardButton?.isHidden = true
            }
        }
        
    }
    
    @IBAction func didClickRetry(_ sender: UIButton) {
        self.gifImg.stopAnimatingGif()
        super.retriveLoading()
        setTrilingConstraint(0)
    }
    
    
    @IBAction func didClickForwardButton(_ sender: UIButton) {
        delegate?.forwordPressed(sender)
    }
    
    
}

