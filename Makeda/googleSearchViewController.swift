//
//  googleSearchViewController.swift
//  Makeda
//
//  Created by Brian on 2019/8/25.
//  Copyright © 2019 breadcrumbs.tw. All rights reserved.
//

import UIKit
import CoreData
import WebKit

class googleSearchViewController: UIViewController, WKNavigationDelegate{
    let debug = 0
    let fullSize = UIScreen.main.bounds.size
    var HeaderY = 30
    let goBackButtonID = 3001
    var mForwardBtn : UIButton?
    var mBackBtn : UIButton?
    var googleSearchWebView :WKWebView!
    var myActivityIndicator:UIActivityIndicatorView!
    var keywords:[String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        go()
    }
    
    override func viewDidLoad() {
        goBackBtn()
        webViewLoad()
    }
    
    func resetKeywords() {
        keywords.removeAll()
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        if googleSearchWebView?.goBack() == nil {
            print("No more page to back")
        }

    }

    @IBAction func forwardAction(_ sender: UIButton) {
        if googleSearchWebView?.goForward() == nil {
            print("No more page to forward")
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
        myActivityIndicator.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
        myActivityIndicator.stopAnimating()//startAnimating()
        if let webView = googleSearchWebView {
            mForwardBtn!.isEnabled = webView.canGoForward
            mBackBtn!.isEnabled = webView.canGoBack
        }
    }
    
    func webViewLoad() {
        googleSearchWebView = WKWebView(frame: CGRect(
            x: 0, y: HeaderY + 30 + 50,
            width: Int(fullSize.width),
            height: Int(fullSize.height)))
        googleSearchWebView.navigationDelegate = self
        self.view.addSubview(googleSearchWebView)
        
        // 建立環狀進度條
        myActivityIndicator = UIActivityIndicatorView(
            activityIndicatorStyle:.gray)
        myActivityIndicator.center = CGPoint(
            x: fullSize.width * 0.5,
            y: fullSize.height * 0.5)
        self.view.addSubview(myActivityIndicator);
        
        mForwardBtn = UIButton(
            frame: CGRect(x: Int(fullSize.width - (8+60)), y: HeaderY + 30, width: 60, height: 50))
        mForwardBtn!.setTitle("下一頁", for: .normal)
        mForwardBtn!.setTitleColor(UIColor.black, for: .normal)
        mForwardBtn!.backgroundColor = UIColor.clear
        // 按鈕是否可以使用
        mForwardBtn!.isEnabled = true
        
        // 按鈕按下後的動作
        mForwardBtn!.addTarget(
            self,
            action: #selector(googleSearchViewController.forwardAction),
            for: .touchUpInside)
        
        self.view.addSubview(mForwardBtn!)
        
        mBackBtn = UIButton(
            frame: CGRect(x: 5, y: HeaderY + 30, width: 60, height: 50))
        mBackBtn!.setTitle("上一頁", for: .normal)
        mBackBtn!.setTitleColor(UIColor.black, for: .normal)
        mBackBtn!.backgroundColor = UIColor.clear
        // 按鈕是否可以使用
        mBackBtn!.isEnabled = true
        
        // 按鈕按下後的動作
        mBackBtn!.addTarget(
            self,
            action: #selector(googleSearchViewController.backAction),
            for: .touchUpInside)
        
        self.view.addSubview(mBackBtn!)
        
        go()
    }
    
    func go()
    {
        var search_str = ""
        //print("keywords : ", keywords)
        for k in (keywords) {
            if (search_str.count == 0) {
                search_str = k
            } else {
                search_str = "\(search_str)+\(k)"
            }
        }
        let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
        let escapedString = search_str.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!
        if self.debug == 1 {
            print("search_str : ",search_str)
            print("escapedString : ",escapedString)
        }
        let url_str = "https://www.google.com/search?q=\(escapedString)"
        if let url = URL(string: url_str)//.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        {
            if self.debug == 1 {
                print("url : ",url)
            }
            let theRequest = NSMutableURLRequest(url:url, cachePolicy:NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval:15.0)
            self.googleSearchWebView.load(theRequest as URLRequest)
        } else {
            if self.debug == 1 {
                print("Url is null")
            }
        }
    }
    
    func goBackBtn()
    {
        let backButton = UIButton(
            frame: CGRect(x: 5, y: HeaderY, width: 30, height: 30))
        backButton.setTitle("＜", for: .normal)
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.backgroundColor = UIColor.clear
        //backButton.setImage(UIImage(named: "if_back@x3"), for: .normal)
        backButton.tag = goBackButtonID
        
        // 按鈕是否可以使用
        backButton.isEnabled = true
        
        // 按鈕按下後的動作
        backButton.addTarget(
            self,
            action: #selector(googleSearchViewController.goBack),
            for: .touchUpInside)
        
        self.view.addSubview(backButton)
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion:nil)
    }
}

extension URL{
    
    static func initPercent(string:String) -> URL
    {
        let urlwithPercentEscapes = string.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let url = URL.init(string: urlwithPercentEscapes!)
        return url!
    }
}

