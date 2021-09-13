//
//  AudioManager.swift
//
//  Created by raguraman on 04/07/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit
import AVFoundation


protocol AudioManagerDelegate : class {
    func updateSlider(value:Float)
    func updateDuration(value:String, at indexPath: IndexPath)
    func playerCompleted()
}
class AudioManager: NSObject, AVAudioPlayerDelegate{
    
    //MARK:- public variables
    static let sharedInstence = AudioManager()
    var player: AVAudioPlayer?
    private var sliderTimer: Timer?
    private var durationTimer:  Timer?
    
    //MARK:- private variables
    weak var delegate:AudioManagerDelegate?
    var currentIndex: IndexPath?
    var isPlaying = false
    var lastSliderValue:Float = 0
    var lastTime = String()
    
    //MARK:- public functions
    func setupAudioPlayer(with data:Data?, at indexPath:IndexPath) {
        guard let audioData = data else { return }
        
        do {
            if(!AppDelegate.sharedInstance.isVideoViewPresented) {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                try AVAudioSession.sharedInstance().setActive(true)
            }
            
            player = try AVAudioPlayer(data: audioData)
            player?.delegate = self
            pauseSound()
            currentIndex = indexPath
            playSound()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func StopPlayer(){
        invalidateTimer()
        self.player = nil
        delegate?.playerCompleted()
        self.currentIndex = nil
        isPlaying = false
    }
    
    func playbackSliderValueChanged(_ playbackSlider:UISlider, event:UIControl.Event)
    {
        guard let checkedPlayer = player else{return}
        pauseSound()
        invalidateTimer()
        if event == .editingDidEnd{
            print(TimeInterval(playbackSlider.value * Float(checkedPlayer.duration)))
            player?.currentTime = TimeInterval(playbackSlider.value * Float(checkedPlayer.duration))
            playSound()
        }
        
    }
    
    func pauseSound(){
        invalidateTimer()
        player?.pause()
        isPlaying = false
    }
    
    func playSound(){
        invalidateTimer()
        startTimer()
        player?.play()
        isPlaying = true
    }
    
    //MARK:- private functions
    
    @objc private func updateTime() {
        guard let checkedPlayer = player else{return}
        let currentTime = Int(checkedPlayer.currentTime) + 1
        let duration = Int(checkedPlayer.duration)
        let total = currentTime - duration
        _ = String(total)
        
        let minutes = currentTime/60
        let seconds = currentTime - minutes / 60
        
        let time = NSString(format: "%02d:%02d", minutes,seconds) as String
        lastTime = time
        delegate?.updateDuration(value: time, at: currentIndex!)
    }
    
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        StopPlayer()
    }
    
    @objc private func updateSlider(){
        guard let checkedPlayer = player else{return}
        let currentTime = Float(checkedPlayer.currentTime)
        let duration = Float(checkedPlayer.duration)
        let sliderValue = currentTime/duration
        lastSliderValue = sliderValue
        delegate?.updateSlider(value: sliderValue)
    }
    
    private func invalidateTimer(){
        durationTimer?.invalidate()
        sliderTimer?.invalidate()
    }
    
    private func startTimer(){
        invalidateTimer()
        durationTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        sliderTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
    }
    
    deinit {
        StopPlayer()
    }
}
