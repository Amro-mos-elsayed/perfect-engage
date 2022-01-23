//
//  LoginViewController.swift
//  Raad
//
//  Created by Ahmed Labeeb on 8/8/21.
//  Copyright © 2021 CASPERON. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    
    @IBOutlet var borderedViews: [UIView]!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var PasswordIdTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    //Constants
    let bottomPadding: CGFloat = 34
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        listenToKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if DEBUG
        userIdTextField.text = "alabeeb@2p.com.sa"
        PasswordIdTextField.text = "Aa.2p123!"
        #endif
    }
    
    func listenToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupUI() {
        borderedViews.forEach { view in
            view.layer.cornerRadius = 25
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.lightGray.cgColor
            if view is UIButton {
                view.layer.borderWidth = 0
            }
        }
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func keyBoardWillShow(_ notification: Notification) {
        let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        bottomConstraint.constant = keyboardHeight + bottomPadding
        print(keyboardHeight)
    }
    
    @objc func keyBoardWillHide(_ notification: Notification) {
        bottomConstraint.constant = bottomPadding
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        login(uid: userIdTextField.text ?? "" , password: PasswordIdTextField.text ?? "")
    }
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.pop(animated: false)
    }
    
    func login(uid: String, password: String) {
        loginRequest(uid: uid, password: password) { user in
            var mobileNum = user.telephoneNumber!//.substring(from: 3)
            if mobileNum.count > 11{
                mobileNum = mobileNum.substring(from: 3)
            }
            let email: String = user.mail!
            self.navigateToLoginVC(phoneNumber: mobileNum, code: "", userName: user.displayName!,email: email)
        }
    }
    
    func navigateToLoginVC(phoneNumber: String, code: String, userName: String, email: String) {
       // let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = FullLoginViewController.init()
        vc.phoneNo = phoneNumber
        vc.userEmail = email
        vc.userName = userName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    func loginRequest(uid: String, password: String, completion:@escaping ((ResultObject) -> ())) {
        Themes.sharedInstance.activityView(View: self.view)
        let url = BaseUrl + "/activeDirectory"
        let parameters: Parameters = ["email" : uid ,"password" : password]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { response in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            switch response.result {
            case .success(let data):
                let jsondecoder = JSONDecoder.init()
                let loginModel = try? jsondecoder.decode(LoginModel.self, from: data)
                if let user = loginModel?.resultObject, loginModel?.authorized == true {
                    completion(user)
                }else {
                    Themes.sharedInstance.ShowNotification("error has been occurred".localized() , false)
                    #if DEBUG
                    //self.navigateToLoginVC(phoneNumber: "", code: "", userName: "", email: "email@email.com")
                    #endif
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                Themes.sharedInstance.ShowNotification("error has been occurred".localized(), false)
                #if DEBUG
                self.navigateToLoginVC(phoneNumber: "", code: "", userName: "", email: "email@email.com")
                #endif
            }
        }
    }
    
}






// MARK: - Welcome
struct LoginModel: Codable {
    let authorized: Bool
    let resultObject: ResultObject?

    enum CodingKeys: String, CodingKey {
        case resultObject = "data"
        case authorized
    }
}

// MARK: - ResultObject
struct ResultObject: Codable {
    let telephoneNumber,displayName,mail: String?

    enum CodingKeys: String, CodingKey {
        case telephoneNumber,displayName,mail
    }
}
