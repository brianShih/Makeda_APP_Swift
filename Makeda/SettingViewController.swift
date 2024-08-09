//
//  ViewController.swift
//  Makeda
//
//  Created by Brian on 2017/7/12.
//  Copyright © 2017年 breadcrumbs.tw. All rights reserved.
//

import Alamofire
import UIKit
import GoogleMobileAds

class SettingViewController: UIViewController, UIScrollViewDelegate, GADBannerViewDelegate  {
    //, UIDocumentMenuDelegate, UIDocumentPickerDelegate
    let debug = 0
    let URL_USER_REGISTER = "TODO"
    let URL_USER_LOGIN = "TODO"
    let URL_USER_ACCOUNT_UPDATE = "TODO"
    let fullSize = UIScreen.main.bounds.size
    var versionLabel:UILabel?
    var versionText:UITextField?
    var userLabel:UILabel?
    var nameText:UITextField?
    var phoneText:UILabel?
    var emailText:UILabel?
    var loginEmail:UITextField?
    var loginPassword:UITextField?
    var registerEmail:UITextField?
    var registerPass:UITextField?
    var registerRePass:UITextField?
    var registerName:UITextField?
    var registerPhone:UITextField?
    var backupFuncLabel:UILabel?
    var backupButton:UIButton?
    var importFuncLabel:UILabel?
    var importButton:UIButton?
    var forgetPassButton:UIButton?
    var loginButton:UIButton?
    var logoutButton:UIButton?
    var resetPassTitle:UILabel?
    var resetPassButton:UIButton?
    var registerButton:UIButton?
    var editeValueCtrl:UIAlertController?
    var startXOffSet = 0
    let startYOffSet = 50
    var centerXOffSet = 0
    let centerYOffSet = 50
    let TextHight = 30
    var offsetY = 0
    //progressing value
    var myActivityIndicator:UIActivityIndicatorView!
    var bannerView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        defineViewOffset()
        versionInfoLoad()
        loadGoogleBannerAD()

