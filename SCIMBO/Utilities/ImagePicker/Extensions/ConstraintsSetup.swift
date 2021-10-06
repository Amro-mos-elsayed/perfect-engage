import UIKit

// MARK: - BottomContainer autolayout

extension BottomContainerView {
    
    func setupConstraints() {
        
        for attribute: NSLayoutConstraint.Attribute in [.centerX, .centerY] {
            addConstraint(NSLayoutConstraint(item: pickerButton, attribute: attribute,
                                             relatedBy: .equal, toItem: self, attribute: attribute,
                                             multiplier: 1, constant: 0))
            
            addConstraint(NSLayoutConstraint(item: borderPickerButton, attribute: attribute,
                                             relatedBy: .equal, toItem: self, attribute: attribute,
                                             multiplier: 1, constant: 0))
        }
        
        for attribute: NSLayoutConstraint.Attribute in [.width, .left, .top] {
            addConstraint(NSLayoutConstraint(item: topSeparator, attribute: attribute,
                                             relatedBy: .equal, toItem: self, attribute: attribute,
                                             multiplier: 1, constant: 0))
        }
        
        for attribute: NSLayoutConstraint.Attribute in [.width, .height] {
            addConstraint(NSLayoutConstraint(item: pickerButton, attribute: attribute,
                                             relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1, constant: ButtonPicker.Dimensions.buttonSize))
            
            addConstraint(NSLayoutConstraint(item: borderPickerButton, attribute: attribute,
                                             relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1, constant: ButtonPicker.Dimensions.buttonBorderSize))
            
            addConstraint(NSLayoutConstraint(item: stackView, attribute: attribute,
                                             relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1, constant: ImageStackView.Dimensions.imageSize))
        }
        
        addConstraint(NSLayoutConstraint(item: doneButton, attribute: .centerY,
                                         relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: stackView, attribute: .centerY,
                                         relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1, constant: -2))
        
        let screenSize = Helper.screenSizeForOrientation()
        
        addConstraint(NSLayoutConstraint(item: doneButton, attribute: .centerX,
                                         relatedBy: .equal, toItem: self, attribute: .right,
                                         multiplier: 1, constant: -(screenSize.width - (ButtonPicker.Dimensions.buttonBorderSize + screenSize.width)/2)/2))
        
        addConstraint(NSLayoutConstraint(item: stackView, attribute: .centerX,
                                         relatedBy: .equal, toItem: self, attribute: .left,
                                         multiplier: 1, constant: screenSize.width/4 - ButtonPicker.Dimensions.buttonBorderSize/3))
        
        addConstraint(NSLayoutConstraint(item: topSeparator, attribute: .height,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1, constant: 1))
        
        
        addConstraint(NSLayoutConstraint(item: UserDescriptionLabel, attribute: .centerX,
                                         relatedBy: .equal, toItem: self, attribute: .centerX,
                                         multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: UserDescriptionLabel, attribute: .top,
                                         relatedBy: .equal, toItem: borderPickerButton, attribute: .bottom,
                                         multiplier: 1, constant: 0))
        
        
        
        addConstraint(NSLayoutConstraint(item: galleryButton, attribute: .left,
                                         relatedBy: .equal, toItem: self, attribute: .left,
                                         multiplier: 1, constant: RotateCameraDimensions.leftOffset))
        
        addConstraint(NSLayoutConstraint(item: galleryButton, attribute: .centerY,
                                         relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: galleryButton, attribute: .width,
                                         relatedBy: .equal, toItem: self, attribute: .height,
                                         multiplier: 0.35, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: galleryButton, attribute: .height,
                                         relatedBy: .equal, toItem: galleryButton, attribute: .width,
                                         multiplier: 1, constant: 0))
        
        
        if configuration.canRotateCamera {
            addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .right,
                                             relatedBy: .equal, toItem: self, attribute: .right,
                                             multiplier: 1, constant: RotateCameraDimensions.rightOffset))
            
            //        addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .left,
            //                                         relatedBy: .equal, toItem: self, attribute: .left,
            //                                         multiplier: 1, constant: Dimensions.leftOffset))
            
            addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .centerY,
                                             relatedBy: .equal, toItem: self, attribute: .centerY,
                                             multiplier: 1, constant: 0))
            
            addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .width,
                                             relatedBy: .equal, toItem: galleryButton, attribute: .height,
                                             multiplier: 1, constant: 0))
            
            addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .height,
                                             relatedBy: .equal, toItem: rotateCamera, attribute: .width,
                                             multiplier: 1, constant: 0))
        }
    }
}

// MARK: - TopView autolayout
//MARK:- changed by ragu

extension TopView {
    
