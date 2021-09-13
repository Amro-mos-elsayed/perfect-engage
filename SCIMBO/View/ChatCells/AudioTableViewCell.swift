//
//  AudioTableViewCell.swift
//
//  Created by raguraman on 28/06/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit

class AudioTableViewCell: CustomTableViewCell {
    
    @IBOutlet weak var useImg: UIImageView!
    @IBOutlet weak var audioDuration: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var statusImg: UIImageView?
    @IBOutlet weak var bubleImg: UIImageView!
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var chatView: UIView!

    @IBOutlet weak var micIcon: UIImageView!
    @IBOutlet weak var downloadView: ACPDownloadView!
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBAction func didClickAudioPlay(_ sender: UIButton) {
        delegate?.playPauseTapped(sender: sender)
//        sender.isSelected = !sender.isSelected
    }
    

    @IBOutlet weak var cellMaxWidth: NSLayoutConstraint!
    
        
    override var bubleImage: String{
        didSet{
            let imgName = messageFrame.message.isLastMessage ? bubleImage : bubleImage+"_0"
            bubleImg.image = UIImage(named:imgName)?.renderImg()
            bubleImg.tintColor = statusImg != nil ? outgoingBubbleColour : incommingBubbleColour
        }
    }
    
    override var RowIndex: IndexPath{
        didSet{
            playPauseButton.tag = RowIndex.row
            audioSlider.tag = RowIndex.row
            if AudioManager.sharedInstence.currentIndex == RowIndex{
                if AudioManager.sharedInstence.isPlaying{
                    playPauseButton.isSelected = true
                }else{
                    playPauseButton.isSelected = false
                }
                audioSlider.value = AudioManager.sharedInstence.lastSliderValue
                audioDuration.text = AudioManager.sharedInstence.lastTime
//                audioSlider.value = 0
            }else{
                playPauseButton.isSelected = false
                audioSlider.value = 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        audioSlider.setThumbImage(UIImage(named: "roundSlider"), for: .normal)
        playPauseButton.setImage(UIImage(named: "play"), for: .normal)
        playPauseButton.setImage(UIImage(named: "pause"), for: .selected)
        audioSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        downloadView.setActionForTap { (sender, state) in
            self.downloadButtonPressed(sender, status: state)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
//    public func isDownloadInProgress(_ value:Bool){
//        playPauseButton.isHidden = value
//        let status:ACPDownloadStatus = value ? .indeterminate : .none
//        downloadView.setIndicatorStatus(status)
//        downloadView.isHidden = !value
//        downloadView.isUserInteractionEnabled = false
//    }
//    
//    public func showManualDownload(){
//        playPauseButton.isHidden = true
//        downloadView.setIndicatorStatus(.none)
//        downloadView.isHidden = false
//        downloadView.isUserInteractionEnabled = true
//    }

    public func isDownloadInProgress(_ status : ACPDownloadStatus, _ progress : Float = 0.0){
        downloadView.setIndicatorStatus(status)
        downloadView.setProgress(progress, animated: true)
        downloadView.isHidden = status == .none ? true : false
        playPauseButton.isHidden = status == .none ? false : true
        downloadView.isUserInteractionEnabled = false
    }
    
    public func showManualDownload(){
        playPauseButton.isHidden = true
        downloadView.setIndicatorStatus(.none)
        downloadView.isHidden = false
        downloadView.isUserInteractionEnabled = true
    }

    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                delegate?.sliderChanged(slider, event: .editingDidBegin)
                break
            case .moved:break
            case .ended:
                delegate?.sliderChanged(slider, event: .editingDidEnd)
                break
            default:
                break
            }
        }
    }
    
}
