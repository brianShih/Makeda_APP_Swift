//
//  addViewController.swift
//  Makeda
//
//  Created by Brian on 2018/8/31.
//  Copyright © 2018年 breadcrumbs.tw. All rights reserved.
//

//
//  ViewController.swift
//  Makeda
//
//  Created by Brian on 2017/7/12.
//  Copyright © 2017年 breadcrumbs.tw. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds

class AddViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate
                            ,UIPickerViewDelegate, UIPickerViewDataSource, GADBannerViewDelegate {
    let debug = 0
    let fullSize = UIScreen.main.bounds.size
    var addfram_ScrollView: UIScrollView!
    var SearchTabVC: SearchResultTabViewController?
    //let countries = ["台灣","日本"]
    var re_edit = 0
    var using_height = 0
    var idx_offset = 50
    let Yoffset = 10
    var bannerView: GADBannerView!
    private var sel_country = 0
    var locateMode = 0
    var ppCountry = "台灣"
    var ppCity = "彰化縣"
    var ppNameL:String! = nil
    var ppPhoneL:String! = nil
    var ppCountryNCityL:String! = nil
    var ppAddressL:String! = nil
    var ppFBL:String! = nil
    var ppWEBL:String! = nil
    var ppBloggerIntroL:String! = nil
    var ppOpentimeL:String! = nil
    var ppNoteL:String? = String("待補充")
    var ppScoreL:String? = String("0")
    var ppDescripL:String? = String(" ")
    
    let NameTextFieldTag:Int = 200
    let PhoneTextFieldTag:Int = 201
    let ppPickTextFieldTag:Int = 202
    let AddressTextFieldTag:Int = 203
    let FBTextFieldTag:Int = 204
    let WebTextFieldTag:Int = 205
    let BloggerIntroTextFieldTag:Int = 206
    let OpentimeTextFieldTag:Int = 207
    let NoteTextFieldTag:Int = 208
    let ScoreTextFieldTag:Int = 209
    let DescriptTextFieldTag:Int = 210

    let frameGap = 30
    let nameFrameHeight = 50
    let phoneFrameHeight = 50
    let countryFrameHeight = 50
    let addrFrameHeight = 50
    let fbFrameHeight = 50
    let webFrameHeight = 50
    let bloggerFrameHeight = 50
    let opentimeFrameHeight = 50
    let noteFrameHeight = 50
    let descriptFrameHeight = 100
    let saveBtnFrameHeight = 30
    
    var ppNameTextField:UITextField! = nil
    var ppPhoneTextField:UITextField! = nil
    var pp_pickTextField:UITextField! = nil
    var pp_addressTextField:UITextField! = nil
    var pp_fbTextField:UITextField! = nil
    var pp_webTextField:UITextField! = nil
    var blogger_introTextField:UITextField! = nil
    var pp_opentimeTextField:UITextField! = nil
    var pp_noteTextField:UITextField! = nil
    var pp_scoreTextField:UITextField! = nil
    var pp_descriptTextView:UITextView! = nil
    

    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "手動新增"
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 160/255, blue: 1, alpha: 0.8)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        if self.debug == 1 {
            print("viewWillAppear")
        }
        //TODO -- load search value
        let myUserDefaults = UserDefaults.standard
        if var mapItemsUpdated = myUserDefaults.object(forKey: "mapItemsDataUpdate") as? Int {
            if self.debug == 1 {
                print("viewWillAppear: mapItemsUpdated: ", mapItemsUpdated)
            }
            
            // clean up flag
            if mapItemsUpdated == 1
            {
                if let pp_name = myUserDefaults.object(forKey: "ppItemsName") as? String {
                    if self.debug == 1 {
                        print("call back ppName: ",pp_name)
                    }
                    ppNameTextField.text = pp_name
                    ppNameL = pp_name
                }
                
                if let pp_phone = myUserDefaults.object(forKey: "ppItemsPhone") as? String {
                    if self.debug == 1 {
                        print("call back ppPhone: ",pp_phone)
                    }
                    ppPhoneTextField.text = pp_phone
                    ppPhoneL = pp_phone
                }
                
                if let pp_country = myUserDefaults.object(forKey: "ppItemsCountry") as? String {
                    if self.debug == 1 {
                        print("call back ppCountry: ",pp_country)
                    }
                    ppCountry = pp_country
                    let spliteStr = " | "
                    if let pp_city = myUserDefaults.object(forKey: "ppItemsCity") as? String {
                        ppCity = pp_city
                        ppCountryNCityL = pp_country + spliteStr + pp_city
                        pp_pickTextField.text = pp_country + spliteStr + pp_city
                    }
                }
                
                if let pp_addr = myUserDefaults.object(forKey: "ppItemsAddress") as? String {
                    if self.debug == 1 {
                        print("call back address: ",pp_addr)
                    }
                    pp_addressTextField.text = pp_addr
                    ppAddressL = pp_addr
                }
                
                if let pp_fb = myUserDefaults.object(forKey: "ppItemsFBUrl") as? String {
                    if self.debug == 1 {
                        print("call back fb: ",pp_fb)
                    }
                    pp_fbTextField.text = pp_fb
                    ppFBL = pp_fb
                }
                
                if let pp_web = myUserDefaults.object(forKey: "ppItemsWebUrl") as? String {
                    if self.debug == 1 {
                        print("call back web: ",pp_web)
                    }
                    pp_webTextField.text = pp_web
                    ppWEBL = pp_web
                }
                
                if let pp_bloggerIntro = myUserDefaults.object(forKey: "ppItemsBloggerIntro") as? String {
                    if self.debug == 1 {
                        print("call back blog: ",pp_bloggerIntro)
                    }
                    blogger_introTextField.text = pp_bloggerIntro
                    ppBloggerIntroL = pp_bloggerIntro
                }
                
                if let pp_opentime = myUserDefaults.object(forKey: "ppItemsOpentime") as? String {
                    if self.debug == 1 {
                        print("call back blog: ",pp_opentime)
                    }
                    pp_opentimeTextField.text = pp_opentime
                    ppOpentimeL = pp_opentime
                }
                
                if let pp_note = myUserDefaults.object(forKey: "ppItemsNote") as? String {
                    if self.debug == 1 {
                        print("call back pp_note: ",pp_note)
                    }
                    pp_noteTextField.text = pp_note
                    ppNoteL = pp_note
                }
                
                if let pp_score = myUserDefaults.object(forKey: "ppItemsScore") as? String {
                    if self.debug == 1 {
                        print("call back pp_score: ",pp_score)
                    }
                    //pp_scoreTextField.text = pp_score
                    ppScoreL = pp_score
                }
                
                
                mapItemsUpdated = 0
                myUserDefaults.set(mapItemsUpdated, forKey: "mapItemsDataUpdate")
                myUserDefaults.synchronize()
                addfram_ScrollView.contentOffset = CGPoint(x: 0, y: 0)
            }
        }
    }

    override func viewDidLoad() {
        if self.debug == 1 {
            print("viewDidLoad")
        }
        super.viewDidLoad()
        loadGoogleBannerAD()
        scrollViewLoad()
        pp_searchItem()

        pp_nameViewLoad()
        pp_phoneViewLoad()
        pp_PickLocateViewLoad()
        pp_addressViewLoad()
        pp_fbViewLoad()
        pp_webViewLoad()
        blogger_introViewLoad()
        pp_opentimeViewLoad()
        pp_noteViewLoad()
        pp_scoreViewLoad()
        pp_descriptViewLoad()
        saveBtn()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        if using_height > Int(fullSize.height)
        {
            addfram_ScrollView.contentSize = CGSize(width: fullSize.width, height: CGFloat(using_height+50))
        }
        if SearchTabVC == nil
        {
            SearchTabVC = SearchResultTabViewController(nibName: "SearchTabVC", bundle: nil)
            if self.debug == 1 {
                print("Re-Init SearchTabVC")
            }
        }
        
        //using_high
        if self.debug == 1 {
            print("using hieght :", using_height, "fullsize height:", fullSize.height)
        }

        // Do any additional setup after loading the view, typically from a nib.
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddViewController.hideKeyboard(tapG:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // setup UserDefault db flag
        let myUserDefaults = UserDefaults.standard
        myUserDefaults.set(0, forKey: "mapItemsDataUpdate")
        myUserDefaults.synchronize()
    }
    
    // 設定delegate 為self後，可以自行增加delegate protocol
    // 開始進入編輯狀態
    func textFieldDidBeginEditing(_ textField: UITextField){
        //print("textFieldDidBeginEditing:" + textField.text!)
        /*
        let scrolling_offset = 80
        var offsetY = textField.frame.minY - CGFloat(scrolling_offset)
        if (textField.frame.minY <= CGFloat(scrolling_offset))
        {
            offsetY = 0
        }
        addfram_ScrollView.contentOffset = CGPoint(x: 0, y: offsetY)
         */
        //print("offset Y:", offsetY)
    }
    
    // 可能進入結束編輯狀態
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //print("textFieldShouldEndEditing:" + textField.text!)
        
        return true
    }
    
    // 結束編輯狀態(意指完成輸入或離開焦點)
    func textFieldDidEndEditing(_ textField: UITextField) {
        //print("textFieldDidEndEditing:" + textField.text!)
        //print("var :",ppNameTextField.text!, ppPhoneTextField.text!, pp_countryTextField.text!, pp_addressTextField.text!, pp_fbTextField.text!, pp_webTextField.text!, blogger_introTextField.text!)
        if let name = ppNameTextField.text
        {
            ppNameL = name
            //print("ppNameL:", ppNameTextField.text!, ppNameL!)
            
        }
        else
        {
            ppNameL = "-"
            //print("ppNameL:", ppNameTextField.text!, ppNameL!)
        }
        
        if let phone = ppPhoneTextField.text
        {
            ppPhoneL = phone
            //print("ppPhoneL:", ppPhoneTextField.text!, ppPhoneL!)
            
        }
        else
        {
            ppPhoneL = "-"
            //print("ppPhoneL:", ppPhoneTextField.text!, ppPhoneL!)
        }

        if pp_pickTextField.text != nil
        {
            ppCountryNCityL = ppCountry + " | " + ppCity//pp_pickTextField.text!
            //print("ppCountryNCityL:", pp_pickTextField.text!, ppCountryNCityL!)
            
        }
        else
        {
            ppCountryNCityL = "請選擇"
            //print("ppCountryNCityL:", pp_pickTextField.text!, ppCountryNCityL!)
        }

        
        if let address = pp_addressTextField.text
        {
            ppAddressL = address
            //print("ppPhoneL:", pp_addressTextField.text!, ppAddressL!)
            
        }
        else
        {
            ppAddressL = "-"
            //print("ppFBL:", pp_addressTextField.text!, ppAddressL!)
        }
        
        if let fb = pp_fbTextField.text
        {
            ppFBL = fb
            //print("ppFBL:", pp_fbTextField.text!, ppFBL!)
            
        }
        else
        {
            ppFBL = "-"
            //print("ppAddressL:", pp_fbTextField.text!, ppFBL!)
        }
        
        if let web = pp_webTextField.text
        {
            ppWEBL = web
            //print("ppWEBL:", pp_webTextField.text!, ppWEBL!)
            
        }
        else
        {
            ppWEBL = "-"
            //print("ppWEBL:", pp_webTextField.text!, ppWEBL!)
        }

        if let blogger = blogger_introTextField.text
        {
            ppBloggerIntroL = blogger
            //print("ppBloggerIntroL:", blogger_introTextField.text!, ppBloggerIntroL!)
            
        }
        else
        {
            ppBloggerIntroL = "-"
            //print("ppBloggerIntroL:", blogger_introTextField.text!, ppBloggerIntroL!)
        }
        
        if let opentime = pp_opentimeTextField.text
        {
            ppOpentimeL = opentime
            //print("ppOpentimeL:", pp_opentimeTextField.text!, ppOpentimeL!)
            
        }
        else
        {
            ppOpentimeL = " "
            //print("ppOpentimeL:", pp_opentimeTextField.text!, ppOpentimeL!)
        }

        if let note = pp_noteTextField.text
        {
            ppNoteL = note
            //print("ppNoteL:", pp_noteTextField.text!, ppNoteL!)
            
        }
        else
        {
            ppNoteL = "-"
            //print("ppNoteL:", pp_noteTextField.text!, ppNoteL!)
        }
        
        if (ppScoreL == nil || ppScoreL == "待補充")
        {
            ppScoreL = "0"
            //print("ppScoreL:", ppScoreL!)
        }

        addfram_ScrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    // 按下Return後會反應的事件
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //利用此方式讓按下Return後會Toogle 鍵盤讓它消失
        textField.resignFirstResponder()
        if self.debug == 1 {
            print("按下Return")
        }
        addfram_ScrollView.contentOffset = CGPoint(x: 0, y: 0)
        return false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if self.debug == 1 {
            print("pickerView000")
        }
        return 2
    }
    
    // UIPickerViewDataSource 必須實作的方法：UIPickerView 各列有多少行資料
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // 設置第一列時
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
        // 設置第一列時
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
            //ppCountryNCityL = Countries().list[row]
            ppCountry = Countries().list[row]
            sel_country = row + 1
            ppCountryNCityL = ppCountry + spliteStr
            ppCity = ""
            
            //if sel_country == GloupID().all_groupID
            //{
            //    city = Cities().citiesOfTaiwan[0]
            //}
            pickerView.reloadComponent(1) // reload cities
            if self.debug == 1 {
                print("country row: \(row)" )
                print("Country Selected : ", ppCountry)
            }
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
            ppCountryNCityL = ppCountry + spliteStr + ppCity
        }
        
        pp_pickTextField.text = ppCountryNCityL
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pp_searchItem()
    {
        // 導覽列左邊按鈕
        let rightButton = UIBarButtonItem(title: "線上搜尋", style: .done, target: self, action: #selector(AddViewController.clickSearchBtn))
        
        // 加到導覽列中
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        //UIColor.white
    }
    
    func pp_nameViewLoad()
    {
        let frameWidth = Int(fullSize.width) - frameGap
        //let offset:float_t = float_t(idx_offset) // * float_t(fullSize.height)
        // 使用 UITextField(frame:) 建立一個 UITextField
        ppNameTextField = UITextField(frame: CGRect(x: frameGap/2, y: Yoffset, width: frameWidth, height: nameFrameHeight))
        idx_offset = Yoffset + nameFrameHeight
        
        // 尚未輸入時的預設顯示提示文字
        ppNameTextField.placeholder = "輸入景點/店家名稱"

        // layout 置中顯示
        //ppNameTextField.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        // 輸入框的樣式 這邊選擇圓角樣式
        ppNameTextField.borderStyle = .roundedRect
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        ppNameTextField.clearButtonMode = .whileEditing
        
        //文字置中
        ppNameTextField.textAlignment = .center
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        ppNameTextField.keyboardType = .default
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        ppNameTextField.returnKeyType = UIReturnKeyType.next
        
        // 輸入文字的顏色
        ppNameTextField.textColor = UIColor.gray
        
        ppNameTextField.tag = NameTextFieldTag
        
        // Delegate
        ppNameTextField.delegate = self
        
        // UITextField 的背景顏色
        ppNameTextField.backgroundColor = UIColor.clear
        //self.view.addSubview(ppNameTextField)
        addfram_ScrollView.addSubview(ppNameTextField)
    }
    
    func pp_phoneViewLoad()
    {
        let frameWidth = Int(fullSize.width) - frameGap
        idx_offset = idx_offset + Yoffset
        //let offset:float_t = float_t(idx_offset) // * float_t(fullSize.height)
        // 使用 UITextField(frame:) 建立一個 UITextField
        ppPhoneTextField = UITextField(frame: CGRect(x: frameGap/2, y: idx_offset, width: frameWidth, height: phoneFrameHeight))
        idx_offset = idx_offset + phoneFrameHeight
        
        // 尚未輸入時的預設顯示提示文字
        ppPhoneTextField.placeholder = "輸入景點/店家聯絡電話"
        
        // 輸入框的樣式 這邊選擇圓角樣式
        ppPhoneTextField.borderStyle = .roundedRect
        
        // layout 置中顯示
        //ppPhoneTextField.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))

        //文字置中
        ppPhoneTextField.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        ppPhoneTextField.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        ppPhoneTextField.keyboardType = .numberPad
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        ppPhoneTextField.returnKeyType =  UIReturnKeyType.next
        
        // 輸入文字的顏色
        ppPhoneTextField.textColor = UIColor.gray
        
        ppPhoneTextField.tag = PhoneTextFieldTag
        
        // Delegate
        ppPhoneTextField.delegate = self
        
        // UITextField 的背景顏色
        ppPhoneTextField.backgroundColor = UIColor.clear
        //self.view.addSubview(ppPhoneTextField)
        addfram_ScrollView.addSubview(ppPhoneTextField)
    }
    
    func pp_PickLocateViewLoad()
    {
        let frameWidth = Int(fullSize.width) - frameGap
        // 建立一個 UITextField
        idx_offset = idx_offset + Yoffset//  + phoneFrameHeight
        //let offset:float_t = float_t(idx_offset)// * float_t(fullSize.height)
        // 使用 UITextField(frame:) 建立一個 UITextField
        pp_pickTextField = UITextField(frame: CGRect(x: frameGap / 2, y: idx_offset, width: frameWidth, height: countryFrameHeight))
        idx_offset = idx_offset + countryFrameHeight
        
        // 輸入框的樣式 這邊選擇圓角樣式
        pp_pickTextField.borderStyle = .roundedRect
        
        // layout 置中顯示
        //pp_pickTextField.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        pp_pickTextField.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        pp_pickTextField.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        pp_pickTextField.keyboardType = .default
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        pp_pickTextField.returnKeyType =  UIReturnKeyType.next
        
        // 輸入文字的顏色
        pp_pickTextField.textColor = UIColor.gray
        
        // 設置 UITextField 其他資訊並放入畫面中
        pp_pickTextField.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
        
        pp_pickTextField.tag = ppPickTextFieldTag
        
        // Delegate
        pp_pickTextField.delegate = self
        
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
        pp_pickTextField.inputView = myPickerView
        
        pp_pickTextField.inputAccessoryView = toolBar
        
        // 設置 UITextField 預設的內容
        pp_pickTextField.text = "\(Countries().list[sel_country])  |  \(Cities().citiesOfTaiwan[1])"
        
        // 設置 UITextField 的 tag 以利後續使用
        //pp_countryTextField.text.tag = 100

        //self.view.addSubview(pp_countryTextField)
        
        // 尚未輸入時的預設顯示提示文字
        pp_pickTextField.placeholder = "輸入所在國家"
        

        
        // UITextField 的背景顏色
        pp_pickTextField.backgroundColor = UIColor.clear
        //self.view.addSubview(pp_countryTextField)
        addfram_ScrollView.addSubview(pp_pickTextField)
    }
    
    func pp_addressViewLoad()
    {
        let frameWidth = Int(fullSize.width) - frameGap - 30
        idx_offset = idx_offset + Yoffset//  + countryFrameHeight
        //let offset:float_t = float_t(idx_offset)// * float_t(fullSize.height)
        // 使用 UITextField(frame:) 建立一個 UITextField
        pp_addressTextField = UITextField(frame: CGRect(x: frameGap/2, y: idx_offset, width: frameWidth, height: addrFrameHeight))
        
        // 尚未輸入時的預設顯示提示文字
        pp_addressTextField.placeholder = "輸入景點/店家的地址"
        
        // 輸入框的樣式 這邊選擇圓角樣式
        pp_addressTextField.borderStyle = .roundedRect
        
        // layout 置中顯示
        //pp_addressTextField.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        pp_addressTextField.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        pp_addressTextField.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        pp_addressTextField.keyboardType = .default
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        pp_addressTextField.returnKeyType =  UIReturnKeyType.next
        
        // 輸入文字的顏色
        pp_addressTextField.textColor = UIColor.gray
        
        pp_addressTextField.tag = AddressTextFieldTag
        
        // Delegate
        pp_addressTextField.delegate = self
        
        // UITextField 的背景顏色
        pp_addressTextField.backgroundColor = UIColor.clear
        //self.view.addSubview(pp_addressTextField)
        addfram_ScrollView.addSubview(pp_addressTextField)
        
        let X = Int(fullSize.width) - saveBtnFrameHeight
        //let btnFrameGap = Int(fullSize.width) - 160
        //idx_offset = idx_offset + Yoffset// + descriptFrameHeight
        //let offset:float_t = float_t(idx_offset) //* float_t(fullSize.height)
        // 使用 UIButton(frame:) 建立一個 UIButton
        let locateBTN = UIButton(
            frame: CGRect(x: X - 5, y: idx_offset + 10, width: 30, height: 30))
        locateBTN.setImage(UIImage(named: "tracker"), for: .normal)
        // 按鈕文字
        //locateBTN.setTitle("收藏", for: .normal)
        
        // 按鈕文字顏色
        //locateBTN.setTitleColor(UIColor.white, for: .normal)
        
        // 按鈕是否可以使用
        locateBTN.isEnabled = true
        
        // 按鈕背景顏色
        locateBTN.backgroundColor = UIColor.clear
        //UIColor.darkGray
        
        // 按鈕按下後的動作
        locateBTN.addTarget(
            self,
            action: #selector(AddViewController.locate),
            for: .touchUpInside)
        addfram_ScrollView.addSubview(locateBTN)
        
        idx_offset = idx_offset + addrFrameHeight
    }

    func pp_fbViewLoad()
    {
        let frameWidth = Int(fullSize.width) - frameGap
        idx_offset = idx_offset + Yoffset// + addrFrameHeight
        //let offset:float_t = float_t(idx_offset)// * float_t(fullSize.height)
        // 使用 UITextField(frame:) 建立一個 UITextField
        pp_fbTextField = UITextField(frame: CGRect(x: frameGap / 2, y: idx_offset, width: frameWidth, height: fbFrameHeight))
        idx_offset = idx_offset + fbFrameHeight
        
        // 尚未輸入時的預設顯示提示文字
        pp_fbTextField.placeholder = "輸入景點/店家的FB"
        
        // 輸入框的樣式 這邊選擇圓角樣式
        pp_fbTextField.borderStyle = .roundedRect
        
        pp_fbTextField.tag = FBTextFieldTag
        
        // layout 置中顯示
        //pp_fbTextField.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        pp_fbTextField.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        pp_fbTextField.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        pp_fbTextField.keyboardType = .URL
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        pp_fbTextField.returnKeyType =  UIReturnKeyType.next
        
        // 輸入文字的顏色
        pp_fbTextField.textColor = UIColor.gray
        
        // Delegate
        pp_fbTextField.delegate = self
        
        // UITextField 的背景顏色
        pp_fbTextField.backgroundColor = UIColor.clear
        //self.view.addSubview(pp_fbTextField)
        addfram_ScrollView.addSubview(pp_fbTextField)
    }

    func pp_webViewLoad()
    {
        let frameWidth = Int(fullSize.width) - frameGap
        idx_offset = idx_offset + Yoffset// + fbFrameHeight
        //let offset:float_t = float_t(idx_offset)// * float_t(fullSize.height)
        // 使用 UITextField(frame:) 建立一個 UITextField
        pp_webTextField = UITextField(frame: CGRect(x: frameGap/2, y: idx_offset, width: frameWidth, height: webFrameHeight))
        idx_offset = idx_offset + webFrameHeight
        
        // 尚未輸入時的預設顯示提示文字
        pp_webTextField.placeholder = "輸入景點/店家的官網"
        
        // 輸入框的樣式 這邊選擇圓角樣式
        pp_webTextField.borderStyle = .roundedRect
        
        // layout 置中顯示
        //pp_webTextField.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        pp_webTextField.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        pp_webTextField.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        pp_webTextField.keyboardType = .URL
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        pp_webTextField.returnKeyType =  UIReturnKeyType.next
        
        // 輸入文字的顏色
        pp_webTextField.textColor = UIColor.gray
        
        pp_webTextField.tag = WebTextFieldTag
        
        // Delegate
        pp_webTextField.delegate = self
        
        // UITextField 的背景顏色
        pp_webTextField.backgroundColor = UIColor.clear
        //self.view.addSubview(pp_webTextField)
        addfram_ScrollView.addSubview(pp_webTextField)
    }
    
    func blogger_introViewLoad()
    {
        let frameWidth = Int(fullSize.width) - frameGap
        idx_offset = idx_offset + Yoffset // + webFrameHeight
        //let offset:float_t = float_t(idx_offset)// * float_t(fullSize.height)
        // 使用 UITextField(frame:) 建立一個 UITextField
        blogger_introTextField = UITextField(frame: CGRect(x: frameGap / 2, y: idx_offset, width: frameWidth, height: bloggerFrameHeight))
        idx_offset = idx_offset + bloggerFrameHeight
        
        // 尚未輸入時的預設顯示提示文字
        blogger_introTextField.placeholder = "輸入介紹景點/店家的部落格網址"
        
        // 輸入框的樣式 這邊選擇圓角樣式
        blogger_introTextField.borderStyle = .roundedRect
        
        // layout 置中顯示
        //blogger_introTextField.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        blogger_introTextField.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        blogger_introTextField.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        blogger_introTextField.keyboardType = .URL
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        blogger_introTextField.returnKeyType =  UIReturnKeyType.next
        
        // 輸入文字的顏色
        blogger_introTextField.textColor = UIColor.gray
        
        blogger_introTextField.tag = BloggerIntroTextFieldTag

        // Delegate
        blogger_introTextField.delegate = self
        
        // UITextField 的背景顏色
        blogger_introTextField.backgroundColor = UIColor.clear
        //self.view.addSubview(blogger_introTextField)
        addfram_ScrollView.addSubview(blogger_introTextField)
    }

    func pp_opentimeViewLoad()
    {
        let frameWidth = Int(fullSize.width) - frameGap
        idx_offset = idx_offset + Yoffset// + bloggerFrameHeight
        //let offset:float_t = float_t(idx_offset)// * float_t(fullSize.height)

        // 使用 UITextField(frame:) 建立一個 UITextField
        pp_opentimeTextField = UITextField(frame: CGRect(x: frameGap/2, y: idx_offset, width: frameWidth, height: opentimeFrameHeight))
        idx_offset = idx_offset + opentimeFrameHeight
        
        // 尚未輸入時的預設顯示提示文字
        pp_opentimeTextField.placeholder = "營業時間"
        
        // 輸入框的樣式 這邊選擇圓角樣式
        pp_opentimeTextField.borderStyle = .roundedRect
        
        // layout 置中顯示
        //pp_opentimeTextField.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        pp_opentimeTextField.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        pp_opentimeTextField.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        pp_opentimeTextField.keyboardType = .default
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        pp_opentimeTextField.returnKeyType =  UIReturnKeyType.next
        
        // 輸入文字的顏色
        pp_opentimeTextField.textColor = UIColor.gray
        
        pp_opentimeTextField.tag = OpentimeTextFieldTag
        
        // Delegate
        pp_opentimeTextField.delegate = self
        
        // UITextField 的背景顏色
        pp_opentimeTextField.backgroundColor = UIColor.clear
        //self.view.addSubview(blogger_introTextField)
        addfram_ScrollView.addSubview(pp_opentimeTextField)
    }
    
    func pp_noteViewLoad()
    {
        let frameWidth = Int(fullSize.width) - frameGap
        idx_offset = idx_offset + Yoffset// + opentimeFrameHeight
        //let offset:float_t = float_t(idx_offset)// * float_t(fullSize.height)
        // 使用 UITextField(frame:) 建立一個 UITextField
        pp_noteTextField = UITextField(frame: CGRect(x: frameGap / 2, y: idx_offset, width: frameWidth, height: noteFrameHeight))
        idx_offset = idx_offset + noteFrameHeight
        
        // 尚未輸入時的預設顯示提示文字
        pp_noteTextField.placeholder = "Tag : #食 ＃衣 #住 #行"
        
        // 輸入框的樣式 這邊選擇圓角樣式
        pp_noteTextField.borderStyle = .roundedRect
        
        // layout 置中顯示
        //pp_noteTextField.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        pp_noteTextField.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        pp_noteTextField.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        pp_noteTextField.keyboardType = .default
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        pp_noteTextField.returnKeyType =  UIReturnKeyType.continue
        
        // 輸入文字的顏色
        pp_noteTextField.textColor = UIColor.gray
        
        pp_noteTextField.tag = NoteTextFieldTag
        
        // Delegate
        pp_noteTextField.delegate = self
        
        // UITextField 的背景顏色
        pp_noteTextField.backgroundColor = UIColor.clear

        addfram_ScrollView.addSubview(pp_noteTextField)
    }
    
    func pp_scoreViewLoad()
    {

    }
    
    func pp_descriptViewLoad()
    {
        let frameWidth = Int(fullSize.width) - frameGap
        idx_offset = idx_offset + Yoffset// + noteFrameHeight
        //let offset:float_t = float_t(idx_offset)// * float_t(fullSize.height)
        // 使用 UITextField(frame:) 建立一個 UITextField
        pp_descriptTextView = UITextView(frame: CGRect(x: frameGap / 2, y: idx_offset, width: frameWidth, height: descriptFrameHeight))
        idx_offset = idx_offset + descriptFrameHeight
        pp_descriptTextView.layer.borderColor = UIColor.lightGray.cgColor
        pp_descriptTextView.layer.borderWidth = 0.5
        pp_descriptTextView.layer.cornerRadius = 5.0
        //idx_offset += 200
        
        // 尚未輸入時的預設顯示提示文字
        //pp_descriptTextView.placeholder = "詳細描述"
        
        // 輸入框的樣式 這邊選擇圓角樣式
        //pp_descriptTextView.borderStyle = .roundedRect
        
        // layout 置中顯示
        //pp_descriptTextView.center = CGPoint(x: fullSize.width * 0.5, y: CGFloat(offset))
        
        //文字置中
        //pp_descriptTextView.textAlignment = .center
        
        // 輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        //pp_descriptTextView.clearButtonMode = .whileEditing
        
        // 輸入框適用的鍵盤 這邊選擇 適用輸入 Email 的鍵盤(會有 @ 跟 . 可供輸入)
        pp_descriptTextView.keyboardType = .default
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        pp_descriptTextView.returnKeyType =  UIReturnKeyType.default
        
        // 輸入文字的顏色
        pp_descriptTextView.textColor = UIColor.gray
        
        pp_descriptTextView.tag = DescriptTextFieldTag
        
        // Delegate
        //pp_descriptTextView.delegate = self
        
        // UITextField 的背景顏色
        pp_descriptTextView.backgroundColor = UIColor.white
        
        addfram_ScrollView.addSubview(pp_descriptTextView)
    }
    
    func saveBtn()
    {
        //let frameWidth = Int(fullSize.width) - frameGap
        let btnFrameGap = Int(fullSize.width) - 160
        idx_offset = idx_offset + Yoffset// + descriptFrameHeight
        //let offset:float_t = float_t(idx_offset) //* float_t(fullSize.height)
        // 使用 UIButton(frame:) 建立一個 UIButton
        let myButton = UIButton(
            frame: CGRect(x: btnFrameGap / 2, y: idx_offset, width: 160, height: saveBtnFrameHeight))
        idx_offset = idx_offset + saveBtnFrameHeight
        
        // 按鈕文字
        myButton.setTitle("收藏", for: .normal)
        
        // 按鈕文字顏色
        myButton.setTitleColor(UIColor.white, for: .normal)
        
        // 按鈕是否可以使用
        myButton.isEnabled = true
        
        // 按鈕背景顏色
        myButton.backgroundColor = UIColor(red: 0, green: 160/255, blue: 1, alpha: 0.8)
        //UIColor.darkGray
        
        // 按鈕按下後的動作
        myButton.addTarget(
            self,
            action: #selector(AddViewController.saveButton),
            for: .touchUpInside)
        
        // 設置位置並加入畫面
        //myButton.center = CGPoint(
        //    x: fullSize.width * 0.5,
        //    y: CGFloat(offset))

        //self.view.addSubview(myButton)
        addfram_ScrollView.addSubview(myButton)
        using_height = using_height + Int(idx_offset)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // 結束編輯 把鍵盤隱藏起來
        self.view.endEditing(true)
        
        return true
    }
    
    func ppInfoCleanup()
    {
        ppNameTextField.text = ""
        ppPhoneTextField.text = ""
        pp_pickTextField.text = ""
        pp_addressTextField.text = ""
        pp_fbTextField.text = ""
        pp_webTextField.text = ""
        blogger_introTextField.text = ""
        pp_opentimeTextField.text = ""
        pp_noteTextField.text = ""
        //pp_scoreTextField.text = ""
    }
    
    // scrollview
    func scrollViewLoad()
    {
        let scrollHeight = fullSize.height - bannerView.frame.height
        // 建立 UIScrollView
        addfram_ScrollView = UIScrollView()
        
        // 設置尺寸 也就是可見視圖範圍
        addfram_ScrollView.frame = CGRect(x: 0, y: 0, width: fullSize.width, height: scrollHeight)
        
        // 實際視圖範圍 為 3*2 個螢幕大小
        addfram_ScrollView.contentSize = CGSize(width: fullSize.width, height: fullSize.height*2)
        
        // 是否顯示水平的滑動條
        addfram_ScrollView.showsHorizontalScrollIndicator = false
        
        // 是否顯示垂直的滑動條
        addfram_ScrollView.showsVerticalScrollIndicator = false
        
        // 滑動條的樣式
        addfram_ScrollView.indicatorStyle = .black
        
        // 是否可以滑動
        addfram_ScrollView.isScrollEnabled = true
        
        // 是否可以按狀態列回到最上方
        addfram_ScrollView.scrollsToTop = false
        
        // 限制滑動時只能單個方向 垂直或水平滑動
        addfram_ScrollView.isDirectionalLockEnabled = false
        
        // 滑動超過範圍時是否使用彈回效果
        addfram_ScrollView.bounces = true
        
        // 縮放元件的預設縮放大小
        //myScrollView.zoomScale = 1.0
        
        // 縮放元件可縮小到的最小倍數
        //myScrollView.minimumZoomScale = 0.5
        
        // 縮放元件可放大到的最大倍數
        //myScrollView.maximumZoomScale = 2.0
        
        // 縮放元件縮放時是否在超過縮放倍數後使用彈回效果
        addfram_ScrollView.bouncesZoom = true
        
        // 設置委任對象
        addfram_ScrollView.delegate = self
        
        // 起始的可見視圖偏移量 預設為 (0, 0)
        // 設定這個值後 就會將原點滑動至這個點起始
        //myScrollView.contentOffset = CGPoint(x: fullSize.width * 0.5, y: fullSize.height)
        
        // 以一頁為單位滑動
        addfram_ScrollView.isPagingEnabled = false
        
        // 加入到畫面中
        self.view.addSubview(addfram_ScrollView)
    }

    func addViewHint(Status:Int) {
        var Title:String?
        var msgStr:String?
        var BtnTitle:String?

        if (Status == 0)
        {
            Title = "資料不完整"
            msgStr = "請完成資料後再存入"
            BtnTitle = "確認"
        }
        else if (Status == 1)
        {
            Title = "放入手冊中"
            msgStr = "儲存本地端完成"
            BtnTitle = "確認"
        }
        else if (Status == 2)
        {
            Title = "資料重複"
            msgStr = "您已經擁有她囉！"
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
                if Status == 1 || Status == 2
                {
                    self.ppInfoCleanup()
                }
        })
        alertController.addAction(okAction)
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
    
    @objc func clickDiscoverBtn()
    {
        if self.debug == 1 {
            print("click discover button")
        }
    }
    
    @objc func clickSearchBtn()
    {
        if self.debug == 1 {
            print("click search button")
            print("Open mapsearch Function...")
        }

        //self.navigationController?.setNavigationBarHidden(false, animated: true)
        if SearchTabVC != nil
        {
            self.navigationController!.pushViewController(SearchTabVC!, animated: false)
        }
    }
    
    @objc func locate() {
        //addAlertMessage(Title:"定位中", msgStr: "正在鎖定您所在城市")
        if let notifVC = self.tabBarController?.viewControllers?[3] as? NotifViewController{
            if (locateMode == 0) {
                if let currCity = notifVC.getCurrCity(),
                    let currCountry = notifVC.getCurrCountry(),
                    let currTown = notifVC.getCurrTown(),
                    let currStreet = notifVC.getStreet() {
                    ppCountry = currCountry
                    ppCity = currCity
                    ppCountryNCityL = currCountry + " | " + currCity
                    pp_pickTextField.text = ppCountryNCityL
                    pp_addressTextField.text = "\(currCountry) \(currCity) \(currTown) \(currStreet)"
                }
                locateMode = 1
            } else {
                if let currLocate = notifVC.getLatLong(),
                    let currCity = notifVC.getCurrCity(),
                    let currCountry = notifVC.getCurrCountry() {
                    ppCountry = currCountry
                    ppCity = currCity
                    ppCountryNCityL = currCountry + " | " + currCity
                    pp_pickTextField.text = ppCountryNCityL
                    pp_addressTextField.text = currLocate
                }
                locateMode = 0
            }
        }
    }
    
    @objc func saveButton() {
        if self.debug == 1 {
            print("Save button")
        }
        var insert:Int! = 0
        if let descrip = pp_descriptTextView.text {
            ppDescripL = descrip
        }
        if ((ppNameL == nil || ppPhoneL == nil
            || ppCountryNCityL == nil || ppAddressL == nil
            || ppWEBL == nil || ppBloggerIntroL == nil) ||
            (ppNameL == "待補充" || ppCountryNCityL == "待補充"))
        {
            if self.debug == 1 {
                print("無資料")
            }
        }
        else
        {
            let db:DB_Access? = DB_Access()
            //let searchAddr_caches = db!.pp_searchByAddress(address: ppAddressL, country: ppCountryL)
            let searchName_caches = db!.pp_searchByName(name: ppNameL, country: ppCountry)
            if (searchName_caches == nil)
            {
                if self.debug == 1 {
                    print("Didn't have same data in DB")
                
                    print("INSERT OPTION : address no problem")
                }
                insert = 1
                let loc:[String] = ppAddressL.components(separatedBy: ",")
                if loc.count == 2
                {
                    ppAddressL = loc[0] + " " + loc[1]
                }
                
                //Debug message
                if insert == 1 && db!.pp_insert(pp_name: ppNameL, pp_phone: ppPhoneL, pp_country: ppCountryNCityL, pp_address: ppAddressL, pp_fb: ppFBL, pp_web: ppWEBL ,pp_blogger_intro: ppBloggerIntroL, pp_opentime: ppOpentimeL,   pp_note: ppNoteL, pp_descrip: ppDescripL, pp_score: ppScoreL) > 0
                {
                    if self.debug == 1 {
                        print("新增成功")
                    }
                }
                else {
                    if self.debug == 1 {
                        print("新增失敗")
                    }
                    insert = 0
                }
            }
            else
            {
                if self.debug == 1 {
                    print("Already had same data")
                    print("Into Edite Mode")
                }
                insert = 2
            }

        }
        self.addViewHint(Status: insert)
    }
    
    @objc func doneSelect()
    {
        let spliteStr = " | "

        if !ppCountry.isEmpty
        {
            ppCountryNCityL = ppCountry + spliteStr
        }
        if !ppCity.isEmpty
        {
            ppCountryNCityL = ppCountryNCityL + ppCity
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
            ppCountryNCityL = ppCountryNCityL + ppCity
        }
        pp_pickTextField.text = ppCountryNCityL
        pp_pickTextField.resignFirstResponder()
        if self.debug == 1 {
            print("Picker DONE")
        }
    }

    // 按空白處會隱藏編輯狀態
    @objc func hideKeyboard(tapG:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    //var touchCnt = 0
    @objc func keyboardNotification(notification: NSNotification) {
        //print("keyboardNotification , count : ", touchCnt)
        //print("self.view.frame.origin.y = ", self.view.frame.origin.y)
        //touchCnt = touchCnt + 1
        if let userInfo = notification.userInfo {
            let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let scrolling_offset = 80
            let offsetY = Int(keyboardFrame.minY) + scrolling_offset
            addfram_ScrollView.contentOffset = CGPoint(x: 0, y: offsetY)
        }
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


