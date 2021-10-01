//
//  LoginTypeViewController.swift
//  Raad
//
//  Created by Ahmed Labeeb on 9/30/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit

class LoginTypeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func userLogin(_ sender: UIButton) {
        let vc = LoginViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