    func setupConstraints() {
        //    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .left,
        //      relatedBy: .equal, toItem: self, attribute: .left,
        //      multiplier: 1, constant: Dimensions.leftOffset))
        
        addConstraint(NSLayoutConstraint(item: flashButton, attribute: .right,
                                         relatedBy: .equal, toItem: self, attribute: .right,
                                         multiplier: 1, constant: Dimensions.rightOffset))
        
        
        addConstraint(NSLayoutConstraint(item: flashButton, attribute: .centerY,
                                         relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: flashButton, attribute: .width,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1, constant: 55))
        
        //add
        
        addConstraint(NSLayoutConstraint(item: flashButton, attribute: .height,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1, constant: 55))
        
        //recordViewConstraint
        recordingLabel.sizeToFit()
        addConstraint(NSLayoutConstraint(item: recordingLabel, attribute: .leading,
                                         relatedBy: .equal, toItem: self, attribute: .centerX,
                                         multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: recordingLabel, attribute: .centerY,
                                         relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1, constant: 0))
        
        
        addConstraint(NSLayoutConstraint(item: recordingView, attribute: .centerY,
                                         relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: recordingView, attribute: .width,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1, constant: 20))
        
        addConstraint(NSLayoutConstraint(item: recordingView, attribute: .height,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1, constant: 20))
        addConstraint(NSLayoutConstraint(item: recordingView, attribute: .right,
                                         relatedBy: .equal, toItem: recordingLabel, attribute: .left,
                                         multiplier: 1, constant: -5))
        
        recordingView.layer.cornerRadius = 20/2
        
        
        addConstraint(NSLayoutConstraint(item: closeButton, attribute: .left,
                                         relatedBy: .equal, toItem: self, attribute: .left,
                                         multiplier: 1, constant: Dimensions.leftOffset))
        
        addConstraint(NSLayoutConstraint(item: closeButton, attribute: .top,
                                         relatedBy: .equal, toItem: self, attribute: .top,
                                         multiplier: 1, constant: Dimensions.leftOffset))
        
        addConstraint(NSLayoutConstraint(item: closeButton, attribute: .width,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1, constant: 40))
        
        addConstraint(NSLayoutConstraint(item: closeButton, attribute: .height,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1, constant: 40))
        
        
        //MARK:- changed by ragu
        //removed
        //    if configuration.canRotateCamera {
        ////      addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .right,
        ////        relatedBy: .equal, toItem: self, attribute: .right,
        ////        multiplier: 1, constant: Dimensions.rightOffset))
        //
        //        addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .left,
        //                                         relatedBy: .equal, toItem: self, attribute: .left,
        //                                         multiplier: 1, constant: Dimensions.leftOffset))
        //
        //      addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .centerY,
        //        relatedBy: .equal, toItem: self, attribute: .centerY,
        //        multiplier: 1, constant: 0))
        //
        //      addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .width,
        //        relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
        //        multiplier: 1, constant: 55))
        //
        //      addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .height,
        //        relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
        //        multiplier: 1, constant: 55))
        //    }
    }
}

// MARK: - Controller autolayout

extension ImagePickerController {
    
    func setupConstraints() {
        let attributes: [NSLayoutConstraint.Attribute] = [.bottom, .right, .width]
        let topViewAttributes: [NSLayoutConstraint.Attribute] = [.left, .top, .width]
        
        for attribute in attributes {
            if UIDevice.isIphoneX &&  attribute == .bottom{
                view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: attribute,
                                                      relatedBy: .equal, toItem: view, attribute: attribute,
                                                      multiplier: 1, constant: -20))
            } else {
                view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: attribute,
                                                      relatedBy: .equal, toItem: view, attribute: attribute,
                                                      multiplier: 1, constant: 0))
            }
            
            
        }
        
        for attribute: NSLayoutConstraint.Attribute in [.left, .top, .width] {
            view.addConstraint(NSLayoutConstraint(item: cameraController.view, attribute: attribute,
                                                  relatedBy: .equal, toItem: view, attribute: attribute,
                                                  multiplier: 1, constant: 0))
        }
        
        for attribute in topViewAttributes {
            if UIDevice.isIphoneX &&  attribute == .top{
                view.addConstraint(NSLayoutConstraint(item: topView, attribute: attribute,
                                                      relatedBy: .equal, toItem: self.view, attribute: attribute,
                                                      multiplier: 1, constant: 44))
            } else {
                view.addConstraint(NSLayoutConstraint(item: topView, attribute: attribute,
                                                      relatedBy: .equal, toItem: self.view, attribute: attribute,
                                                      multiplier: 1, constant: 0))
            }
            
        }
        
        view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: .height,
                                              relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                              multiplier: 1, constant: BottomContainerView.Dimensions.height))
        
        view.addConstraint(NSLayoutConstraint(item: topView, attribute: .height,
                                              relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                              multiplier: 1, constant: TopView.Dimensions.height))
        
        view.addConstraint(NSLayoutConstraint(item: cameraController.view, attribute: .height,
                                              relatedBy: .equal, toItem: view, attribute: .height,
                                              multiplier: 1, constant: 0))
        //    -BottomContainerView.Dimensions.height
    }
}

extension ImageGalleryViewCell {
    
    func setupConstraints() {
        
        for attribute: NSLayoutConstraint.Attribute in [.width, .height, .centerX, .centerY] {
            addConstraint(NSLayoutConstraint(item: imageView, attribute: attribute,
                                             relatedBy: .equal, toItem: self, attribute: attribute,
                                             multiplier: 1, constant: 0))
            
            addConstraint(NSLayoutConstraint(item: selectedImageView, attribute: attribute,
                                             relatedBy: .equal, toItem: self, attribute: attribute,
                                             multiplier: 1, constant: 0))
        }
    }
}

extension ButtonPicker {
    
    func setupConstraints() {
        let attributes: [NSLayoutConstraint.Attribute] = [.centerX, .centerY]
        
        for attribute in attributes {
            addConstraint(NSLayoutConstraint(item: numberLabel, attribute: attribute,
                                             relatedBy: .equal, toItem: self, attribute: attribute,
                                             multiplier: 1, constant: 0))
        }
    }
}




