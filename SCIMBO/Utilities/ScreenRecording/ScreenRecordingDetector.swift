//
//  ScreenRecordingDetector.swift
//  SCIMBO
//
//  Created by 2p on 1/30/22.
//  Copyright © 2022 CASPERON. All rights reserved.
//

import Foundation
import UIKit

protocol ScreenRecordingDetectorDelegate: AnyObject {
    func screenRecordingStatusChanged(isRecording: Bool, isMirroring: Bool)
}

class ScreenRecordingDetector {
    
    public static var shared = ScreenRecordingDetector()
    weak var delegate: ScreenRecordingDetectorDelegate?
    private init() {}
    
    func startMonitoring() {
        recordingStatusChanged()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(recordingStatusChanged),
                                               name: UIScreen.capturedDidChangeNotification,
                                               object: nil)
    }
    
    @objc private func recordingStatusChanged() {
        delegate?.screenRecordingStatusChanged(isRecording: isRecording(),
                                               isMirroring: isMirroring())
        
        
    }
    
    func isRecording() -> Bool {
        for screen in UIScreen.screens {
            return screen.isCaptured
        }
        return false
    }
    
    func isMirroring() -> Bool {
        for screen in UIScreen.screens {
            return (screen.mirrored != nil)
        }
        return false
    }
}
