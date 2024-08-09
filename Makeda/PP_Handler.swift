//
//  PP_Handler.swift
//  Makeda
//
//  Created by Brian on 2018/8/31.
//  Copyright © 2018年 breadcrumbs.tw. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import SafariServices

class PP_Handler: UIViewController, UITextFieldDelegate, UIScrollViewDelegate
,UIPickerViewDelegate, UIPickerViewDataSource, SFSafariViewControllerDelegate {
    let debug = 0
    let fullSize = UIScreen.main.bounds.size
    var myScrollView: UIScrollView!
    let goBackButtonID = 100
    let editeButtonID = 101
    let goMapButtonID = 102
    let SaveButtonID = 103
    private var sel_country = 0
    var userPower = 0
    var PPdetail:NSManagedObject! = nil
    var ppCountry:String? = String("台灣")
    var ppCity:String?
    var ppCountryNCityL:String! = nil
    var editOnOff:Bool = false
    var using_height = 0
    var idx_offset = 80
    let scrolling_offset = 80
    let Yoffset = 10
    var ppIDL:String?
    var ppNameL:String?
    var ppPhoneL:String?
    //var ppCountryL:String?
    var ppAddressL:String?
    var ppFBL:String?
    var ppWEBL:String?
    var ppBloggerIntroL:String?
    var ppOpentimeL:String?
    var ppNoteL:String? = String("待補充")
    var ppScoreL:String? = String("待補充")
    var ppDescripL:String?
    
    var ppNameTextField:UITextField?
    var ppPhoneTextField:UITextField?
    var pp_countryTextField:UITextField?
    var pp_addressTextField:UITextField?
    var pp_fbTextField:UITextField?
    var pp_webTextField:UITextField?
    var blogger_introTextField:UITextField?
    var pp_opentimeTextField:UITextField?
    var ppNoteTextField:UITextField?
    
    let nameTextFieldTag = 900
    let phoneTextFieldTag = 901
    let countryTextFieldTag = 902
    let addressTextFieldTag = 903
    let fbTextFieldTag = 904
    let webTextFieldTag = 905
    let bloggerIntroTextFieldTag = 906
    let opentimeTextFieldTag = 907
    let noetTextFieldTag = 908
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewLoad()
        pp_nameViewLoad()
        pp_phoneViewLoad()
        pp_countryViewLoad()
        pp_addressViewLoad()
        pp_fbViewLoad()
        pp_webViewLoad()
        blogger_introViewLoad()
        pp_opentimeViewLoad()
        ppNoteViewLoad()
        goBackBtn()
        editeBtn()
        map_go_Btn()
        saveBtn()
        disableButton(ButtonID: self.SaveButtonID)
        
        userPower = GetUserPower()
        
        if using_height > Int(fullSize.height)
        {
            myScrollView.contentSize = CGSize(width: fullSize.width, height: CGFloat(using_height + 50))
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(DashViewController.hideKeyboard(tapG:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        if debug == 1 {
            print("PP_Handler..Init done")
        }
        TextFieldInit()
        if debug == 1 {
            print("data Init done")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func GetUserPower()-> Int {
        let myUserDefaults = UserDefaults.standard
        if let po:Int = myUserDefaults.value(forKey: "user_power") as? Int {
            return po
        }
        return 0
    }
    
    func TextFieldInit()
    {
        ppNameTextField!.text = (PPdetail.value(forKey: "pp_name") as! String)
        ppPhoneTextField!.text = (PPdetail.value(forKey: "pp_phone") as! String)
        pp_countryTextField!.text = (PPdetail.value(forKey: "pp_country") as! String)
        pp_addressTextField!.text = (PPdetail.value(forKey: "pp_address") as! String)
        pp_fbTextField!.text = (PPdetail.value(forKey: "pp_fb") as! String)
        pp_webTextField!.text = (PPdetail.value(forKey: "pp_web") as! String)
        blogger_introTextField!.text = (PPdetail.value(forKey: "blogger_intro") as! String)
        pp_opentimeTextField!.text = (PPdetail.value(forKey: "pp_opentime") as! String)
        if let text = PPdetail.value(forKey: "pp_note") as? String
        {
            ppNoteTextField!.text = text
        }

        //fill local data
        let pid = PPdetail.value(forKey: "id")
        ppIDL = "\(pid!)"
        ppNameL = (PPdetail.value(forKey: "pp_name") as! String)
        ppPhoneL = (PPdetail.value(forKey: "pp_phone") as! String)
        ppCountryNCityL = (PPdetail.value(forKey: "pp_country") as! String)
        ppAddressL = (PPdetail.value(forKey: "pp_address") as! String)
        ppFBL = (PPdetail.value(forKey: "pp_fb") as! String)
        ppWEBL = (PPdetail.value(forKey: "pp_web") as! String)
        ppBloggerIntroL = (PPdetail.value(forKey: "blogger_intro") as! String)
        ppOpentimeL = (PPdetail.value(forKey: "pp_opentime") as! String)
        if let text = (PPdetail.value(forKey: "pp_note"))
        {
            ppNoteL = text as? String
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // 設定delegate 為self後，可以自行增加delegate protocol
    //(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        if self.debug == 1 {
            print("textFieldShouldBeginEditing:", editOnOff)
        }
        return editOnOff
    }
    // 開始進入編輯狀態
    func textFieldDidBeginEditing(_ textField: UITextField){
        if self.debug == 1 {
            print("textFieldDidBeginEditing:" + textField.text!)
        }
        
        var offsetY = textField.frame.minY - CGFloat(scrolling_offset)
        if (textField.frame.minY <= CGFloat(scrolling_offset))
        {
            offsetY = 0
        }
        myScrollView.contentOffset = CGPoint(x: 0, y: offsetY)
        if self.debug == 1 {
            print("offset Y:", offsetY)
        }
    }
    
    // 可能進入結束編輯狀態
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if self.debug == 1 {
            print("textFieldShouldEndEditing:" + textField.text!)
        }
        
        return true
    }
    
    // 結束編輯狀態(意指完成輸入或離開焦點)
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.debug == 1 {
            print("textFieldDidEndEditing:" + textField.text!)
        }
        if (ppNameL == nil || ppNameL == "待補充")
        {
            if (ppNameTextField!.text!.isEmpty)
            {
                ppNameL = "待補充"
            }
            else
            {
                ppNameL = ppNameTextField!.text!
            }
            if self.debug == 1 {
                print("name:", ppNameTextField!.text!, ppNameL!)
            }
        }
        
        if (ppPhoneL == nil || ppPhoneL == "待補充")
        {
            if ppPhoneTextField!.text!.isEmpty
            {
                ppPhoneL = "待補充"
            }
            else
            {
                ppPhoneL = ppPhoneTextField!.text!
            }
            if self.debug == 1 {
                print("phone:", ppPhoneTextField!.text!, ppPhoneL!)
            }
        }
        
        if (ppCountryNCityL == nil || ppCountryNCityL == "待補充")
        {
            if pp_countryTextField!.text!.isEmpty
            {
                ppCountryNCityL = "待補充"
            }
            else
            {
                ppCountryNCityL = pp_countryTextField!.text!
            }
            if self.debug == 1 {
                print("country:", pp_countryTextField!.text!, ppCountryNCityL!)
            }
        }
        
        if (ppAddressL == nil || ppAddressL == "待補充")
        {
            if pp_addressTextField!.text!.isEmpty
            {
                ppAddressL = "待補充"
            }
            else
            {
                ppAddressL = pp_addressTextField!.text!
            }
            if self.debug == 1 {
                print("Address:", pp_addressTextField!.text!, ppAddressL!)
            }
        }

        if (ppFBL == nil || ppFBL == "待補充")
        {
            if pp_fbTextField!.text!.isEmpty
            {
                ppFBL = "待補充"
            }
            else
            {
                ppFBL = pp_fbTextField!.text!
            }
            if self.debug == 1 {
                print("FB:", pp_fbTextField!.text!, ppFBL!)
            }
        }

        if (ppWEBL == nil || ppWEBL == "待補充")
        {
            if pp_webTextField!.text!.isEmpty
            {
                ppWEBL = "待補充"
            }
            else
            {
                ppWEBL = pp_webTextField!.text!
            }
            if self.debug == 1 {
                print("WEB:", pp_webTextField!.text!, ppWEBL!)
            }
        }
        
        if let bloggerIntro = blogger_introTextField!.text
        {
            ppBloggerIntroL = bloggerIntro
            if self.debug == 1 {
                print("Blogger intro:", blogger_introTextField!.text!, ppBloggerIntroL!)
            }
        }
        else
        {
            ppBloggerIntroL = "待補充"
            if self.debug == 1 {
                print("Blogger intro:", blogger_introTextField!.text!, ppBloggerIntroL!)
            }
        }
        
        if let opentime = pp_opentimeTextField!.text
        {
            ppOpentimeL = opentime
            if self.debug == 1 {
                print("Blogger intro:", pp_opentimeTextField!.text!, ppOpentimeL!)
            }
        }
        else
        {
            ppOpentimeL = "待補充"
            if self.debug == 1 {
                print("Blogger intro:", pp_opentimeTextField!.text!, ppOpentimeL!)
            }
        }

        if let note = ppNoteTextField!.text
        {
            ppNoteL = note
            if self.debug == 1 {
                print("ppNoteL :", ppNoteTextField!.text!, ppNoteL!)
            }
        }
        else
        {
            ppNoteL = "待補充"
            if self.debug == 1 {
                print("ppNoteL :", ppNoteTextField!.text!, ppNoteL!)
            }
        }
        
        myScrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    // 按下Return後會反應的事件
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //利用此方式讓按下Return後會Toogle 鍵盤讓它消失
        textField.resignFirstResponder()
        if self.debug == 1 {
            print("按下Return")
        }
        myScrollView.contentOffset = CGPoint(x: 0, y: 0)
        return false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // UIPickerViewDataSource 必須實作的方法：UIPickerView 各列有多少行資料
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            // 返回陣列 week 的成員數量
            return Countries().list.count
        }
        // 否則就是設置第二列
        // 返回陣列 meals 的成員數量
        if sel_country == GloupID().Taiwan_groupID
        {
            return Cities().citiesOfTaiwan.count - 1
        }
        else if sel_country == GloupID().all_groupID
        {
            return Cities().citiesOfAll.count
        }
        else if sel_country == GloupID().Japan_groupID
        {
            return Cities().citiesOfJapan.count - 1
        }
        else if sel_country == GloupID().China_groupID
        {
            return Cities().citiesOfChina.count - 1
        }
        
        return Cities().citiesOfTaiwan.count - 1
    }
    
    // UIPickerView 每個選項顯示的資料
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            // 設置為陣列 week 的第 row 項資料
            sel_country = row + 1
            pickerView.reloadComponent(1) // reload cities
            return Countries().list[row]
        }
        
        // 否則就是設置第二列
        // 設置為陣列 meals 的第 row 項資料
        if sel_country == GloupID().Taiwan_groupID
        {
            return Cities().citiesOfTaiwan[row + 1]
        }
        else if sel_country == GloupID().all_groupID
        {
            return Cities().citiesOfAll
        }
        else if sel_country == GloupID().Japan_groupID
        {
            return Cities().citiesOfJapan[row + 1]
        }
        else if sel_country == GloupID().China_groupID
        {
            return Cities().citiesOfChina[row + 1]
        }
        
        
        return Cities().citiesOfTaiwan[row + 1]
    }
    //pickerview
    // UIPickerView 改變選擇後執行的動作
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let spliteStr = " | "
        if component == 0 {
            ppCountry = Countries().list[row]
            sel_country = row + 1
            ppCountryNCityL = ppCountry! + spliteStr
            ppCity = ""
            pickerView.reloadComponent(1) // reload cities
        } else {
            // 否則就是改變第二列
            // whatMeal 設置為陣列 meals 的第 row 項資料
            
            if sel_country == GloupID().Taiwan_groupID
            {
                ppCity = Cities().citiesOfTaiwan[row + 1]
            }
            else if sel_country == GloupID().all_groupID
            {
                ppCity = Cities().citiesOfAll
            }
            else if sel_country == GloupID().Japan_groupID
            {
                ppCity = Cities().citiesOfJapan[row + 1]
            }
            else if sel_country == GloupID().China_groupID
            {
                ppCity = Cities().citiesOfChina[row + 1]
            }
            ppCountryNCityL = ppCountry! + spliteStr + ppCity!
        }
        
        pp_countryTextField!.text = ppCountryNCityL
    }
    
    func pp_nameViewLoad()
    {
        let offset:float_t = float_t(idx_offset) // * float_t(fullSize.height)
        // 使用 UITextField(frame:) 建立一個 UITextField
        ppNameTextField = UITextField(frame: CGRect(x: 0, y: 0, width: fullSize.width - 30, height: 50))
        //let ppNameTextField = UITextField(frame: CGRect(x: 0, y: 100, width: fullSize.width - 20, height: 50))
        
        // 尚未輸入時的預設顯示提示文字
        ppNameTextField!.placeholder = "輸入景點/店家名稱"
        ppNameTextField!.isUserInteractionEnabled = true
        //ppNameTextField!.endEditing
        
        // layout 置中顯示
        ppNameTextField!.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        // 輸入框的樣式 這邊選擇圓角樣式
        ppNameTextField!.borderStyle = .roundedRect
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        ppNameTextField!.clearButtonMode = .whileEditing
        
        //文字置中
        ppNameTextField!.textAlignment = .center
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        ppNameTextField!.keyboardType = .default
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        ppNameTextField!.returnKeyType = UIReturnKeyType.next
        
        // 輸入文字的顏色
        ppNameTextField!.textColor = UIColor.white
        
        ppNameTextField!.addTarget(self, action: #selector(touchTextField), for: UIControlEvents.touchDown)
        
        ppNameTextField!.tag = nameTextFieldTag
        
        // Delegate
        ppNameTextField!.delegate = self
        
        // UITextField 的背景顏色
        ppNameTextField!.backgroundColor = UIColor.lightGray
        //self.view.addSubview(ppNameTextField)
        myScrollView.addSubview(ppNameTextField!)
    }
    
    func pp_phoneViewLoad()
    {
        idx_offset = idx_offset + Yoffset + 50
        let offset:float_t = float_t(idx_offset) // * float_t(fullSize.height)
        // 使用 UITextField(frame:) 建立一個 UITextField
        ppPhoneTextField = UITextField(frame: CGRect(x: 0, y: 0, width: fullSize.width - 30, height: 50))
        
        // 尚未輸入時的預設顯示提示文字
        ppPhoneTextField!.placeholder = "輸入景點/店家聯絡電話"
        ppPhoneTextField!.isUserInteractionEnabled = true
        
        // 輸入框的樣式 這邊選擇圓角樣式
        ppPhoneTextField!.borderStyle = .roundedRect
        
        // layout 置中顯示
        ppPhoneTextField!.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        ppPhoneTextField!.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        ppPhoneTextField!.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        ppPhoneTextField!.keyboardType = .numberPad
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        ppPhoneTextField!.returnKeyType =  UIReturnKeyType.next
        
        // 輸入文字的顏色
        ppPhoneTextField!.textColor = UIColor.white
        
        ppPhoneTextField!.addTarget(self, action: #selector(touchTextField), for: UIControlEvents.touchDown)
        
        ppPhoneTextField!.tag = phoneTextFieldTag
        
        // Delegate
        ppPhoneTextField!.delegate = self
        
        // UITextField 的背景顏色
        ppPhoneTextField!.backgroundColor = UIColor.lightGray
        //self.view.addSubview(ppPhoneTextField)
        myScrollView.addSubview(ppPhoneTextField!)
    }
    
    func pp_countryViewLoad()
    {
        // 建立一個 UITextField
        idx_offset = idx_offset + Yoffset  + 50
        let offset:float_t = float_t(idx_offset)// * float_t(fullSize.height)
        // 使用 UITextField(frame:) 建立一個 UITextField
        pp_countryTextField = UITextField(frame: CGRect(x: 0, y: 0, width: fullSize.width - 30, height: 50))
        
        // 輸入框的樣式 這邊選擇圓角樣式
        pp_countryTextField!.borderStyle = .roundedRect
        pp_countryTextField!.isUserInteractionEnabled = true
        
        // layout 置中顯示
        pp_countryTextField!.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        pp_countryTextField!.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        pp_countryTextField!.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        pp_countryTextField!.keyboardType = .default
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        pp_countryTextField!.returnKeyType =  UIReturnKeyType.next
        
        // 輸入文字的顏色
        pp_countryTextField!.textColor = UIColor.white
        
        // 設置 UITextField 其他資訊並放入畫面中
        pp_countryTextField!.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
        
        pp_countryTextField!.addTarget(self, action: #selector(touchTextField), for: UIControlEvents.touchDown)
        
        pp_countryTextField!.tag = countryTextFieldTag

        // Delegate
        pp_countryTextField!.delegate = self
        
        // 建立 UIPickerView
        let myPickerView = UIPickerView()
        
        // 設定 UIPickerView 的 delegate 及 dataSource
        myPickerView.delegate = self
        myPickerView.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.lightGray//UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneSelect))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        // 將 UITextField 原先鍵盤的視圖更換成 UIPickerView
        pp_countryTextField!.inputView = myPickerView
        pp_countryTextField!.inputAccessoryView = toolBar
        
        // 設置 UITextField 預設的內容
        pp_countryTextField!.text = ppCountryNCityL//ppCountry + ppCity
        
        // 設置 UITextField 的 tag 以利後續使用
        //pp_countryTextField.text.tag = 100
        
        self.view.addSubview(pp_countryTextField!)
        
        // 尚未輸入時的預設顯示提示文字
        pp_countryTextField!.placeholder = "輸入所在國家"
        
        
        
        // UITextField 的背景顏色
        pp_countryTextField!.backgroundColor = UIColor.lightGray
        //self.view.addSubview(pp_countryTextField)
        myScrollView.addSubview(pp_countryTextField!)
    }
    
    func pp_addressViewLoad()
    {
        idx_offset = idx_offset + Yoffset  + 50
        let offset:float_t = float_t(idx_offset)// * float_t(fullSize.height)
        // 使用 UITextField(frame:) 建立一個 UITextField
        pp_addressTextField = UITextField(frame: CGRect(x: 0, y: 0, width: fullSize.width - 30, height: 50))
        
        // 尚未輸入時的預設顯示提示文字
        pp_addressTextField!.placeholder = "輸入景點/店家的地址"
        pp_addressTextField!.isUserInteractionEnabled = true
        
        // 輸入框的樣式 這邊選擇圓角樣式
        pp_addressTextField!.borderStyle = .roundedRect
        
        // layout 置中顯示
        pp_addressTextField!.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        pp_addressTextField!.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        pp_addressTextField!.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        pp_addressTextField!.keyboardType = .default
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        pp_addressTextField!.returnKeyType =  UIReturnKeyType.next
        
        pp_addressTextField!.addTarget(self, action: #selector(touchTextField), for: UIControlEvents.touchDown)
        
        pp_addressTextField!.tag = addressTextFieldTag
        
        // 輸入文字的顏色
        pp_addressTextField!.textColor = UIColor.white
        
        // Delegate
        pp_addressTextField!.delegate = self
        
        // UITextField 的背景顏色
        pp_addressTextField!.backgroundColor = UIColor.lightGray
        //self.view.addSubview(pp_addressTextField)
        myScrollView.addSubview(pp_addressTextField!)
    }

    func pp_fbViewLoad()
    {
        idx_offset = idx_offset + Yoffset + 50
        let offset:float_t = float_t(idx_offset)// * float_t(fullSize.height)
        // 使用 UITextField(frame:) 建立一個 UITextField
        pp_fbTextField = UITextField(frame: CGRect(x: 0, y: 0, width: fullSize.width - 30, height: 50))
        
        // 尚未輸入時的預設顯示提示文字
        pp_fbTextField!.placeholder = "輸入景點/店家的FB"
        pp_fbTextField!.isUserInteractionEnabled = true
        
        // 輸入框的樣式 這邊選擇圓角樣式
        pp_fbTextField!.borderStyle = .roundedRect
        
        // layout 置中顯示
        pp_fbTextField!.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        pp_fbTextField!.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        pp_fbTextField!.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        pp_fbTextField!.keyboardType = .URL
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        pp_fbTextField!.returnKeyType =  UIReturnKeyType.next
        
        // 輸入文字的顏色
        pp_fbTextField!.textColor = UIColor.white
        
        pp_fbTextField!.addTarget(self, action: #selector(touchTextField), for: UIControlEvents.touchDown)
        
        pp_fbTextField!.tag = fbTextFieldTag
        
        // Delegate
        pp_fbTextField!.delegate = self
        
        // UITextField 的背景顏色
        pp_fbTextField!.backgroundColor = UIColor.lightGray
        //self.view.addSubview(pp_fbTextField)
        myScrollView.addSubview(pp_fbTextField!)
    }

    func pp_webViewLoad()
    {
        idx_offset = idx_offset + Yoffset + 50
        let offset:float_t = float_t(idx_offset)// * float_t(fullSize.height)
        // 使用 UITextField(frame:) 建立一個 UITextField
        pp_webTextField = UITextField(frame: CGRect(x: 0, y: 0, width: fullSize.width - 30, height: 50))
        
        // 尚未輸入時的預設顯示提示文字
        pp_webTextField!.placeholder = "輸入景點/店家的官網"
        pp_webTextField!.isUserInteractionEnabled = true
        
        // 輸入框的樣式 這邊選擇圓角樣式
        pp_webTextField!.borderStyle = .roundedRect
        
        // layout 置中顯示
        pp_webTextField!.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        pp_webTextField!.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        pp_webTextField!.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        pp_webTextField!.keyboardType = .URL
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        pp_webTextField!.returnKeyType =  UIReturnKeyType.next
        
        // 輸入文字的顏色
        pp_webTextField!.textColor = UIColor.white
        
        pp_webTextField!.addTarget(self, action: #selector(touchTextField), for: UIControlEvents.touchDown)
        
        pp_webTextField!.tag = webTextFieldTag
        
        // Delegate
        pp_webTextField!.delegate = self
        
        // UITextField 的背景顏色
        pp_webTextField!.backgroundColor = UIColor.lightGray
        //self.view.addSubview(pp_webTextField)
        myScrollView.addSubview(pp_webTextField!)
    }
    
    func blogger_introViewLoad()
    {
        idx_offset = idx_offset + Yoffset + 50
        let offset:float_t = float_t(idx_offset)// * float_t(fullSize.height)
        if self.debug == 1 {
            print("blogger_introViewLoad() , idx_offset :\(idx_offset)")
        }
        // 使用 UITextField(frame:) 建立一個 UITextField
        blogger_introTextField = UITextField(frame: CGRect(x: 0, y: 0, width: fullSize.width - 30, height: 50))
        
        // 尚未輸入時的預設顯示提示文字
        blogger_introTextField!.placeholder = "輸入介紹景點/店家的部落格網址"
        blogger_introTextField!.isUserInteractionEnabled = true
        
        // 輸入框的樣式 這邊選擇圓角樣式
        blogger_introTextField!.borderStyle = .roundedRect
        
        // layout 置中顯示
        blogger_introTextField!.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        blogger_introTextField!.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        blogger_introTextField!.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        blogger_introTextField!.keyboardType = .URL
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        blogger_introTextField!.returnKeyType =  UIReturnKeyType.next
        
        // 輸入文字的顏色
        blogger_introTextField!.textColor = UIColor.white
        
        blogger_introTextField!.addTarget(self, action: #selector(touchTextField), for: UIControlEvents.touchDown)
        
        blogger_introTextField!.tag = bloggerIntroTextFieldTag
        
        // Delegate
        blogger_introTextField!.delegate = self
        
        // UITextField 的背景顏色
        blogger_introTextField!.backgroundColor = UIColor.lightGray
        //self.view.addSubview(blogger_introTextField)
        myScrollView.addSubview(blogger_introTextField!)
    }
    
    func pp_opentimeViewLoad()
    {
        idx_offset = idx_offset + Yoffset + 50
        let offset:float_t = float_t(idx_offset)// * float_t(fullSize.height)

        // 使用 UITextField(frame:) 建立一個 UITextField
        pp_opentimeTextField = UITextField(frame: CGRect(x: 0, y: 0, width: fullSize.width - 30, height: 50))
        
        // 尚未輸入時的預設顯示提示文字
        pp_opentimeTextField!.placeholder = "輸入介紹景點/店家的部落格網址"
        pp_opentimeTextField!.isUserInteractionEnabled = true
        
        // 輸入框的樣式 這邊選擇圓角樣式
        pp_opentimeTextField!.borderStyle = .roundedRect
        
        // layout 置中顯示
        pp_opentimeTextField!.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        pp_opentimeTextField!.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        pp_opentimeTextField!.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        pp_opentimeTextField!.keyboardType = .URL
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        pp_opentimeTextField!.returnKeyType =  UIReturnKeyType.next
        
        // 輸入文字的顏色
        pp_opentimeTextField!.textColor = UIColor.white
        
        pp_opentimeTextField!.addTarget(self, action: #selector(touchTextField), for: UIControlEvents.touchDown)
        
        pp_opentimeTextField!.tag = opentimeTextFieldTag
        
        // Delegate
        pp_opentimeTextField!.delegate = self
        
        // UITextField 的背景顏色
        pp_opentimeTextField!.backgroundColor = UIColor.lightGray
        //self.view.addSubview(blogger_introTextField)
        myScrollView.addSubview(pp_opentimeTextField!)
    }
    
    func ppNoteViewLoad()
    {
        idx_offset = idx_offset + Yoffset + 50
        let offset:float_t = float_t(idx_offset)// * float_t(fullSize.height)
        if self.debug == 1 {
            print("ppNoteTextField() , idx_offset :\(idx_offset)")
        }
        // 使用 UITextField(frame:) 建立一個 UITextField
        ppNoteTextField = UITextField(frame: CGRect(x: 0, y: 0, width: fullSize.width - 30, height: 50))
        
        // 尚未輸入時的預設顯示提示文字
        ppNoteTextField!.placeholder = "輸入介紹景點/店家的部落格網址"
        ppNoteTextField!.isUserInteractionEnabled = true
        
        // 輸入框的樣式 這邊選擇圓角樣式
        ppNoteTextField!.borderStyle = .roundedRect
        
        // layout 置中顯示
        ppNoteTextField!.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        ppNoteTextField!.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        ppNoteTextField!.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        ppNoteTextField!.keyboardType = .default
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        ppNoteTextField!.returnKeyType =  UIReturnKeyType.continue
        
        // 輸入文字的顏色
        ppNoteTextField!.textColor = UIColor.white
        
        ppNoteTextField!.addTarget(self, action: #selector(touchTextField), for: UIControlEvents.touchDown)
        
        ppNoteTextField!.tag = noetTextFieldTag
        
        // Delegate
        ppNoteTextField!.delegate = self
        
        // UITextField 的背景顏色
        ppNoteTextField!.backgroundColor = UIColor.lightGray

        myScrollView.addSubview(ppNoteTextField!)
    }
    
    func goBackBtn()
    {
        idx_offset = idx_offset + Yoffset + 50
        let offset:float_t = float_t(idx_offset) //* float_t(fullSize.height)
        // 使用 UIButton(frame:) 建立一個 UIButton
        let backButton = UIButton(
            frame: CGRect(x: 0, y: 0, width: fullSize.width / 3 - 10, height: 30))
        
        backButton.setImage(UIImage(named: "if_back@x3"), for: .normal)
        
        backButton.tag=goBackButtonID

        // 按鈕是否可以使用
        backButton.isEnabled = true
        
        // 按鈕按下後的動作
        backButton.addTarget(
            self,
            action: #selector(PP_Handler.goBack),
            for: .touchUpInside)
        
        // 設置位置並加入畫面
        backButton.center = CGPoint(
            x: (fullSize.width / 6 + 5),
            y: CGFloat(offset))
        
        //self.view.addSubview(myButton)
        myScrollView.addSubview(backButton)
        using_height = using_height + Int(offset)
    }
    
    func editeBtn()
    {
        //idx_offset = idx_offset + Yoffset + 50
        let offset:float_t = float_t(idx_offset) //* float_t(fullSize.height)
        // 使用 UIButton(frame:) 建立一個 UIButton
        let editeButton = UIButton(
            frame: CGRect(x: 0, y: 0, width: fullSize.width / 3 - 10, height: 30))
        
        editeButton.setImage(UIImage(named: "edit@x3"), for: .normal)
        
        // 按鈕是否可以使用
        editeButton.isEnabled = true
        
        editeButton.tag=editeButtonID
        
        // 按鈕按下後的動作
        editeButton.addTarget(
            self,
            action: #selector(PP_Handler.edite),
            for: .touchUpInside)
        
        // 設置位置並加入畫面
        editeButton.center = CGPoint(
            x: (fullSize.width / 6 * 3),
            y: CGFloat(offset))
        
        //self.view.addSubview(myButton)
        myScrollView.addSubview(editeButton)
    }
    
    func map_go_Btn()
    {
        //idx_offset = idx_offset + Yoffset + 50
        let offset:float_t = float_t(idx_offset) //* float_t(fullSize.height)
        // 使用 UIButton(frame:) 建立一個 UIButton
        let goButton = UIButton(
            frame: CGRect(x: 0, y: 0, width: fullSize.width / 3 - 10, height: 30))

        goButton.setImage(UIImage(named: "if_map@x3"), for: .normal)
        
        // 按鈕是否可以使用
        goButton.isEnabled = true
        
        goButton.tag=goMapButtonID
        
        // 按鈕按下後的動作
        goButton.addTarget(
            self,
            action: #selector(PP_Handler.mapGO),
            for: .touchUpInside)
        
        // 設置位置並加入畫面
        goButton.center = CGPoint(
            x: (fullSize.width / 6 * 5 - 5),
            y: CGFloat(offset))
        
        myScrollView.addSubview(goButton)
    }
    
    func saveBtn()
    {
        //idx_offset = idx_offset + Yoffset + 50
        let offset:float_t = float_t(idx_offset) //* float_t(fullSize.height)
        // 使用 UIButton(frame:) 建立一個 UIButton
        let myButton = UIButton(
            frame: CGRect(x: 0, y: 0, width: fullSize.width / 3 - 10, height: 30))
        
        // 按鈕文字
        //myButton.setTitle("儲存", for: .normal)
        myButton.setImage(UIImage(named: "save@x3"), for: .normal)
        
        // 按鈕文字顏色
        //myButton.setTitleColor(UIColor.white, for: .normal)
        
        // 按鈕是否可以使用
        myButton.isEnabled = true
        
        myButton.tag=SaveButtonID
        
        // 按鈕按下後的動作
        myButton.addTarget(
            self,
            action: #selector(PP_Handler.saveButton),
            for: .touchUpInside)
        
        // 設置位置並加入畫面
        myButton.center = CGPoint(
            x: (fullSize.width / 6 * 5 - 5),
            y: CGFloat(offset))
        
        //self.view.addSubview(myButton)
        myScrollView.addSubview(myButton)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // 結束編輯 把鍵盤隱藏起來
        self.view.endEditing(true)
        
        return true
    }
    
    func updateLastestData()
    {
        ppNameL = ppNameTextField!.text
        ppPhoneL = ppPhoneTextField!.text
        //ppCountryL = pp_countryTextField!.text
        ppCountryNCityL = pp_countryTextField!.text
        ppAddressL = pp_addressTextField!.text
        ppFBL = pp_fbTextField!.text
        ppWEBL = pp_webTextField!.text
        ppBloggerIntroL = blogger_introTextField!.text
        ppOpentimeL = pp_opentimeTextField!.text
    }
    
    func textFieldCleanup()
    {
        ppNameTextField!.text = ""
        ppPhoneTextField!.text = ""
        pp_countryTextField!.text = ""
        pp_addressTextField!.text = ""
        pp_fbTextField!.text = ""
        pp_webTextField!.text = ""
        blogger_introTextField!.text = ""
        pp_opentimeTextField!.text = ""
    }
    
    func localDataCleanup()
    {
        ppIDL = nil
        ppNameL = nil
        ppPhoneL = nil
        //ppCountryL = nil
        ppCountryNCityL = nil
        ppAddressL = nil
        ppFBL = nil
        ppWEBL = nil
        ppBloggerIntroL = nil
        ppOpentimeL = nil
        ppNoteL = nil
        ppScoreL = nil
        ppDescripL = nil
    }
    
    // scrollview
    
    func scrollViewLoad()
    {

        // 建立 UIScrollView
        myScrollView = UIScrollView()
        
        // 設置尺寸 也就是可見視圖範圍
        myScrollView.frame = CGRect(x: 0, y: 0, width: fullSize.width, height: fullSize.height)
        
        // 實際視圖範圍 為 3*2 個螢幕大小
        myScrollView.contentSize = CGSize(width: fullSize.width, height: fullSize.height)
        
        // 是否顯示水平的滑動條
        myScrollView.showsHorizontalScrollIndicator = false
        
        // 是否顯示垂直的滑動條
        myScrollView.showsVerticalScrollIndicator = false
        
        // 滑動條的樣式
        myScrollView.indicatorStyle = .black
        
        // 是否可以滑動
        myScrollView.isScrollEnabled = true
        
        // 是否可以按狀態列回到最上方
        myScrollView.scrollsToTop = false
        
        // 限制滑動時只能單個方向 垂直或水平滑動
        myScrollView.isDirectionalLockEnabled = false
        
        // 滑動超過範圍時是否使用彈回效果
        myScrollView.bounces = true
        
        // 縮放元件的預設縮放大小
        //myScrollView.zoomScale = 1.0
        
        // 縮放元件可縮小到的最小倍數
        //myScrollView.minimumZoomScale = 0.5
        
        // 縮放元件可放大到的最大倍數
        //myScrollView.maximumZoomScale = 2.0
        
        // 縮放元件縮放時是否在超過縮放倍數後使用彈回效果
        myScrollView.bouncesZoom = true
        
        // 設置委任對象
        myScrollView.delegate = self
        
        // 起始的可見視圖偏移量 預設為 (0, 0)
        // 設定這個值後 就會將原點滑動至這個點起始
        //myScrollView.contentOffset = CGPoint(x: fullSize.width * 0.5, y: fullSize.height)
        
        // 以一頁為單位滑動
        myScrollView.isPagingEnabled = false
        
        // 加入到畫面中
        self.view.addSubview(myScrollView)
   
    }
    
    // 開始滑動時
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.debug == 1 {
            print("scrollViewWillBeginDragging")
        }
    }
    
    // 滑動時
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("scrollViewDidScroll")
    }
    
    // 結束滑動時
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    }
    
    
    // 開始縮放時
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {

    }
    
    // 縮放時
    func scrollViewDidZoom(_ scrollView: UIScrollView) {

    }
    
    // 結束縮放時
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        // 縮放元件時 會將 contentSize 設為這個元件的尺寸
        // 會導致 contentSize 過小而無法滑動
        // 所以縮放完後再將 contentSize 設回原本大小
        myScrollView.contentSize = CGSize(width: fullSize.width, height: fullSize.height * 1.5)
    }
    
    func Hint(mesg:String) {
        // 建立一個提示框
        let alertController = UIAlertController(
            title: "放入手冊中",
            message: mesg,
            preferredStyle: .alert)
        
        // 建立[確認]按鈕
        let okAction = UIAlertAction(
            title: "確認",
            style: .default,
            handler: {
                (action: UIAlertAction!) -> Void in
                if self.debug == 1 {
                    print("按下確認後，閉包裡的動作")
                }
                //self.textFieldCleanup()
                self.editSwitch(onoff: false)
                self.disableButton(ButtonID: self.SaveButtonID)
                self.enableButton(ButtonID: self.goMapButtonID)
                self.enableButton(ButtonID: self.editeButtonID)
        })
        alertController.addAction(okAction)
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
    
    func editSwitch(onoff:Bool)
    {
        editOnOff = onoff
    }
    
    func enableButton(ButtonID:Int)
    {
        self.view.viewWithTag(ButtonID)?.isHidden = false
    }
    
    func disableButton(ButtonID:Int)
    {
        //self.view.viewWithTag(ButtonID)?.removeFromSuperview()
        self.view.viewWithTag(ButtonID)?.isHidden = true
    }
    
    @objc func saveButton() {
        if ppNameL == nil || ppPhoneL == nil
            || ppAddressL == nil
            || ppCountryNCityL == nil
            || ppWEBL == nil || ppBloggerIntroL == nil
        {
            if self.debug == 1 {
                print("無資料")
            }
        }
        else
        {
            let db:DB_Access? = DB_Access()
            //let searchAddr_caches = db!.pp_searchByAddress(address: ppAddressL, country: ppCountryL)
            let searchName_caches = db!.pp_searchByName(name: ppNameL!, country: ppCountry!)
            if (searchName_caches == nil)
            {
                if self.debug == 1 {
                    print("Didn't have same data in DB")
                }
                if db!.pp_insert(pp_name: ppNameL, pp_phone: ppPhoneL, pp_country: ppCountryNCityL, pp_address: ppAddressL, pp_fb: ppFBL, pp_web: ppWEBL ,pp_blogger_intro: ppBloggerIntroL, pp_opentime: ppOpentimeL, pp_note: ppNoteL, pp_descrip: ppDescripL, pp_score: ppScoreL ) > 0
                {
                    if self.debug == 1 {
                        print("新增成功")
                    }
                    Hint(mesg: "新增成功")
                }
                else {
                    if self.debug == 1 {
                        print("新增失敗")
                    }
                    Hint(mesg: "新增失敗")
                }
            }
            else
            {
                if self.debug == 1 {
                    print("Already had same data")
                    print("Into Update Mode, ID:", ppIDL!)
                }
                let ppDescripL = ""
                updateLastestData()
                if db!.pp_update(id: ppIDL,pp_name: ppNameL, pp_phone: ppPhoneL, pp_country: ppCountryNCityL, pp_address: ppAddressL, pp_fb: ppFBL, pp_web: ppWEBL ,pp_blogger_intro: ppBloggerIntroL, pp_opentime: ppOpentimeL, pp_note: ppNoteL, pp_descrip: ppDescripL, pp_score: ppScoreL )
                {
                    if self.debug == 1 {
                        print("更新成功")
                    }
                    Hint(mesg: "更新成功")
                }
                else {
                    if self.debug == 1 {
                        print("更新失敗")
                    }
                    Hint(mesg: "更新失敗")
                }
            }
            
        }
    }
    
    @objc func mapGO()
    {
        if self.debug == 1 {
            print("open map....")
        }
        let addressTextField = self.view?.viewWithTag(addressTextFieldTag) as? UITextField


        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!))
        {
            let callWebview =   UIWebView()
            let addr:NSString = addressTextField!.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! as NSString
            let directionsRequest = "comgooglemaps://" +
                "?daddr=\(addr))" +
            "&x-success=sourceapp://?resume=true&x-source=AirApp&views=traffic"
            if self.debug == 1 {
                print("Direction Address: ",directionsRequest)
            }
            callWebview.loadRequest(NSURLRequest(url: URL(string: directionsRequest)!) as URLRequest)
            self.view.addSubview(callWebview)
        } else {
            if self.debug == 1 {
                print("Can't use comgooglemaps://");
            }
            if (UIApplication.shared.canOpenURL(URL(string:"http://maps.apple.com/")!))
            {
                if self.debug == 1 {
                    print("We can open apple map url")
                }
                let callWebview =   UIWebView()
                let addr:NSString = addressTextField!.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! as NSString
                let directionsRequest = "http://maps.apple.com/" +
                "?daddr=\(addr))"
                if self.debug == 1 {
                    print("Direction Address: ",directionsRequest)
                }
                callWebview.loadRequest(NSURLRequest(url: URL(string: directionsRequest)!) as URLRequest)
                self.view.addSubview(callWebview)
            }
            else
            {
                if self.debug == 1 {
                    print("Apple map url open fail")
                }
            }
        }
    }
    
    @objc func edite()
    {
        if self.debug == 1 {
            print("click edite")
        }

        editSwitch(onoff: true)
        disableButton(ButtonID: editeButtonID)
        disableButton(ButtonID: goMapButtonID)
        enableButton(ButtonID: SaveButtonID)
    }
    
    @objc func goBack() {
        textFieldCleanup()
        localDataCleanup()
        self.dismiss(animated: true, completion:nil)
    }
    
    @objc func touchTextField(textField: UITextField)
    {
        if self.debug == 1 {
            print("TouchTextField:")
        }
        if (editOnOff)
        {
            return
        }

        if (textField.tag == nameTextFieldTag)
        {
            if self.debug == 1 {
                print("Touch: NameTextField")
            }
        }
        else if (textField.tag == phoneTextFieldTag)
        {
            if self.debug == 1 {
                print("Touch: PhoneTextField")
            }
            //let callWebview =   UIWebView()
            //let url = URL(string: "telprompt://\(textField.text!)")
            //print("Phone URL: ", "telprompt://\(textField.text!)")
            //callWebview.loadRequest(NSURLRequest(url: URL(string: "telprompt://\(textField.text!)")!) as URLRequest)
            //self.view.addSubview(callWebview)
            if UIApplication.shared.canOpenURL(URL(string:"tel://")!) != true
            {
                if self.debug == 1 {
                    print("Can 't Open tel://")
                }
                return
            }
            if let numb = textField.text
            {
                let cleanNum = numb.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
                let urlStr = URL(string: "tel://\(cleanNum)")
                if (UIApplication.shared.canOpenURL(urlStr!)) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(urlStr!, options: [:], completionHandler: nil)
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(urlStr!)
                    }
                    return
                }
            }
            else
            {
                handlrViewHint(Title: "提醒", msgStr: "請更新\"電話號碼\"", BtnTitle: "確認")
            }
        }
        else if (textField.tag == countryTextFieldTag)
        {
            if self.debug == 1 {
                print("Touch: CountryTextField")
            }
        }
        else if (textField.tag == addressTextFieldTag)
        {
            // api : https://developers.google.com/maps/documentation/urls/ios-urlscheme
            if self.debug == 1 {
                print("Touch: AddressTextField")
            }
            mapGO()
        }
        else if (textField.tag == fbTextFieldTag)
        {
            if let url = textField.text
            {
                if self.debug == 1 {
                    print("FB URL: ", url)
                }
                if url.hasPrefix("http")
                {
                    if self.debug == 1 {
                        print("url hasPrefix", url.hasPrefix("http"))
                    }
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(NSURL(string: url)! as URL, options: [:], completionHandler: nil)
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(NSURL(string: url)! as URL)
                    }
                    return
                }
                else
                {
                    if self.debug == 1 {
                        print("url --- 待補充? ", url)
                    }
                }
            }
            handlrViewHint(Title: "提醒", msgStr: "請更新\"粉絲團\"網址", BtnTitle: "確認")
        }
        else if (textField.tag == webTextFieldTag)
        {
            if self.debug == 1 {
                print("Touch: WebTextField")
            }
            if let url = textField.text
            {
                if self.debug == 1 {
                    print("Web URL: ", url)
                }
                if url.hasPrefix("http")
                {
                    if self.debug == 1 {
                        print("url hasPrefix", url.hasPrefix("http"))
                    }
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(NSURL(string: url)! as URL, options: [:], completionHandler: nil)
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(NSURL(string: url)! as URL)
                    }
                    return
                }
                else
                {
                    if self.debug == 1 {
                        print("url --- 待補充? ", url)
                    }
                }
            }
            handlrViewHint(Title: "提醒", msgStr: "請更新\"官方網站\"", BtnTitle: "確認")
        }
        else if (textField.tag == bloggerIntroTextFieldTag)
        {
            if self.debug == 1 {
                print("Touch: BloggerIntroTextField")
            }
            if let url = textField.text
            {
                if self.debug == 1 {
                    print("bloggerIntro URL: ", url)
                }
                if url.hasPrefix("http")
                {
                    if self.debug == 1 {
                        print("url hasPrefix", url.hasPrefix("http"))
                    }
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(NSURL(string: url)! as URL, options: [:], completionHandler: nil)
                    } else {
                        // Fallback on earlier versions
                        UIApplication.shared.openURL(NSURL(string: url)! as URL)
                    }
                    return
                }
                else
                {
                    if self.debug == 1 {
                        print("url --- 待補充? ", url)
                    }
                }
            }
            handlrViewHint(Title: "提醒", msgStr: "請更新\"部落客介紹\"", BtnTitle: "確認")
        }
        else
        {
            handlrViewHint(Title: "提醒", msgStr: "按下\"鉛筆\"圖案即可編輯唷!", BtnTitle: "確認")
        }
    }
    
    func handlrViewHint(Title:String, msgStr:String, BtnTitle:String) {
        if Title == "" || msgStr == "" || BtnTitle == ""
        {
            if self.debug == 1 {
                print("handlrViewHint: input null")
            }
            return
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
        })
        alertController.addAction(okAction)
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
    
    @objc func doneSelect()
    {
        let spliteStr = " | "
    
        if !ppCountry!.isEmpty
        {
            ppCountryNCityL = ppCountry! + spliteStr
        }
        if !ppCity!.isEmpty
        {
            ppCountryNCityL = ppCountryNCityL + ppCity!
        } else {
            if sel_country == GloupID().Taiwan_groupID
            {
                ppCity = Cities().citiesOfTaiwan[1]
            }
            else if sel_country == GloupID().all_groupID
            {
                ppCity = Cities().citiesOfAll
            }
            else if sel_country == GloupID().Japan_groupID
            {
                ppCity = Cities().citiesOfJapan[1]
            }
            else if sel_country == GloupID().China_groupID
            {
                ppCity = Cities().citiesOfChina[1]
            }
            ppCountryNCityL = ppCountryNCityL + ppCity!
        }
        pp_countryTextField?.text = ppCountryNCityL
        pp_countryTextField?.resignFirstResponder()
        if self.debug == 1 {
            print (" ppCountryNCityL : ", ppCountryNCityL)
            print("Picker DONE")
        }
        //self.view.endEditing(true)
    }
    
    // 按空白處會隱藏編輯狀態
    @objc func hideKeyboard(tapG:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
}
