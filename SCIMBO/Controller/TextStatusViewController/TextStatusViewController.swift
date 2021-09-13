//
//  TextStatusViewController.swift
//
//
//  Created by raguraman on 01/11/18.
//  Copyright © 2018 CASPERON. All rights reserved.
//

import UIKit



protocol TextStatusViewControllerDelegate : class{
    func sendStatus(text: String, bgColor: String, fontName: String)
}

class TextStatusViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var mainTextTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fontButton: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var sendViewBottomConstraint: NSLayoutConstraint!
    
    
    fileprivate let colorArray = [UIColor(hexString: "#233540"),
                                  UIColor(hexString: "#7ACCA5"),
                                  UIColor(hexString: "#6D267D"),
                                  UIColor(hexString: "#5696FE"),
                                  UIColor(hexString: "#7D8FA3"),
                                  UIColor(hexString: "#72666B"),
                                  UIColor(hexString: "#56C9FF"),
                                  UIColor(hexString: "#26C4DB"),
                                  UIColor(hexString: "#FE7A6B"),
                                  UIColor(hexString: "#8C688F"),
                                  UIColor(hexString: "#C79ECC"),
                                  UIColor(hexString: "#B5B226"),
                                  UIColor(hexString: "#EFB230"),
                                  UIColor(hexString: "#AD8772"),
                                  UIColor(hexString: "#782138"),
                                  UIColor(hexString: "#C1A040"),
                                  UIColor(hexString: "#A52B70"),
                                  UIColor(hexString: "#8294C9"),
                                  UIColor(hexString: "#54C166"),
                                  UIColor(hexString: "#FF898C")]
    
    fileprivate let fontArray = [UIFont(name: "Roboto-Medium", size: 40.0), UIFont(name: "TimesNewRomanPSMT", size: 40.0), UIFont(name: "Norican-Regular", size: 40.0), UIFont(name: "Bryndan-Write", size: 40.0), UIFont(name: "Oswald-Heavy", size: 40.0)]

    fileprivate let placeholderText = languageHandler.ApplicationLanguage() == "ar" ?  "اكتب حالتك": "Type a status"
    weak var delegate: TextStatusViewControllerDelegate?
    
    var selectedColorIndex = 0{
        didSet{
            setBGColor()
        }
    }
    var selectedFontIndex = 0{
        didSet{
            setFontStyle()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationListener()
        self.setBGColor()
        self.setFontStyle()
        setupTextView(contentTextView, placeHolder: placeholderText)
        setShareButton()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        contentTextView.sizeToFit()
        
        if contentContainerView.bounds.height <= contentTextView.contentSize.height{
            self.contentTextView.isScrollEnabled = true
        }else{
            self.contentTextView.isScrollEnabled = false
        }
    }
    
    private func setBGColor(){
        guard selectedColorIndex < colorArray.count else{return}
        self.view?.backgroundColor = colorArray[selectedColorIndex]
    }
    
    private func setFontStyle(){
        guard selectedFontIndex < fontArray.count else{return}
        self.contentTextView?.font = fontArray[selectedFontIndex]?.withSize((self.contentTextView?.font?.pointSize)!)
        self.fontButton?.titleLabel?.font = fontArray[selectedFontIndex]?.withSize((self.fontButton?.titleLabel?.font?.pointSize)!)
    }
    
    fileprivate func setupTextView(_ sender: UITextView, placeHolder: String){
        sender.text = placeHolder
        sender.autocorrectionType = .no
        sender.textColor = UIColor.white.withAlphaComponent(0.8)
        sender.selectedTextRange = sender.textRange(from: sender.beginningOfDocument, to: sender.beginningOfDocument)
        sender.delegate = self
    }
    
    fileprivate func setShareButton(){
        let postText = contentTextView.text == placeholderText ? "" : contentTextView.text
        _ = postText?.replacingOccurrences(of: " ", with: "")
        if postText != ""{
            sendButton.isEnabled = true
        }else{
            sendButton.isEnabled = false
        }
    }
    
    @IBAction func didClickColor(_ sender: UIButton) {
        if selectedColorIndex+1 < colorArray.count{
            selectedColorIndex += 1
        }else{
            selectedColorIndex = 0
        }
    }
    
    @IBAction func didClickFont(_ sender: UIButton) {
        
        if selectedFontIndex+1 < fontArray.count{
            selectedFontIndex += 1
        }else{
            selectedFontIndex = 0
        }
    }
    
    @IBAction func didClickCloseButton(_ sender: UIButton) {
        self.pop(animated: true)
    }
    
    @IBAction func didClickSendButton(_ sender: UIButton) {
        var postText = contentTextView.text == placeholderText ? "" : contentTextView.text
        postText = postText?.trimmingCharacters(in: .whitespacesAndNewlines)

        delegate?.sendStatus(text: Themes.sharedInstance.CheckNullvalue(Passed_value: postText), bgColor: Themes.sharedInstance.CheckNullvalue(Passed_value: view.backgroundColor?.hexString), fontName: Themes.sharedInstance.CheckNullvalue(Passed_value: contentTextView.font?.fontName))
        self.pop(animated: true)
    }
    
    func addNotificationListener() {
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.keyboardWillShow(notification:notify)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main) { [weak self] (notify: Notification) in
            guard let weak = self else { return }
            weak.keyboardDidHide(notification:notify)
        }
    }
    
    func removeNotificationListener() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        removeNotificationListener()
    }

}

//MARK:- keyboard related function
extension TextStatusViewController{
    @objc func keyboardWillShow(notification: Notification) {
        handleKeyBoard(with: notification, isHidding: false)
    }
    
    @objc func keyboardDidHide(notification: Notification) {
        handleKeyBoard(with: notification, isHidding: true)
    }
    
    private func handleKeyBoard(with notification: Notification, isHidding:Bool){
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
            
            self.view.setNeedsLayout()
            sendViewBottomConstraint.constant = isHidding ? 0 : (UIDevice.isIphoneX ? keyboardSize.height-34 : keyboardSize.height)
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            
        }
    }
}

extension TextStatusViewController: UITextViewDelegate{
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(textView.textColor == UIColor.white.withAlphaComponent(0.8))
        {
            textView.text = ""
        }
        let currentText:String = textView.text
        var updatedText = ""
        if(currentText == "")
        {
            updatedText = currentText.appending(text)
        }
        else
        {
            updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        }
        
        
        if updatedText.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            setupTextView(textView, placeHolder: placeholderText)
            setShareButton()
            return false
        }
        
        if contentContainerView.bounds.height <= contentTextView.contentSize.height{
            self.contentTextView.isScrollEnabled = true
        }else{
            self.contentTextView.isScrollEnabled = false
        }
        
        self.sendButton.isEnabled = true
        
        let tempTxt = textView.text
        textView.text = updatedText
        if(textView.numberOfLines() == 15 || updatedText.length > 600)
        {
            textView.text = tempTxt
            return false
        }
        textView.text = tempTxt
        
        DispatchQueue.main.async {
            self.contentTextView.textColor = UIColor.white
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if contentTextView.text == placeholderText {
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
    }
    

}

extension UIColor{
    var hexString: String {
        let colorRef = cgColor.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha
        
        var color = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
        
        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a)))
        }
        
        return color
    }
    
}
