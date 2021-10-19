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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        listenToKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if DEBUG
        userIdTextField.text = "112233"
        PasswordIdTextField.text = "P@$$w0rd"
        #endif
    }
    
    func listenToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
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
        bottomConstraint.constant = keyboardHeight
        print(keyboardHeight)
    }
    
    @objc func keyBoardWillHide(_ notification: Notification) {
        bottomConstraint.constant = 0
    }


    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        login(uid: userIdTextField.text ?? "" , password: PasswordIdTextField.text ?? "")
    }
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.pop(animated: false)
    }
    
    func login(uid: String, password: String) {
        loginRequest(uid: uid, password: password) { user in
            var mobileNum = user.mobile!//.substring(from: 3)
            if mobileNum.count > 11{
                mobileNum = mobileNum.substring(from: 3)
            }
            let email: String = user.fullName!
            let name = user.fullName
            self.navigateToLoginVC(phoneNumber: mobileNum, userName: name!,email: email)
        }
    }
    
    func navigateToLoginVC(phoneNumber: String, userName: String, email: String) {
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
        let parameters: Parameters = ["employeeId" : uid ,"password" : password]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { response in
            Themes.sharedInstance.RemoveactivityView(View: self.view)
            switch response.result {
            case .success(let data):
                let jsondecoder = JSONDecoder.init()
                let loginModel = try? jsondecoder.decode(LoginModel.self, from: data)
                if let user = loginModel?.resultObject {
                    completion(user)
                }else {
                    Themes.sharedInstance.ShowNotification(loginModel?.resultMessage ?? "error has been occurred".localized() , false)
                    #if DEBUG
                    self.navigateToLoginVC(phoneNumber: "", userName: "", email: "email@email.com")
                    #endif
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                Themes.sharedInstance.ShowNotification("error has been occurred".localized(), false)
                #if DEBUG
                self.navigateToLoginVC(phoneNumber: "", userName: "", email: "email@email.com")
                #endif
            }
        }
    }
    
}






// MARK: - Welcome
struct LoginModel: Codable {
    let resultMessage, moreDetails: String?
    let resultObject: ResultObject?

    enum CodingKeys: String, CodingKey {
        case resultMessage = "ResultMessage"
        case moreDetails = "MoreDetails"
        case resultObject = "ResultObject"
    }
}

// MARK: - ResultObject
struct ResultObject: Codable {
    let firstNameAr, middleNameAr, lastNameAr, firstNameEn: String?
    let middleNameEn, lastNameEn, fullName, gender: String?
    let nationalID, nationality, mobile, title: String?
    let department, departmentCode, locationAr, locationEn: String?
    let photo: String?

    enum CodingKeys: String, CodingKey {
        case firstNameAr = "FirstNameAr"
        case middleNameAr = "MiddleNameAr"
        case lastNameAr = "LastNameAr"
        case firstNameEn = "FirstNameEn"
        case middleNameEn = "MiddleNameEn"
        case lastNameEn = "LastNameEn"
        case fullName = "FullName"
        case gender = "Gender"
        case nationalID = "NationalId"
        case nationality = "Nationality"
        case mobile = "Mobile"
        case title = "Title"
        case department = "Department"
        case departmentCode = "DepartmentCode"
        case locationAr = "LocationAr"
        case locationEn = "LocationEn"
        case photo = "Photo"
    }
}
