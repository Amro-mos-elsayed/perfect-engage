//
//  URLTableViewCell.swift
//
//  Created by raguraman on 02/07/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit

class URLTableViewCell: CustomTableViewCell {

    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var statusImg: UIImageView?
    
    @IBOutlet weak var readMoreBtn: UIButton!
    @IBOutlet weak var messageLabelBottom: NSLayoutConstraint!
    @IBOutlet weak var replayView: UIView!
    @IBOutlet weak var tailImg: UIImageView!
    @IBOutlet weak var bubleImg: UIImageView!
    @IBOutlet weak var urlImgView: UIImageView!
//    @IBOutlet weak var urlTitle: UILabel!
//    @IBOutlet weak var urlContent: UILabel!
//    @IBOutlet weak var urlImgWidth: NSLayoutConstraint!
    
    @IBOutlet weak var urlTextView: UITextView!
    @IBOutlet weak var urlViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var cellMaxWidth: NSLayoutConstraint!
    
    
    private var readMorePressCount = 1
    override var bubleImage: String{
        didSet{
            let imgName = messageFrame.message.isLastMessage ? bubleImage : bubleImage+"_0"
            bubleImg.image = UIImage(named:imgName)?.renderImg()
            bubleImg.tintColor = statusImg != nil ? outgoingBubbleColour : incommingBubbleColour
        }
    }
    
    override var readCount: String{
        didSet{
            readMorePressCount = Int(readCount) ?? 1
            messageLabel.numberOfLines = 50*readMorePressCount
        }
    }
    
    override var RowIndex: IndexPath{
        didSet{
            readMoreBtn.tag = RowIndex.row
            forwardButton.tag = RowIndex.row
        }
    }
    
    @IBAction func didClickReadMore(_ sender: UIButton) {
        readMorePressCount += 1
        messageLabel.numberOfLines = 50*readMorePressCount
        delegate?.readMorePressed(sender: sender, count: "\(readMorePressCount)")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tailImg.tintColor = chatView.backgroundColor
        self.addButton(to: replayView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapTextview(tap:)))
        messageLabel.addGestureRecognizer(tap)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        replayView.backgroundColor = statusImg != nil ? outgoingHighlightColour : incommingHighlightColour
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        replayView.backgroundColor = statusImg != nil ? outgoingHighlightColour : incommingHighlightColour
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        forwardButton.isHidden(value: true)
    }
    

    
    @IBAction func didClickForwardButton(_ sender: UIButton) {
        delegate?.forwordPressed(sender)
    }
}
