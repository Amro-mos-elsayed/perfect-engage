//
//  PickerVC.swift
//
//
//  Created by Prem Mac on 05/01/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit
protocol secretTime : class {
    func time(time:String)
}

class PickerVC: UIViewController {
    
    
    @IBOutlet weak var picker: UIPickerView!
    var pickerDataSource:NSMutableArray = NSMutableArray()
    weak var delegate:secretTime!
    var time:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.layer.borderWidth = 1.0
        picker.layer.borderColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0).cgColor
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func expiration_time(_ sender: UIButton) {
        if(self.time == "")
        {
            self.time = "5 seconds"
        }
        self.delegate.time(time: self.time)
        self.dismissView(animated: true, completion: nil)
    }
    
    
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismissView(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension PickerVC : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.time = (pickerDataSource[row] as? String)!
    }
}


