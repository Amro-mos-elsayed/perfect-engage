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
    
    func listenToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    func setupUI() {
        borderedViews.forEach { view in
            view.layer.cornerRadius = 25
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.lightGray.cgColor
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
    
    func login(uid: String, password: String) {
        loginRequest(uid: uid, password: password) { user in
            let fullMobileNum = user.mobile!
            let mobileNum = fullMobileNum.substring(from: 3)
            
            self.navigateToLoginVC(phoneNumber: mobileNum, code: "", userName: user.fullName)
        }
    }
    
    func navigateToLoginVC(phoneNumber: String?, code: String?, userName: String?) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryBoard.instantiateViewController(withIdentifier: "LoginVCID") as! LoginVC
        vc.phoneNo = phoneNumber
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
                    self.navigateToLoginVC(phoneNumber: "", code: "", userName: "")
                    #endif
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                Themes.sharedInstance.ShowNotification("error has been occurred".localized(), false)
                #if DEBUG
                self.navigateToLoginVC(phoneNumber: "", code: "", userName: "")
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


