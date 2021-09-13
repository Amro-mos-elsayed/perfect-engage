//
//  DemoVC.swift
//
//
//  Created by Casperon iOS on 29/12/17.
//  Copyright © 2017 CASPERON. All rights reserved.
//

import UIKit

class DemoVC: UIViewController, UIScrollViewDelegate {
    
    let scrollView = UIScrollView(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height))
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var signupBtn: UIButton!
    var Images:[UIImage] = [#imageLiteral(resourceName: "demo1"), #imageLiteral(resourceName: "demo2"), #imageLiteral(resourceName: "demo3")]
    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = signupBtn.backgroundColor
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        
        self.view.addSubview(scrollView)
        
        self.view.bringSubviewToFront(pageControl)
        
        self.view.bringSubviewToFront(signupBtn)
        
        signupBtn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        signupBtn.layer.shadowOffset = CGSize(width: 0, height: 5)
        signupBtn.layer.shadowOpacity = 0.8
        signupBtn.layer.shadowRadius = 15.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        

        for index in 0..<3 {
            
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.size = self.scrollView.frame.size
            
            let subView = UIImageView(frame: frame)
            subView.image = Images[index]
            self.scrollView.addSubview(subView)
        }
        
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.size.width * 3,height: 0)
        pageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)
        
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(AnimatePaging), userInfo: nil, repeats: true)
    }
    
    // MARK : TO CHANGE WHILE CLICKING ON PAGE CONTROL
    @IBAction func changePage(sender: AnyObject) {
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        scrollView.setContentOffset(CGPoint(x:x, y:-20), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    @objc func AnimatePaging()
    {
        if(pageControl.currentPage + 1 < 3)
        {
            let x = CGFloat(pageControl.currentPage + 1) * scrollView.frame.size.width
            scrollView.setContentOffset(CGPoint(x:x, y:-20), animated: true)
            pageControl.currentPage = pageControl.currentPage + 1
        }
        else
        {
            let x = 0
            scrollView.setContentOffset(CGPoint(x:x, y:-20), animated: true)
            pageControl.currentPage = 0
        }
    }
    
    @IBAction func signup(sender: AnyObject) {
        timer?.invalidate()
        timer = nil
        let signinVC = self.storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.pushView(signinVC, animated: true)
    }
}