        if !userInfoLoad()
        {
            loginNregisterFunLoad()
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(DashViewController.hideKeyboard(tapG:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func confirmLocalUserData() -> Bool
    {
        let myUserDefaults = UserDefaults.standard
        if let _ = myUserDefaults.object(forKey: "user_name"), let _ = myUserDefaults.object(forKey: "user_email"), let _ = myUserDefaults.object(forKey: "user_phone"), let _ = myUserDefaults.object(forKey: "user_power"), let _ = myUserDefaults.object(forKey: "user_status"), let _ = myUserDefaults.object(forKey: "user_activity_key")
        {
            return true
        }
        return false
    }
    
    func defineViewOffset()
    {
        startXOffSet = Int(fullSize.width * 0.04)
        centerXOffSet = Int(fullSize.width / 2)
    }
    

    func versionInfoLoad()
    {
        let verTitleStr = "運行版本"
        versionLabel = UILabel(frame: CGRect(x: startXOffSet, y: startYOffSet, width: 80, height: TextHight))
        versionLabel!.text = verTitleStr
        // 文字顏色
        versionLabel!.textColor = UIColor.black
        
        // 文字的字型與大小
        versionLabel!.font = UIFont(name: "Helvetica-Light", size: 20)
        
        // 設定文字位置 置左、置中或置右等等
        versionLabel!.textAlignment = NSTextAlignment.left
        
        // 文字行數
        versionLabel!.numberOfLines = 1
        //versionLab!.bounds = CGRect(
        //        x: startXOffSet, y: startYOffSet, width: 80, height: 50)
        self.view.addSubview(versionLabel!)
        
        // Get the current version from AppInfo
        let verTextWidth = 150
        
        var verStrCenterX = centerXOffSet + (centerXOffSet / 2)
        if Int(fullSize.width) < (verStrCenterX + verTextWidth)
        {
            verStrCenterX = centerXOffSet + (centerXOffSet / 4)
        }
        versionText = UITextField(frame: CGRect(x: verStrCenterX, y: centerYOffSet, width: 150, height: TextHight))
        
        // 輸入框的樣式 這邊選擇圓角樣式
        versionText!.borderStyle = .none //.roundedRect
        
        versionText!.font = UIFont(name: "Helvetica-Light", size: 20)
        
        versionText!.text = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        
        // 輸入文字的顏色
        versionText!.textColor = UIColor.gray
        
        
        // UITextField 的背景顏色
        versionText!.backgroundColor = UIColor.clear
        self.view.addSubview(versionText!)
    }

    func userInfoLoad() -> Bool
    {
        let myUserDefaults = UserDefaults.standard
        if let name = myUserDefaults.object(forKey: "user_name") as? String,
            let email = myUserDefaults.object(forKey: "user_email") as? String,
            let phone = myUserDefaults.object(forKey: "user_phone") as? String,
            let power = myUserDefaults.object(forKey: "user_power") as? Int,
            let status = myUserDefaults.object(forKey: "user_status") as? Int
        {
            let text = "嗨!         \(name)"
            offsetY = offsetY + TextHight + 5
            userLabel = UILabel(frame: CGRect(x: startXOffSet, y: startYOffSet + offsetY, width: 250, height: TextHight))
            userLabel!.text = text
            // 文字顏色
            userLabel!.textColor = UIColor.black
            // 文字的字型與大小
            userLabel!.font = UIFont(name: "Helvetica-Light", size: 20)
            // 設定文字位置 置左、置中或置右等等
            userLabel!.textAlignment = NSTextAlignment.left
            // 文字行數
            userLabel!.numberOfLines = 1
            self.view.addSubview(userLabel!)
            
            //offsetY = offsetY + TextHight + 5
            logoutButton = UIButton(
                frame: CGRect(x: Int(fullSize.width - 100), y: startYOffSet + offsetY, width: 60, height: TextHight))
            logoutButton!.setTitle("登出", for: .normal)
            logoutButton!.setTitleColor(UIColor.white, for: .normal)
            logoutButton!.layer.cornerRadius = 5.0
            logoutButton!.isEnabled = true
            logoutButton!.backgroundColor = UIColor(red: 0, green: 160/255, blue: 1, alpha: 0.8)
            logoutButton!.addTarget(
                self,
                action: #selector(logout_btn),
                for: .touchUpInside)
            self.view.addSubview(logoutButton!)

            offsetY = offsetY + TextHight + 5
            emailText = UILabel(frame: CGRect(x: startXOffSet + 20, y: centerYOffSet + offsetY, width: Int(fullSize.width - 20) , height: TextHight))
            emailText!.text = email
            emailText!.isEnabled = false
            emailText!.textColor = UIColor.black
            emailText!.backgroundColor = UIColor.clear
            self.view.addSubview(emailText!)
            
            offsetY = offsetY + TextHight + 5
            phoneText = UILabel(frame: CGRect(x: startXOffSet + 20, y: centerYOffSet + offsetY, width: Int(fullSize.width - 20) , height: TextHight))
            phoneText!.text = phone
            phoneText!.isEnabled = false
            phoneText!.textColor = UIColor.black
            phoneText!.backgroundColor = UIColor.clear
            self.view.addSubview(phoneText!)
            
            //resetPassTitle
            offsetY = offsetY + TextHight + 5
            resetPassTitle = UILabel(frame: CGRect(x: startXOffSet + 20, y: centerYOffSet + offsetY, width: Int(fullSize.width - 20) , height: TextHight))
            resetPassTitle!.text = "密碼"
            resetPassTitle!.isEnabled = false
            resetPassTitle!.textColor = UIColor.black
            resetPassTitle!.backgroundColor = UIColor.clear
            self.view.addSubview(resetPassTitle!)
            
            //resetPassButton
            //offsetY = offsetY + TextHight + 5
            resetPassButton = UIButton(
                frame: CGRect(x: centerXOffSet - 40, y: startYOffSet + offsetY, width: 80, height: TextHight))
            resetPassButton!.setTitle("重設密碼", for: .normal)
            resetPassButton!.setTitleColor(UIColor.white, for: .normal)
            resetPassButton!.layer.cornerRadius = 5.0
            resetPassButton!.isEnabled = true
            resetPassButton!.backgroundColor = UIColor(red: 0, green: 160/255, blue: 1, alpha: 0.8)
            resetPassButton!.addTarget(
                self,
                action: #selector(resetPass_btn),
                for: .touchUpInside)
            self.view.addSubview(resetPassButton!)

            if power == 1 && self.debug == 1
            {
                print("Special one")
            }
            if status > 0 && self.debug == 1
            {
                print ("Status is :",status)
            }
            return true
        }
        return false
    }
    
    func loginNregisterFunLoad()
    {
        offsetY = offsetY + TextHight + 20
        loginEmail = UITextField(frame: CGRect(x: startXOffSet, y: centerYOffSet + offsetY, width: Int(fullSize.width - 20) , height: TextHight))
        loginEmail!.placeholder = "輸入 email"
        loginEmail!.borderStyle = .roundedRect
        loginEmail!.textAlignment = .justified
        loginEmail!.clearButtonMode = .whileEditing
        loginEmail!.keyboardType = .emailAddress
        loginEmail!.returnKeyType =  UIReturnKeyType.continue
        loginEmail!.textColor = UIColor.gray
        loginEmail!.backgroundColor = UIColor.clear
        self.view.addSubview(loginEmail!)
        
        //loginPassword
        offsetY = offsetY + TextHight + 5
        loginPassword = UITextField(frame: CGRect(x: startXOffSet, y: centerYOffSet + offsetY, width: Int(fullSize.width - 20) , height: TextHight))
        loginPassword!.placeholder = "輸入密碼"
        loginPassword!.borderStyle = .roundedRect
        loginPassword!.isSecureTextEntry = true
        loginPassword!.textAlignment = .justified
        loginPassword!.clearButtonMode = .whileEditing
        loginPassword!.keyboardType = .default
        loginPassword!.returnKeyType =  UIReturnKeyType.continue
        loginPassword!.textColor = UIColor.gray
        loginPassword!.backgroundColor = UIColor.clear
        self.view.addSubview(loginPassword!)
        
        // 使用 UIButton(frame:) 建立一個 UIButton
        offsetY = offsetY + TextHight + 5
        loginButton = UIButton(
            frame: CGRect(x: centerXOffSet - (60 + 5), y: centerYOffSet + offsetY, width: 60, height: TextHight))
        // 按鈕文字
        loginButton!.setTitle("登入", for: .normal)
        // 按鈕文字顏色
        loginButton!.setTitleColor(UIColor.white, for: .normal)
        loginButton!.layer.cornerRadius = 5.0
        // 按鈕是否可以使用
        loginButton!.isEnabled = true
        // 按鈕背景顏色
        loginButton!.backgroundColor = UIColor(red: 0, green: 160/255, blue: 1, alpha: 0.8)
        //UIColor.darkGray
        // 按鈕按下後的動作
        loginButton!.addTarget(
            self,
            action: #selector(login_btn),
            for: .touchUpInside)
        self.view.addSubview(loginButton!)
        
        // 使用 UIButton(frame:) 建立一個 UIButton
        forgetPassButton = UIButton(
            frame: CGRect(x: centerXOffSet + 30, y: centerYOffSet + offsetY, width: 80, height: TextHight))
        // 按鈕文字
        forgetPassButton!.setTitle("忘記密碼", for: .normal)
        // 按鈕文字顏色
        forgetPassButton!.setTitleColor(UIColor.white, for: .normal)
        forgetPassButton!.layer.cornerRadius = 5.0
        // 按鈕是否可以使用
        forgetPassButton!.isEnabled = true
        // 按鈕背景顏色
        forgetPassButton!.backgroundColor = UIColor(red: 0, green: 160/255, blue: 1, alpha: 0.8)
        //UIColor.darkGray
        // 按鈕按下後的動作
        forgetPassButton!.addTarget(
            self,
            action: #selector(forgetPass_btn),
            for: .touchUpInside)
        self.view.addSubview(forgetPassButton!)
        
        //register name
        offsetY = offsetY + TextHight + 20
        registerName = UITextField(frame: CGRect(x: startXOffSet, y: centerYOffSet + offsetY, width: Int(fullSize.width - 20) , height: TextHight))
        registerName!.placeholder = "輸入暱稱"
        registerName!.borderStyle = .roundedRect
        registerName!.textAlignment = .justified
        registerName!.clearButtonMode = .whileEditing
        registerName!.keyboardType = .default
        registerName!.returnKeyType =  UIReturnKeyType.continue
        registerName!.textColor = UIColor.gray
        registerName!.backgroundColor = UIColor.clear
        self.view.addSubview(registerName!)
        
        //register email
        offsetY = offsetY + TextHight + 5
        registerEmail = UITextField(frame: CGRect(x: startXOffSet, y: centerYOffSet + offsetY, width: Int(fullSize.width - 20) , height: TextHight))
        registerEmail!.placeholder = "輸入 email"
        registerEmail!.borderStyle = .roundedRect
        registerEmail!.textAlignment = .justified
        registerEmail!.clearButtonMode = .whileEditing
        registerEmail!.keyboardType = .emailAddress
        registerEmail!.returnKeyType =  UIReturnKeyType.continue
        registerEmail!.textColor = UIColor.gray
        registerEmail!.backgroundColor = UIColor.clear
        self.view.addSubview(registerEmail!)
        
        //register phone
        offsetY = offsetY + TextHight + 5
        registerPhone = UITextField(frame: CGRect(x: startXOffSet, y: centerYOffSet + offsetY, width: Int(fullSize.width - 20) , height: TextHight))
        registerPhone!.placeholder = "輸入手機號碼"
        registerPhone!.borderStyle = .roundedRect
        registerPhone!.textAlignment = .justified
        registerPhone!.clearButtonMode = .whileEditing
        registerPhone!.keyboardType = .numberPad
        registerPhone!.returnKeyType =  UIReturnKeyType.continue
        registerPhone!.textColor = UIColor.gray
        registerPhone!.backgroundColor = UIColor.clear
        self.view.addSubview(registerPhone!)
        
        //register password1
        offsetY = offsetY + TextHight + 5
        registerPass = UITextField(frame: CGRect(x: startXOffSet, y: centerYOffSet + offsetY, width: Int(fullSize.width - 20) , height: TextHight))
        registerPass!.placeholder = "輸入密碼"
        registerPass!.borderStyle = .roundedRect
        registerPass!.isSecureTextEntry = true
        registerPass!.textAlignment = .justified
        registerPass!.clearButtonMode = .whileEditing
        registerPass!.keyboardType = .default
        registerPass!.returnKeyType =  UIReturnKeyType.continue
        registerPass!.textColor = UIColor.gray
        registerPass!.backgroundColor = UIColor.clear
        self.view.addSubview(registerPass!)
        
        //register password1
        offsetY = offsetY + TextHight + 5
        registerRePass = UITextField(frame: CGRect(x: startXOffSet, y: centerYOffSet + offsetY, width: Int(fullSize.width - 20) , height: TextHight))
        registerRePass!.placeholder = "再輸入一次密碼"
        registerRePass!.borderStyle = .roundedRect
        registerRePass!.isSecureTextEntry = true
        registerRePass!.textAlignment = .justified
        registerRePass!.clearButtonMode = .whileEditing
        registerRePass!.keyboardType = .default
        registerRePass!.returnKeyType =  UIReturnKeyType.continue
        registerRePass!.textColor = UIColor.gray
        registerRePass!.backgroundColor = UIColor.clear
        self.view.addSubview(registerRePass!)
        
        offsetY = offsetY + TextHight + 5
        registerButton = UIButton(
            frame: CGRect(x: centerXOffSet - 30, y: centerYOffSet + offsetY, width: 60, height: TextHight))
        // 按鈕文字
        registerButton!.setTitle("註冊", for: .normal)
        // 按鈕文字顏色
        registerButton!.setTitleColor(UIColor.white, for: .normal)
        registerButton!.layer.cornerRadius = 5.0
        // 按鈕是否可以使用
        registerButton!.isEnabled = true
        // 按鈕背景顏色
        registerButton!.backgroundColor = UIColor(red: 0, green: 160/255, blue: 1, alpha: 0.8)
        //UIColor.darkGray
        // 按鈕按下後的動作
        registerButton!.addTarget(
            self,
            action: #selector(register_btn),
            for: .touchUpInside)
        self.view.addSubview(registerButton!)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        var insert = 0 // 0 - insert suceess, 1 - insert failure, 2 - file load err
        var failcount = 0
        let imporURL = url as URL
        if self.debug == 1 {
            print(imporURL)
            print("import result : \(imporURL)")
            print(url.lastPathComponent)
            print(url.pathExtension)
        }
        do {
            let loading = try NSString(contentsOfFile: imporURL.path, encoding: String.Encoding.utf8.rawValue)
            if self.debug == 1 {
                print("got from file: ",loading)
            }
            let impArray = loading.components(separatedBy: NSCharacterSet.newlines)
            var readIdx = 0

            for ar in impArray
            {
                if readIdx > 0 && ar != ""
                {
                    let dbInsrtArr = ar.components(separatedBy: ",")
                    let db:DB_Access = DB_Access()

                    if db.ppCheck(nameStr: dbInsrtArr[0]) && dbInsrtArr.count == 8
                    {
                        if db.pp_insert(pp_name: dbInsrtArr[0], pp_phone: dbInsrtArr[1],
                                        pp_country: dbInsrtArr[2], pp_address: dbInsrtArr[3],
                                        pp_fb: dbInsrtArr[4], pp_web: dbInsrtArr[5] ,
                                        pp_blogger_intro: dbInsrtArr[6],
                                        pp_opentime: dbInsrtArr[7],
                                        pp_note: dbInsrtArr[8],
                                        pp_score: "待補充") > 0
                        {
                            if self.debug == 1 {
                                print("Insert successful")
                            }
                            //DashViewController
                            if let dashVC = self.tabBarController?.viewControllers?[2] as? DashViewController{
                                dashVC.ppList_updated = 1
                            }
                        }
                        else
                        {
                            if self.debug == 1 {
                                print("Insert failure")
                            }
                            insert = 1
                        }
                    }
                    else
                    {
                        failcount += 1
                        if self.debug == 1 {
                            print("Format error : ",dbInsrtArr[0] , ", dbInsrtArr Count : ",dbInsrtArr.count )
                            print("Insert format fail count : ", failcount)
                        }
                    }
                }
                readIdx += 1
            }
        } catch {
            if self.debug == 1 {
                print("error creating file")
            }
            insert = 2
        }

        //self.addViewHint(Status: insert)
    }
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
        if self.debug == 1 {
            print("documentMenu Pick animated done...")
        }
        switchActivityIndicator(SWITCH: 1)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        if self.debug == 1 {
            print("view was cancelled")
        }
        dismiss(animated: true, completion: nil)
        switchActivityIndicator(SWITCH: 0)
    }
    */
    func userRegisterAlertHdlr(email:String, name:String, phone:String)
    {
        // 建立一個提示框
        let userRgCtrl = UIAlertController(
            title: "註冊",
            message: nil,
            preferredStyle: .alert)
        
        // 建立[確認]按鈕
        let sendAction = UIAlertAction(
            title: "確認",
            style: .default,
            handler: {
                (action: UIAlertAction!) -> Void in
                let email = self.registerEmail!.text!
                let password = self.registerPass!.text!
                let re_pss = self.registerRePass!.text!
                let name = self.registerName!.text!
                let phone = self.registerPhone!.text!
                if password != re_pss
                {
                    if self.debug == 1 {
                        print("different password input ")
                    }
                    self.userRegisterAlertHdlr(email: email, name: name, phone: phone)
                }
                if self.debug == 1 {
                    print ("User register info: ",email, password,name,phone)
                }
                let parameters: Parameters=[
                    "TODO":email,
                    "TODO":password,
                    "TODO": name,
                    "TODO": phone
                ]
                Alamofire.request(self.URL_USER_REGISTER, method: .post, parameters: parameters).responseJSON
                { response in
                    //printing response
                    if self.debug == 1 {
                        print(response)
                    }
                    
                    //getting the json value from the server
                    if let result = response.result.value {
                        
                        //converting it as NSDictionary
                        let jsonData = result as! NSDictionary
                        let status = jsonData.value(forKey: "status") as! Int
                        if status == 0
                        {
                            if self.debug == 1 {
                                print ("user not exist")
                            }
                            let message = jsonData.value(forKey: "message") as! String
                            if message == "User already exist"
                            {
                                if self.debug == 1 {
                                    print("User already been registered")
                                    print ("Input IS NULLLLLL")
                                }
                                let cancelctrl = UIAlertController(
                                    title: "email或電話已被註冊",
                                    message: nil,
                                    preferredStyle: .alert)
                                let cancel = UIAlertAction(title: "確定", style: .destructive, handler: { (action) -> Void in
                                    self.userRegisterAlertHdlr(email: "", name: "", phone: "")
                                })
                                cancelctrl.addAction(cancel)
                                
                                // 顯示提示框
                                self.present(
                                    cancelctrl,
                                    animated: true,
                                    completion: nil)
                            }
                            else
                            {
                                self.userRegisterAlertHdlr(email: email, name: "", phone: "")
                            }
                        }
                        else
                        {
                            if self.debug == 1 {
                                print("Register successful")
                            }
                            let user = jsonData.value(forKey: "user") as! NSDictionary
                            let name = user.value(forKey: "name") as! String
                            let email = user.value(forKey: "email") as! String
                            let phone = user.value(forKey: "phone") as! String
                            let power = user.value(forKey: "power") as! Int
                            let status = user.value(forKey: "status") as! Int
                            let activity_key = user.value(forKey: "activity_key") as! String
                            let myUserDefaults = UserDefaults.standard
                            myUserDefaults.set(name, forKey: "user_name")
                            myUserDefaults.set(email, forKey: "user_email")
                            myUserDefaults.set(phone, forKey: "user_phone")
                            myUserDefaults.set(power, forKey: "user_power")
                            myUserDefaults.set(status, forKey: "user_status")
                            myUserDefaults.set(activity_key, forKey: "user_activity_key")
                            myUserDefaults.synchronize()
                            self.UserLogSwitch(logout_login: true)
                        }
                    }
                }
        })
        let cancel = UIAlertAction(title: "取消", style: .destructive, handler: { (action) -> Void in })
        userRgCtrl.addAction(cancel)
        userRgCtrl.addAction(sendAction)
        // 顯示提示框
        self.present(
            userRgCtrl,
            animated: true,
            completion: nil)
    }
    
    func sendLoginJSON(email: String, password: String)
    {
        if email.count <= 0 || password.count <= 0
        {
            if debug == 1 {
                print ("Input IS NULLLLLL")
            }
            let cancelctrl = UIAlertController(
                title: "輸入不完整",
                message: nil,
                preferredStyle: .alert)
            let cancel = UIAlertAction(title: "確定", style: .destructive, handler: { (action) -> Void in})
            cancelctrl.addAction(cancel)

            // 顯示提示框
            self.present(
                cancelctrl,
                animated: true,
                completion: nil)
            return
        }
        let parameters: Parameters=[
            "TODO":email,
            "TODO":password
        ]
        
        //Sending http post request
        Alamofire.request(self.URL_USER_LOGIN, method: .post, parameters: parameters).responseJSON
        {
            response in
            //printing response
            if self.debug == 1 {
                print(response)
            }
        
            //getting the json value from the server
            if let result = response.result.value {
            
                //converting it as NSDictionary
                let jsonData = result as! NSDictionary
                let status = jsonData.value(forKey: "status") as! Int
                if status == 0
                {
                    if self.debug == 1 {
                        print ("user not exist")
                    }
                    self.addViewHint(Status: 6)
                    //self.userRegisterAlertHdlr(email: email, name: "", phone: "")
                }
                else
                {
                    if self.debug == 1 {
                        print("login successful")
                        print("feeback: ", jsonData)
                    }
                    let user = jsonData.value(forKey: "user") as! NSDictionary
                    let name = user.value(forKey: "name") as! String
                    let email = user.value(forKey: "email") as! String
                    let phone = user.value(forKey: "phone") as! String
                    let power = user.value(forKey: "power") as! Int
                    let status = user.value(forKey: "status") as! Int
                    let activity_key = user.value(forKey: "activity_key") as! String
                    let myUserDefaults = UserDefaults.standard
                    myUserDefaults.set(name, forKey: "user_name")
                    myUserDefaults.set(email, forKey: "user_email")
                    myUserDefaults.set(phone, forKey: "user_phone")
                    myUserDefaults.set(power, forKey: "user_power")
                    myUserDefaults.set(status, forKey: "user_status")
                    myUserDefaults.set(activity_key, forKey: "user_activity_key")
                    myUserDefaults.synchronize()
                    self.UserLogSwitch(logout_login: true)
                }
            }
        }
    }
    
    @objc func resetPass_btn() {
        changePass()
    }
    
    @objc func register_btn()
    {
        self.userRegisterAlertHdlr(email: "", name: "", phone: "")
    }
    
    @objc func forgetPass_btn()
    {
        self.editeValueCtrl = UIAlertController(
            title: "忘記密碼",
            message: "輸入你註冊的E-Mail",
            preferredStyle: .alert)
        //create value change
        self.editeValueCtrl!.addTextField { (textfield: UITextField) in
            textfield.font = UIFont(name: "Helvetica-Light", size: 16)
            textfield.placeholder = "輸入你的E-Mail"
            textfield.textAlignment = .justified
            textfield.clearButtonMode = .whileEditing
            textfield.keyboardType = .emailAddress
            textfield.returnKeyType =  UIReturnKeyType.continue
        }
        // 建立[確認]按鈕
        let sendAction = UIAlertAction(
            title: "確認",
            style: .default,
            handler: { (action: UIAlertAction!) -> Void in
                //print("update:", self.editeValueCtrl!.textFields![0].text!)
                let email = self.editeValueCtrl!.textFields![0].text!
                if (email.count <= 0) {
                    self.addViewHint(Status: 2)
                }
                self.forgetPassToCloud(email: email)
                self.editeValueCtrl = nil
        })
        
        let cancel = UIAlertAction(title: "取消", style: .destructive, handler: { (action) -> Void in })
        
        //self.editeValueCtrl!.view.addSubview(cusTextView)
        self.editeValueCtrl!.addAction(cancel)
        self.editeValueCtrl!.addAction(sendAction)
        
        // 顯示提示框
        self.present(self.editeValueCtrl!, animated: true, completion: nil)
    }
    
    @objc func logout_btn()
    {
        UserLogSwitch(logout_login: false)
    }
    
    @objc func login_btn()
    {
        // 建立一個提示框
        let pwdCtrl = UIAlertController(
            title: "登入",
            message: nil,
            preferredStyle: .alert)

        let cancel = UIAlertAction(title: "取消", style: .destructive, handler: { (action) -> Void in })
        // 建立[確認]按鈕
        let sendAction = UIAlertAction(
            title: "確認",
            style: .default,
            handler: {
                (action: UIAlertAction!) -> Void in
                //creating parameters for the post request
                self.sendLoginJSON( email: self.loginEmail!.text!, password: self.loginPassword!.text!)
        })
        
        pwdCtrl.addAction(cancel)
        pwdCtrl.addAction(sendAction)
        // 顯示提示框
        self.present(
            pwdCtrl,
            animated: true,
            completion: nil)
    }
    /*
    @objc func import_PP()
    {
        importNotePP()
        if self.debug == 1 {
            print("匯入click")
        }
    }*/
    
    func UserLogSwitch(logout_login:Bool)
    {
        if !logout_login
        {
            userLabel!.isHidden = true
            logoutButton!.isHidden = true
            emailText!.isHidden = true
            phoneText!.isHidden = true
            resetPassTitle!.isHidden = true
            resetPassButton!.isHidden = true
            //offsetY = offsetY - (TextHight + 5)*3
            offsetY = 0//TextHight + 20
            let myUserDefaults = UserDefaults.standard
            myUserDefaults.removeObject(forKey: "user_name")
            myUserDefaults.removeObject(forKey: "user_email")
            myUserDefaults.removeObject(forKey: "user_phone")
            myUserDefaults.removeObject(forKey: "user_power")
            myUserDefaults.removeObject(forKey: "user_status")
            myUserDefaults.removeObject(forKey: "user_activity_key")
            myUserDefaults.synchronize()
            
            loginNregisterFunLoad()
        }
        else
        {
            loginPassword!.isHidden = true
            loginEmail!.isHidden = true
            loginButton!.isHidden = true
            forgetPassButton!.isHidden = true
            registerButton!.isHidden = true
            registerName!.isHidden = true
            registerEmail!.isHidden = true
            registerPhone!.isHidden = true
            registerPass!.isHidden = true
            registerRePass!.isHidden = true
            
            //offsetY = (TextHight + 5)
            offsetY = 0
            _ = userInfoLoad()
            userLabel!.isHidden = false
            logoutButton!.isHidden = false
            resetPassTitle!.isHidden = false
            resetPassButton!.isHidden = false
            emailText!.isHidden = false
            phoneText!.isHidden = false
        }
    }
    
/*
    func saveAllPP()
    {
        let db:DB_Access = DB_Access()
        let fileName = "makeda_backup.csv"
        var csvString = "Name,Phone,Country,Address,FB,Web,BloggerIntro,Opentime,Note\n"

        do {
            if self.debug == 1 {
                print("prepare Path INIT...")
            }
            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            if self.debug == 1 {
                print("Path Init : ", path as Any)
                print("建立存檔 - test.csv")
            }
            
            if let caches = db.pp_getAll()
            {
                if self.debug == 1 {
                    print("backup --")
                }
                for cache in (caches) {
                    //print("Name: ", cache.value(forKey: "pp_name") as! String)
                    let ppStr = "\(cache.value(forKey: "pp_name") as! String),\(cache.value(forKey: "pp_phone") as! String),\(cache.value(forKey: "pp_country") as! String),\(cache.value(forKey: "pp_address") as! String),\(cache.value(forKey: "pp_fb") as! String),\(cache.value(forKey: "pp_web") as! String),\(cache.value(forKey: "blogger_intro") as! String),\(cache.value(forKey: "pp_opentime") as! String),\(cache.value(forKey: "pp_note") as! String)\n"
                    if self.debug == 1 {
                        print(ppStr)
                    }
                    csvString = csvString.appending(ppStr)
                }
            }
            try csvString.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            let vc = UIActivityViewController(activityItems: [path as Any], applicationActivities: [])
            vc.excludedActivityTypes = [
                UIActivityType.assignToContact,
                UIActivityType.saveToCameraRoll,
                UIActivityType.postToFlickr,
                UIActivityType.postToVimeo,
                UIActivityType.postToTencentWeibo,
                UIActivityType.postToTwitter,
                UIActivityType.postToFacebook,
                UIActivityType.openInIBooks
            ]
            present(vc, animated: true, completion: nil)
 
        } catch {
            if self.debug == 1 {
                print("error creating file")
            }
        }
    }
 */
    
    func changePass() {
        self.editeValueCtrl = UIAlertController(
            title: "更換密碼",
            message: "輸入密碼",
            preferredStyle: .alert)

        //create value change
        self.editeValueCtrl!.addTextField { (textfield: UITextField) in
            textfield.font = UIFont(name: "Helvetica-Light", size: 16)
            textfield.placeholder = "輸入原本的密碼"
            textfield.isSecureTextEntry = true
            textfield.textAlignment = .justified
            textfield.clearButtonMode = .whileEditing
            textfield.keyboardType = .default
            textfield.returnKeyType =  UIReturnKeyType.continue
        }
        
        //create value change
        self.editeValueCtrl!.addTextField { (textfield: UITextField) in
            textfield.font = UIFont(name: "Helvetica-Light", size: 16)
            textfield.placeholder = "輸入新的密碼"
            textfield.isSecureTextEntry = true
            textfield.textAlignment = .justified
            textfield.clearButtonMode = .whileEditing
            textfield.keyboardType = .default
            textfield.returnKeyType =  UIReturnKeyType.continue
        }
        
        //create value change
        self.editeValueCtrl!.addTextField { (textfield: UITextField) in
            textfield.font = UIFont(name: "Helvetica-Light", size: 16)
            textfield.placeholder = "再輸入一次新的密碼"
            textfield.isSecureTextEntry = true
            textfield.textAlignment = .justified
            textfield.clearButtonMode = .whileEditing
            textfield.keyboardType = .default
            textfield.returnKeyType =  UIReturnKeyType.continue
        }
            
        // 建立[確認]按鈕
        let sendAction = UIAlertAction(
            title: "確認",
            style: .default,
            handler: { (action: UIAlertAction!) -> Void in
                if self.debug == 1 {
                    print("update:", self.editeValueCtrl!.textFields![0].text!)
                }
                let oldpass = self.editeValueCtrl!.textFields![0].text!
                let newpass1 = self.editeValueCtrl!.textFields![1].text!
                let newpass2 = self.editeValueCtrl!.textFields![2].text!
                if (newpass1.count > 0 && newpass2.count > 0 && oldpass.count > 0)
                {
                    if (newpass1 != newpass2) {
                        self.addViewHint(Status: 3)
                    } else {
                        self.resetPassToCloud(email: self.emailText!.text!, oldpass: oldpass, newpass: newpass1)
                    }
                } else {
                    // input is null
                    self.addViewHint(Status: 2)
                }
                self.editeValueCtrl = nil
        })
            
        let cancel = UIAlertAction(title: "取消", style: .destructive, handler: { (action) -> Void in })
            
        //self.editeValueCtrl!.view.addSubview(cusTextView)
        self.editeValueCtrl!.addAction(cancel)
        self.editeValueCtrl!.addAction(sendAction)
            
            // 顯示提示框
        self.present(self.editeValueCtrl!, animated: true, completion: nil)
    }
    
    func forgetPassToCloud(email:String) {
        
        let parameters: Parameters=[
            "TODO":"TODO",
            "TODO":email,
        ]
        
        //Sending http post request
        Alamofire.request(self.URL_USER_ACCOUNT_UPDATE, method: .post, parameters: parameters).responseJSON
            {
                response in
                //printing response
                if self.debug == 1 {
                    print(response)
                }
                //getting the json value from the server
                if let result = response.result.value {
                    
                    //converting it as NSDictionary
                    let jsonData = result as! NSDictionary
                    let status = jsonData.value(forKey: "status") as! Int
                    if status == 0
                    {
                        if self.debug == 1 {
                            print("fail:", jsonData)
                        }
                        self.addViewHint(Status: 0)
                    }
                    else
                    {
                        if self.debug == 1 {
                            print("successful")
                            print("feeback: ", jsonData)
                        }
                        self.addViewHint(Status: 1)
                        
                    }
                }
        }
    }
    
    func resetPassToCloud(email:String, oldpass:String, newpass:String) {

        let parameters: Parameters=[
            "TODO":"TODO",
            "TODO":email,
            "TODO":oldpass,
            "TODO":newpass
        ]
        
        //Sending http post request
        Alamofire.request(self.URL_USER_ACCOUNT_UPDATE, method: .post, parameters: parameters).responseJSON
        {
            response in
            //printing response
            if self.debug == 1 {
                print(response)
            }
            //getting the json value from the server
            if let result = response.result.value {
                
                //converting it as NSDictionary
                let jsonData = result as! NSDictionary
                let status = jsonData.value(forKey: "status") as! Int
                if status == 0
                {
                    if self.debug == 1 {
                        print("fail:", jsonData)
                    }
                    self.addViewHint(Status: 4)
                }
                else
                {
                    if self.debug == 1 {
                        print("successful")
                        print("feeback: ", jsonData)
                    }
                    self.addViewHint(Status: 5)
                    
                }
            }
        }
    }
    
    func addViewHint(Status:Int) {
        var Title:String?
        var msgStr:String?
        var BtnTitle:String?
        // 0 - insert suceess, 1 - insert failure, 2 - file load err
        if (Status == 0)
        {
            Title = "錯誤"
            msgStr = "E-mail似乎有錯誤？"
            BtnTitle = "確認"
        }
        else if (Status == 1)
        {
            Title = "成功"
            msgStr = "已發送密碼到您的信箱囉！"
            BtnTitle = "確認"
        }
        else if (Status == 2)
        {
            Title = "錯誤"
            msgStr = "請勿空白"
            BtnTitle = "確認"
        }
        else if (Status == 3)
        {
            Title = "錯誤"
            msgStr = "輸入兩次的新密碼不符合"
            BtnTitle = "確認"
        }
        else if (Status == 4)
        {
            Title = "錯誤"
            msgStr = "更換密碼失敗"
            BtnTitle = "確認"
        }
        else if (Status == 5)
        {
            Title = "成功"
            msgStr = "更換密碼成功，重新登入"
            BtnTitle = "確認"
        }
        else if (Status == 6)
        {
            Title = "錯誤"
            msgStr = "使用者不存在"
            BtnTitle = "確認"
        }

        
        // 建立一個提示框
        let alertController = UIAlertController(
            title: Title,
            message: msgStr,
            preferredStyle: .alert)
        
        // 建立[確認]按鈕
        let okAction = UIAlertAction(
            title: BtnTitle,
            style: .default,
            handler: {
                (action: UIAlertAction!) -> Void in
                if self.debug == 1 {
                    print("按下確認後，閉包裡的動作")
                }
                //self.myActivityIndicator.stopAnimating()
                //self.switchActivityIndicator(SWITCH: 0)
                if (Status == 5) {
                    self.UserLogSwitch(logout_login: false)
                }
        })
        alertController.addAction(okAction)
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
    
    func switchActivityIndicator(SWITCH: Int) // 0- close, 1- open
    {
        if SWITCH == 1
        {
            self.myActivityIndicator.startAnimating()
            UIApplication.shared.isIdleTimerDisabled = true
        }
        else if SWITCH == 0
        {
            self.myActivityIndicator.stopAnimating()
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    // 按空白處會隱藏編輯狀態
    @objc func hideKeyboard(tapG:UITapGestureRecognizer)
    {
        self.view.endEditing(true)
    }
    
    func loadGoogleBannerAD()
    {
        if debug == 1 {
            print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        }
        let request = GADRequest()
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.adUnitID = "ca-app-pub-3903928830427305/1763722242"
        bannerView.delegate = self
        bannerView.rootViewController = self
        bannerView.load(request)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        if #available(iOS 11.0, *) {
            view.addConstraints(
                [bannerView.bottomAnchor.constraintEqualToSystemSpacingBelow(view.safeAreaLayoutGuide.bottomAnchor, multiplier: 0), bannerView.centerXAnchor.constraintEqualToSystemSpacingAfter(view.safeAreaLayoutGuide.centerXAnchor, multiplier: 0)
                ])
        }
        else
        {
            view.addConstraints(
                [NSLayoutConstraint(item: bannerView,
                                    attribute: .bottom,
                                    relatedBy: .equal,
                                    toItem: bottomLayoutGuide,
                                    attribute: .top,
                                    multiplier: 1,
                                    constant: 0),
                 NSLayoutConstraint(item: bannerView,
                                    attribute: .centerX,
                                    relatedBy: .equal,
                                    toItem: view,
                                    attribute: .centerX,
                                    multiplier: 1,
                                    constant: 0)
                ])
        }
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(bannerView)
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        if debug == 1 {
            print("setting: adView:didFailToReceiveAdWithError : \(error)")
        }
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        
    }
}
