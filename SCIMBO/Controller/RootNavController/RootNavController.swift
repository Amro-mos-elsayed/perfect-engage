//
//  RootNavController.swift
//
//
//  Created by Casp iOS on 12/04/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class RootNavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var shouldAutorotate: Bool {
        if(topViewController?.isKind(of: EditViewController.classForCoder()))!
        {
        return false
        }
        else
        {
            return true
        }
    }
    
    
    
     override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        if(topViewController?.isKind(of: EditViewController.classForCoder()))!
        {
            return UIInterfaceOrientationMask.portrait
        }
        else
        {
            return UIInterfaceOrientationMask.all
        }

    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
