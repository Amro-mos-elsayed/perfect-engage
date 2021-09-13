//
//  VideoTrimCell.swift
//
//
//  Created by Casperon iOS on 19/09/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import ICGVideoTrimmer
import MobileCoreServices

class VideoTrimCell: UICollectionViewCell,ICGVideoTrimmerDelegate {
    @IBOutlet weak var Play_Btn: UIButton!
    @IBOutlet weak var media_ImageView: UIImageView!
    @IBOutlet weak var media_GifImageView: UIImageView!
    @IBOutlet weak var TrimmerView: ICGVideoTrimmerView!
    @IBOutlet weak var PlayerView: UIView!
    
    var isVideoData:Bool = Bool()
    var playerLayer:AVPlayerLayer! = AVPlayerLayer()
    var isPlaying:Bool=Bool()
    var restartOnPlay:Bool=Bool()
    var avPlayer: AVPlayer!
    var videoPlaybackPosition:CGFloat = CGFloat()
    var playbackTimeCheckerTimer:Timer!=Timer()
    var ObjMultimedia:MultimediaRecord = MultimediaRecord()
    var fromStatus : Bool = Bool()
    
    func UpdateUI()
    {
//        NotificationCenter.removeObserver(self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer?.currentItem)
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.PlayVideo))
        tapGesture.numberOfTapsRequired = 1
        self.PlayerView.addGestureRecognizer(tapGesture)
        
        let tapGesture1:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.DidclickPlayBtn(_:)))
        tapGesture1.numberOfTapsRequired = 1
        self.media_GifImageView.addGestureRecognizer(tapGesture1)
        self.media_GifImageView.isUserInteractionEnabled = true
        
        if(self.isVideoData)
        {
            self.Play_Btn.isHidden = false
            self.Play_Btn.setImage(#imageLiteral(resourceName: "playIcon"), for: .normal)
            self.TrimmerView.isHidden = false
            self.PlayerView.isHidden = false
            self.media_ImageView.isHidden = true
            self.media_GifImageView.isHidden = true
            self.ConfigureVideo(videoURl: self.ObjMultimedia.assetpathname,ObjRecord:self.ObjMultimedia)
        }
        else if(ObjMultimedia.isGif)
        {
            self.Play_Btn.isHidden = false
            self.Play_Btn.center = self.media_GifImageView.center
            self.Play_Btn.setImage(#imageLiteral(resourceName: "gifIcon"), for: .normal)
            self.TrimmerView.isHidden = true
            self.PlayerView.isHidden = true
            self.media_ImageView.isHidden = true
            self.media_GifImageView.isHidden = false
            
            let image = UIImage(gifData: ObjMultimedia.rawData)
            self.media_GifImageView.setGifImage(image)
            self.media_GifImageView.stopAnimatingGif()
        }
        else
        {
            self.Play_Btn.isHidden = true
            self.TrimmerView.isHidden = true
            self.PlayerView.isHidden = true
            self.media_ImageView.isHidden = false
            self.media_GifImageView.isHidden = true
            self.media_ImageView.image = ObjMultimedia.Thumbnail
        }
    }
    
    deinit {
        avPlayer = nil
        playerLayer = nil
    }
    @objc func PlayVideo()
    {
        if isPlaying {
            avPlayer.pause()
            Play_Btn.isHidden = false
            stopPlaybackTimeChecker()
        }
        else {
            if restartOnPlay {
                seekVideo(toPos: CGFloat(ObjMultimedia.StartTime))
                TrimmerView.seek(toTime: CGFloat(ObjMultimedia.StartTime))
                restartOnPlay = false
            }
            Play_Btn.isHidden = true
            avPlayer.play()
            startPlaybackTimeChecker()
        }
        isPlaying = !isPlaying
        TrimmerView.hideTracker(!isPlaying)
    }
    
    
    func trimmerView(_ trimmerView: ICGVideoTrimmerView, didChangeLeftPosition startTime: CGFloat, rightPosition endTime: CGFloat) {
        restartOnPlay = true
        avPlayer.pause()
        Play_Btn.isHidden = false
        isPlaying = false
        stopPlaybackTimeChecker()
        TrimmerView.hideTracker(true)
        if startTime != CGFloat(ObjMultimedia.StartTime) {
            //then it moved the left position, we should rearrange the bar
            seekVideo(toPos: CGFloat(ObjMultimedia.StartTime))
        }
        else {
            // right has changed
            seekVideo(toPos: endTime)
        }
        ObjMultimedia.StartTime = Double(startTime)
        ObjMultimedia.Endtime = Double(endTime)
    }
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.onPlaybackTimeCheckerTimer), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        if (playbackTimeCheckerTimer != nil) {
            playbackTimeCheckerTimer.invalidate()
            playbackTimeCheckerTimer = nil
        }
    }
    @objc func onPlaybackTimeCheckerTimer() {
        let curTime: CMTime = avPlayer.currentTime()
        var seconds: Float64 = CMTimeGetSeconds(curTime)
        if seconds < 0 {
            seconds = 0
            // this happens! dont know why.
        }
        videoPlaybackPosition = CGFloat(seconds)
        TrimmerView.seek(toTime: CGFloat(seconds))
        if videoPlaybackPosition >= CGFloat(ObjMultimedia.Endtime) {
            videoPlaybackPosition = CGFloat(ObjMultimedia.StartTime)
            seekVideo(toPos: CGFloat(ObjMultimedia.StartTime))
            TrimmerView.seek(toTime: CGFloat(ObjMultimedia.StartTime))
        }
    }
    
    func seekVideo(toPos pos: CGFloat) {
        videoPlaybackPosition = pos
        let time: CMTime = CMTimeMakeWithSeconds(Float64(videoPlaybackPosition), preferredTimescale: avPlayer.currentTime().timescale)
        //NSLog(@"seekVideoToPos time:%.2f", CMTimeGetSeconds(time));
        avPlayer.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero) { success in
                print(success)
            }
            if(avPlayer != nil)
            {
                avPlayer.pause()
            }
            Play_Btn.isHidden = false
        }
    }
    
    func ConfigureVideo(videoURl:String,ObjRecord:MultimediaRecord)
    {
        DispatchQueue.main.async {
            if(self.avPlayer == nil)
            {
                let videoURL = URL(string: videoURl)!
                self.avPlayer = AVPlayer(url: videoURL)
                self.avPlayer.pause()
                self.playerLayer.player = self.avPlayer
                self.playerLayer.contentsGravity = CALayerContentsGravity.resize
//                self.playerLayer.contentsGravity = AVLayerVideoGravity.resize
                self.playerLayer.frame = CGRect(x: 0, y: 0, width: self.PlayerView.frame.size.width, height: self.PlayerView.frame.size.height)
                self.SettrimmerView(videoURL: videoURL as URL,ObjRecord:ObjRecord)
                self.PlayerView.layer.addSublayer(self.playerLayer)
            }
        }
        
            self.Play_Btn.isHidden = false;
    }
    
    func SettrimmerView(videoURL:URL,ObjRecord:MultimediaRecord)
    {
        if(ObjRecord.Endtime <= 5.0)
        {
            TrimmerView.isUserInteractionEnabled = false
        }
        else
        {
            TrimmerView.isUserInteractionEnabled = true
        }
        let AVasset:AVAsset = AVAsset(url: videoURL )
        TrimmerView.themeColor = UIColor.lightGray
        TrimmerView.asset =  AVasset
        TrimmerView.rulerLabelInterval = 5
        TrimmerView.minLength = CGFloat(5)
        TrimmerView.maxLength = fromStatus ? CGFloat(30) : CGFloat(ObjRecord.Endtime)
        TrimmerView.showsRulerView = false
        TrimmerView.trackerColor = UIColor.yellow
        TrimmerView.delegate = self
        TrimmerView.resetSubviews()
    }
    
    @IBAction func DidclickPlayBtn(_ sender: Any) {
        if(self.isVideoData)
        {
            self.PlayVideo()
        }
        else if(ObjMultimedia.isGif)
        {
            if(self.media_GifImageView.isAnimatingGif())
            {
                self.media_GifImageView.stopAnimatingGif()
                self.Play_Btn.setImage(#imageLiteral(resourceName: "gifIcon"), for: .normal)
            }
            else
            {
                self.media_GifImageView.startAnimatingGif()
                self.Play_Btn.setImage(nil, for: .normal)
            }
        }
    }
}
