//
//  QrcodeViewController.swift
//
//
//  Created by Casp iOS on 06/03/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit
import JSSAlertView

class QrcodeViewController: UIViewController {
    var scanner:QRCode!
    
    @IBOutlet weak var ScannerView: UIView!
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.isIphoneX {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight_iPhoneX
        } else {
            topViewHeightConstraint.constant = Constant.sharedinstance.NavigationBarHeight
        }
        addNotificationListener()
        if !Platform.isSimulator {
            scanner=QRCode()
            scanner.prepareScan(ScannerView) { (SiteCode) in
                let msisdn:String=Themes.sharedInstance.setPhoneTxt(Themes.sharedInstance.Getuser_id());
                if(SocketIOManager.sharedInstance.socket.status == .connected)
                {
                    self.scanner.stopScan()
                    let param:[String:Any]=["_id":"\(Themes.sharedInstance.Getuser_id())","msisdn":"\(msisdn)","random":SiteCode]
                    print("the param is \(param)")
                    SocketIOManager.sharedInstance.qrCode = SiteCode
                    SocketIOManager.sharedInstance.EmitQRdata(Param: param)
                }
                else
                {
                    self.view.makeToast(message: Constant.sharedinstance.ErrorMessage, duration: 3, position: HRToastActivityPositionDefault)
                }
            }
        }
        // Do any additional setup after loading the view.
        detailLbl.text = NSLocalizedString("Go to", comment:"note")  + webUrl + NSLocalizedString("on your computer and scan the QR code", comment:"no")
    }
    func isConnectedToNetwork() -> Bool {
        return (UIApplication.shared.delegate as! AppDelegate).IsInternetconnected
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !Platform.isSimulator {
            self.scanner.startScan()
        }
    }
    
    @IBAction func DidClickBack(_ sender: Any) {
        self.pop(animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addNotificationListener() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Constant.sharedinstance.qrResponse), object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            let success : Bool = ((notify.object as! [String : Any])["success"] as! NSString).boolValue
            if(success)
            {
                weak.pop(animated: true)
            }
            else
            {
                _ = JSSAlertView().show(weak,title: Themes.sharedInstance.GetAppname(),text: "We could not sign you in to \(Themes.sharedInstance.GetAppname()) Web/Desktop.\n Please try again later." ,buttonText: "OK",color: CustomColor.sharedInstance.alertColor)
                weak.pop(animated: true)
            }
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}
