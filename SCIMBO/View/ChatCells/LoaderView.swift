//
//  loaderView.swift
//
//  Created by raguraman on 26/06/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit

class LoaderView: UIView {
    
    
    @IBOutlet weak var downloadIndicator: ACPDownloadView!
    @IBOutlet weak var progressView: MRCircularProgressView!
    
    @IBOutlet weak var loadingButton: UIButton!
    
    
    var isUpload = Bool(){
        didSet{
//            self.loadingButton.isSelected = !isUpload
            self.loadingButton.isHidden = !isUpload
            self.downloadIndicator.isHidden = false
            if(isUpload)
            {
                self.progressView.isHidden = true
                self.downloadIndicator.isUserInteractionEnabled = false
            }
            else
            {
                self.progressView.isHidden = true
                self.downloadIndicator.isUserInteractionEnabled = true
            }
        }
    }
    
    public func setupProgress(isInitial : Bool){
        progressView.wrapperColor = UIColor(red: 216/255, green: 214/255, blue: 215/255, alpha: 1.0)
        progressView.progressColor = UIColor(red: 90/255, green: 88/255, blue: 85/255, alpha: 1.0)
        progressView.wrapperArcWidth = 2.0
        progressView.progressArcWidth = 2.5
        if(isInitial)
        {
            progressView.setProgress(0.0, animated: true)
        }
        downloadIndicator.tintColor = UIColor(red: 90/255, green: 88/255, blue: 85/255, alpha: 1.0)
    }
    public func setPercentage(_ value:CGFloat){
        progressView.setProgress(value, animated: true)
    }
}
