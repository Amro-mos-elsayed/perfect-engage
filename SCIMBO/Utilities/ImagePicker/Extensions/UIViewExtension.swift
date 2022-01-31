//
//  UIViewExtension.swift
//  SCIMBO
//
//  Created by 2p on 1/31/22.
//  Copyright © 2022 CASPERON. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func makeSecure() {
        DispatchQueue.main.async {
            let field = UITextField()
            field.isSecureTextEntry = true
            self.addSubview(field)
            field.isUserInteractionEnabled = false
            field.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            field.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.layer.superlayer?.addSublayer(field.layer)
            field.layer.sublayers?.first?.addSublayer(self.layer)
            
        }
    }
}
