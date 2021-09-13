//
//  DocViewController.swift
//
//
//  Created by MV Anand Casp iOS on 10/07/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import WebKit

class DocViewController: UIViewController {
    var webViewURL:String = String()
    var webViewTitle:String = String()
    
    @IBOutlet weak var doc_nameLbl: CustomLblFont!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var WKView: WKWebView!
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        
        doc_nameLbl.text = webViewTitle
        let targetURL:URL = URL(fileURLWithPath: webViewURL)
        let request = NSURLRequest(url: targetURL)
        WKView.load(request as URLRequest)
        // Do any additional setup after loading the view.
    }
    
    func SetWebView(str:String)
    {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didclickBackBtn(_ sender: Any) {
        self.pop(animated: true)
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        let shareUrl = URL(fileURLWithPath: webViewURL)
        let imageShare = [ shareUrl ]
              let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities:nil)
               
           // activityViewController.popoverPresentationController?.sourceView = self.view
            //self.present(activityViewController, animated: true, completion: nil)
            self.presentView(activityViewController, animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

