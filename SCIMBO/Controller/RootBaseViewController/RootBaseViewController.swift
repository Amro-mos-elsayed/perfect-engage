//
//  RootBaseViewController.swift
//
//
//  Created by CASPERON on 19/12/16.
//  Copyright © 2016 CASPERON. All rights reserved.
//

import UIKit


class RootBaseViewController: UIViewController {
    static let sharedInstance = RootBaseViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Themes.sharedInstance.saveLanguage(str:Themes.sharedInstance.kLanguage as NSString)
        Themes.sharedInstance.SetLanguageToApp()
    }
}
