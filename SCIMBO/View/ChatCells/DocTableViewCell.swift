//
//  PDFTableViewCell.swift
//
//  Created by raguraman on 04/07/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit

class DocTableViewCell: CustomTableViewCell {

    @IBOutlet weak var fileView: UIView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var statusImg: UIImageView?
    
    @IBOutlet weak var tailImg: UIImageView!
    @IBOutlet weak var timeLabelLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var fileTypeImg: UIImageView!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var fileImg: UIImageView!
    @IBOutlet weak var bubleImg: UIImageView!
    
    @IBOutlet weak var imgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellMaxWidth: NSLayoutConstraint!
    
    @IBOutlet weak var downloadView: ACPDownloadView!
    
    override var bubleImage: String{
        didSet{
            let imgName = messageFrame.message.isLastMessage ? bubleImage : bubleImage+"_0"
            bubleImg.image = UIImage(named:imgName)?.renderImg()
            bubleImg.tintColor = statusImg != nil ? outgoingBubbleColour : incommingBubbleColour
        }
    }
    
        
    override func layoutSubviews() {
        super.layoutSubviews()
        customButton.frame = fileView.bounds
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tailImg.tintColor = chatView.backgroundColor
        self.addButton(to: fileView)
        downloadView.setActionForTap { (sender, state) in
            self.downloadButtonPressed(sender, status: state)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapTextview(tap:)))
        messageLabel.addGestureRecognizer(tap)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        fileView.backgroundColor = statusImg != nil ? outgoingHighlightColour : incommingHighlightColour
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        fileView.backgroundColor = statusImg != nil ? outgoingHighlightColour : incommingHighlightColour
    }
    
    public func isDownloadInProgress(_ status : ACPDownloadStatus, _ progress : Float = 0.0){
        downloadView.setIndicatorStatus(status)
        downloadView.setProgress(progress, animated: true)
        downloadView.isHidden = status == .none ? true : false
        downloadView.isUserInteractionEnabled = false
    }
    
    public func showManualDownload(){
        downloadView.setIndicatorStatus(.none)
        downloadView.isHidden = false
        downloadView.isUserInteractionEnabled = true
    }
    
}
