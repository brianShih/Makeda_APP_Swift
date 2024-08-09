//
//  PP_Viewer.swift
//  Makeda
//
//  Created by Brian on 2019/4/13.
//  Copyright © 2019 breadcrumbs.tw. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import SafariServices

class PP_Viewer: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate, UIPickerViewDataSource {
    let debug = 0
    var userPower = 0
    let nav_sel = 0
    let displayCnt = 10
    var setupCnt = 0
    let nameHeader_height = 50
    let fullSize = UIScreen.main.bounds.size
    var ppV_ScrollView: UIScrollView!
    var ppV_TableView:UITableView!
    var swipeLab: UIButton?
    var swipeTextOpen = 0
    //var activityIndicator:UIActivityIndicatorView!
    var PPdetail:NSManagedObject! = nil
    var HeaderY = 50
    let goBackButtonID = 1201
    var mapActivityIndicator:UIActivityIndicatorView!
    var tv_height = 0
    var editeValueCtrl:UIAlertController?
    private var sel_country = 0
    var ppCountry:String? = String("台灣")
    var ppCity:String?
    var ppCountryNCityL:String! = nil
    let defualtContentSize = ppV_Cell.layerHight
    var contentHeights : [CGFloat] = [0.0, 0.0, 0.0, 0.0, 0.0,
                                    0.0, 0.0, 0.0, 0.0, 0.0]
    struct tabStr {
        let list = [
            "電話",
            "區域",
            "地址",
            "粉絲團/社團",
            "官方網站",
            "部落客推薦",
            "營業時間",
            "標籤",
            "詳細"
        ]
        let dbName = [
            "pp_phone",
            "pp_country",
            "pp_address",
            "pp_fb",
            "pp_web",
            "blogger_intro",
            "pp_opentime",
            "pp_note",
            "pp_descrip"
        ]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code. Add details based on your needs.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ppV_TableView!.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPower = GetUserPower()
        //scrollViewLoad()
        NameLabelInit()
        goBackBtn()
        tabViewLoad()
        swipeLoad()
        SwipeLabelLoad()
        // 增加一個觸控事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(tapG:)))
        tap.cancelsTouchesInView = false
        // 加在最基底的 self.view 上
        //self.view.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(tap)
    }
    
    func swipeLoad() {
        // 向左滑動
        let swipeLeft = UISwipeGestureRecognizer(
            target:self,
            action:#selector(PP_Viewer.swipe))
        swipeLeft.direction = .left
        
        swipeLeft.numberOfTouchesRequired = 1
        
        // 為視圖加入監聽手勢
        self.view.addGestureRecognizer(swipeLeft)
        
        // 向左滑動
        let swipeRight = UISwipeGestureRecognizer(
            target:self,
            action:#selector(PP_Viewer.swipe))
        swipeRight.direction = .right
        
        swipeRight.numberOfTouchesRequired = 1
        
        // 為視圖加入監聽手勢
        self.view.addGestureRecognizer(swipeRight)
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
            action: #selector(PP_Viewer.goBack),
            for: .touchUpInside)
        self.view.addSubview(backButton)
        //ppV_ScrollView.addSubview(backButton)
    }
    
    func NameLabelInit()
    {
        let buttonWidth = 35
        if let name = PPdetail.value(forKey: "pp_name") as? String
        {
            if self.debug == 1 {
                print("NameLabelInit start....")
            }
            let nameLab = UILabel(frame: CGRect(x: buttonWidth, y: HeaderY, width: Int(fullSize.width) - buttonWidth*2, height: nameHeader_height))
            nameLab.text = name
            nameLab.textColor = UIColor.black
            nameLab.font = UIFont(name: "Helvetica-Light", size: 20)
            nameLab.textAlignment = NSTextAlignment.center
            nameLab.numberOfLines = 0
            nameLab.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.view.addSubview(nameLab)
        }
    }
    
    func SwipeLabelLoad() {
        //let buttonWidth = 35
        let swipeTextWidth = 5
        let X = Int(fullSize.width) - swipeTextWidth
        swipeLab = UIButton(frame: CGRect(x: X, y: HeaderY, width: swipeTextWidth, height: Int(fullSize.height)))
        //swipeLab.text =
        swipeLab!.setTitle("開\n啟\nG\no\no\ng\nl\ne\n搜\n尋\n", for: .normal)
        swipeLab!.setTitleColor(UIColor.black, for: .normal)
        swipeLab!.backgroundColor = UIColor(red: 0, green: 160/255, blue: 1, alpha: 0.8)
        swipeLab!.titleLabel?.font = UIFont(name: "Helvetica-Light", size: 14)
        swipeLab!.titleLabel?.textAlignment = NSTextAlignment.center
        swipeLab!.titleLabel?.numberOfLines = 0
        swipeLab!.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        swipeTextOpen = 0
        swipeLab!.isEnabled = true
        swipeLab!.addTarget(
            self,
            action: #selector(PP_Viewer.googleGo),
            for: .touchUpInside)
        
        self.view.addSubview(swipeLab!)

    }
    
    func tabViewLoad()
    {
        for i in 0...(contentHeights.count - 1) {
            contentHeights[i] = CGFloat(ppV_Cell.layerHight) * 2
        }
        ppV_TableView = UITableView(frame: CGRect(
            x: 0, y: Int(HeaderY + nameHeader_height),
            width: Int(fullSize.width),
            height: Int(fullSize.height) - nameHeader_height - HeaderY
        ), style: .grouped)
        ppV_TableView.register(
            ppV_Cell.self, forCellReuseIdentifier: ppV_Cell.reuseID)
        ppV_TableView.delegate = self
        ppV_TableView.dataSource = self
        ppV_TableView.separatorStyle = .singleLine
        ppV_TableView.allowsSelection = true
        ppV_TableView.allowsMultipleSelection = false
        self.view.addSubview(ppV_TableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if PPdetail != nil
        {
            return displayCnt
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ppV_Cell.reuseID, for: indexPath) as! ppV_Cell
        cell.content?.isEditable = false
        cell.content?.isScrollEnabled = false
        cell.imageButton!.setImage(UIImage(named: ""), for: .normal)
        var non_data = false
        if (indexPath.row == 0) {
            cell.title?.text = "電話   : "
            cell.imageButton!.setImage(UIImage(named: "call@x2"), for: .normal)
            if let phone = PPdetail.value(forKey: "pp_phone") as? String {
                cell.content?.text = phone
            } else { non_data = true }
        } else if (indexPath.row == 1) {
            cell.title?.text = "所在區域    : "
            if let country = PPdetail.value(forKey: "pp_country") as? String {
                cell.content?.text = country
                cell.content?.textAlignment = .center
            } else { non_data = true }
        } else if (indexPath.row == 2) {
            cell.title?.text = "地址/座標   : "
            cell.imageButton!.setImage(UIImage(named: "iconfinder_navigation"), for: .normal)
            if let addr = PPdetail.value(forKey: "pp_address") as? String {
                cell.content?.text = addr
                //cell.content?.sizeToFit()
            } else { non_data = true }
        } else if (indexPath.row == 3) {
            cell.title?.text = "粉絲團/社團   : "
            cell.imageButton!.setImage(UIImage(named: "fb"), for: .normal)
            if let fb = PPdetail.value(forKey: "pp_fb") as? String {
                cell.content?.text = fb
                //cell.content?.sizeToFit()
            } else { non_data = true }
        } else if (indexPath.row == 4) {
            cell.title?.text = "官方網站   : "
            cell.imageButton!.setImage(UIImage(named: "iconfinder_Internet_Line"), for: .normal)
            if let web = PPdetail.value(forKey: "pp_web") as? String {
                cell.content?.text = web
                //cell.content?.sizeToFit()
            } else { non_data = true }
        } else if (indexPath.row == 5) {
            cell.title?.text = "部落客推薦   : "
            cell.imageButton!.setImage(UIImage(named: "blogger"), for: .normal)
            if let blogger = PPdetail.value(forKey: "blogger_intro") as? String {
                cell.content?.text = blogger
                //cell.content?.sizeToFit()
            } else { non_data = true }
        } else if (indexPath.row == 6) {
            cell.title?.text = "營業時間   : "
            if let opentime = PPdetail.value(forKey: "pp_opentime") as? String {
                cell.content?.frame = CGRect(x: 0, y: ppV_Cell.layerHight - 8, width:  Int(fullSize.width), height: ppV_Cell.layerHight)
                cell.content?.text = opentime
                cell.content?.sizeToFit()
                contentHeights[indexPath.row] = (cell.content?.contentSize.height)! + CGFloat(ppV_Cell.layerHight)
            } else { non_data = true }
        } else if (indexPath.row == 7) {
            cell.title?.text = "標籤   : "
            if let note = PPdetail.value(forKey: "pp_note") as? String {
                cell.content?.frame = CGRect(x: 0, y: ppV_Cell.layerHight - 8, width:  Int(fullSize.width), height: ppV_Cell.layerHight)
                cell.content?.text = note
                cell.content?.sizeToFit()
                contentHeights[indexPath.row] = (cell.content?.contentSize.height)! + CGFloat(ppV_Cell.layerHight)
            } else { non_data = true }
        } else if (indexPath.row == 8) {
            cell.title?.text = "詳細   : "
            if let descrp = PPdetail.value(forKey: "pp_descrip") as? String {
                cell.content?.frame = CGRect(x: 0, y: ppV_Cell.layerHight - 8, width:  Int(fullSize.width), height: ppV_Cell.layerHight)
                cell.content?.text = descrp
                cell.content?.sizeToFit()
                cell.content?.dataDetectorTypes = UIDataDetectorTypes.all
                contentHeights[indexPath.row] = (cell.content?.contentSize.height)! + CGFloat(ppV_Cell.layerHight)
            } else { non_data = true }
        } else if (indexPath.row == 9) {
            cell.title?.text = "評論"
            cell.content?.text = "點擊讀取更多"
        }
        
        if non_data == true {
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.row == 0) {
            if UIApplication.shared.canOpenURL(URL(string:"tel://")!) {
                if let numb = PPdetail.value(forKey: "pp_phone") as? String {
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
                } else {
                    handlrViewHint(Title: "提醒", msgStr: "請更新\"電話號碼\"", BtnTitle: "確認")
                }
            } else {
                handlrViewHint(Title: "提醒", msgStr: "撥話功能異常", BtnTitle: "確認")
            }
            
        } else if (indexPath.row == 1) {

        } else if (indexPath.row == 2) {
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!))
            {
                let callWebview =   UIWebView()
                if let addr_row = PPdetail.value(forKey: "pp_address") as? String {
                    let addr:NSString = addr_row.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! as NSString
                    let directionsRequest = "comgooglemaps://" +
                                            "?daddr=\(addr))" +
                        "&x-success=sourceapp://?resume=true&x-source=AirApp&views=traffic"
                    if self.debug == 1 {
                        print("Direction Address: ",directionsRequest)
                    }
                    callWebview.loadRequest(NSURLRequest(url: URL(string: directionsRequest)!) as URLRequest)
                    self.view.addSubview(callWebview)
                }
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
                    if let addr_row = PPdetail.value(forKey: "pp_address") as? String {
                        let addr:NSString = addr_row.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! as NSString
                        let directionsRequest = "http://maps.apple.com/" +
                            "?daddr=\(addr))"
                        if self.debug == 1 {
                            print("Direction Address: ",directionsRequest)
                        }
                        callWebview.loadRequest(NSURLRequest(url: URL(string: directionsRequest)!) as URLRequest)
                        self.view.addSubview(callWebview)
                    }
                }
                else
                {
                    if self.debug == 1 {
                        print("Apple map url open fail")
                    }
                }
            }

        } else if (indexPath.row == 3) {
            if let url = PPdetail.value(forKey: "pp_fb") as? String
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
        } else if (indexPath.row == 4) {
            if let url = PPdetail.value(forKey: "pp_web") as? String
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
        } else if (indexPath.row == 5) {
            if self.debug == 1 {
                print("Touch: BloggerIntroTextField")
            }
            if let url = PPdetail.value(forKey: "blogger_intro") as? String
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
        } else if (indexPath.row == 6) {

        } else if (indexPath.row == 7) {
            
        } else if (indexPath.row == 9) {
            // get comments from cloud
            let cvc = CommentsViewController()
            cvc.PPdetail = PPdetail
            self.present(cvc, animated: true, completion: nil)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if defualtContentSize < Int(contentHeights[indexPath.row]) {
            return contentHeights[indexPath.row]
        }
        return CGFloat(defualtContentSize)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath)
        -> [UITableViewRowAction]?
    {
        var actionArr:Array<UITableViewRowAction> = [UITableViewRowAction]()
        var edite_en = 0

        if let id = PPdetail.value(forKey: "id") as? Int {
            if id > 0 {
                edite_en = 1
            } else if id == 0 && userPower == 1 {
                edite_en = 2
            }
        }
        if edite_en > 0 && indexPath.row < tabStr().list.count {
            
            let actionEdite = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "編輯") {
                (action, indexPath) in
                // 建立一個提示框
                self.editeValueCtrl = UIAlertController(
                    title: tabStr().list[indexPath.row],
                    message: "更新資料",
                    preferredStyle: .alert)
                // 建立[確認]按鈕
                let sendAction = UIAlertAction(
                    title: "確認",
                    style: .default,
                    handler: { (action: UIAlertAction!) -> Void in
                        let editFrame = PP_EditViewController()
                        editFrame.PPdetail = self.PPdetail
                        editFrame.indexRow = indexPath.row
                        self.present(editFrame, animated: true, completion: nil)
                        
                })
                
                let cancel = UIAlertAction(title: "取消", style: .destructive, handler: { (action) -> Void in })

                //self.editeValueCtrl!.view.addSubview(cusTextView)
                self.editeValueCtrl!.addAction(cancel)
                self.editeValueCtrl!.addAction(sendAction)
                // 顯示提示框
                self.present(self.editeValueCtrl!, animated: true, completion: nil)
            }
            actionEdite.backgroundColor = UIColor(red: 0, green: 190/255, blue: 1, alpha: 0.8)
            actionArr.append(actionEdite)
        }
        return actionArr;
    }
    
    // 每個 section 的標題
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "詳細資訊"
    }
    
    // 有幾組 section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
        
        //pp_countryTextField!.text = ppCountryNCityL
        self.editeValueCtrl!.textFields![0].text = ppCountryNCityL
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 按空白處會隱藏編輯狀態
    @objc func hideKeyboard(tapG:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion:nil)
    }
    
    func GetUserPower()-> Int {
        let myUserDefaults = UserDefaults.standard
        if let po:Int = myUserDefaults.value(forKey: "user_power") as? Int {
            return po
        }
        return 0
    }
    
    
    func handlrViewHint(Title:String, msgStr:String, BtnTitle:String) {
        if Title == "" || msgStr == "" || BtnTitle == ""
        {
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

    @objc func googleGo() {
        if self.debug == 1 {
            print("googleGo")
        }
        let g = googleSearchViewController()
        g.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        if let name = PPdetail.value(forKey: "pp_name") as? String,
            let area = PPdetail.value(forKey: "pp_country") as? String{
            let area_comp = area.components(separatedBy: " | ")
            g.resetKeywords()
            g.keywords.append(name)
            g.keywords.append(area_comp[0])
            g.keywords.append(area_comp[1])
        }
        //g.keyword
        
        self.present(
            g,
            animated: true,
            completion: nil)
    }
    
    @objc func swipe(recognizer:UISwipeGestureRecognizer) {
        if self.debug == 1 {
            print("swipe : google search ------")
        }
        if recognizer.direction == .left {
            if (swipeTextOpen == 0) {
                if self.debug == 1 {
                    print("swipeTextOpen == 0 ...")
                }
                let swipeTextWidth = 60
                let X = Int(fullSize.width) - swipeTextWidth
                swipeLab!.frame = CGRect(x: X, y: 0, width: swipeTextWidth, height: Int(fullSize.height))
                swipeTextOpen = 1
            } else if (swipeTextOpen == 1) {
                if self.debug == 1 {
                    print("swipeTextOpen == 1 ...")
                }
                googleGo()
            }
        } else if recognizer.direction == .right {
            if self.debug == 1 {
                print("recognizer.direction == .right")
            }
            let swipeTextWidth = 5
            let X = Int(fullSize.width) - swipeTextWidth
            swipeLab!.frame = CGRect(x: X, y: 0, width: swipeTextWidth, height: Int(fullSize.height))
            swipeTextOpen = 0
        }
    }
}

extension UITableViewCell {
    /// Search up the view hierarchy of the table view cell to find the containing table view
    var tableView: UITableView? {
        get {
            var table: UIView? = superview
            while !(table is UITableView) && table != nil {
                table = table?.superview
            }
            
            return table as? UITableView
        }
    }
}

class ppV_Cell:UITableViewCell{
    var fullSize = UIScreen.main.bounds.size
    var title : UILabel?
    var content : UITextView?
    var imageButton : UIButton?
    static let layerHight:Int = 30
    static let reuseID = "ppV_Cell"
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        title = UILabel(frame:CGRect(x: 5, y: 0, width:  Int(fullSize.width), height: ppV_Cell.layerHight - 10))
        title!.font = UIFont(name: "Helvetica-Light", size: 14)
        //titleLabel.textAlignment = .center
        title!.textColor = UIColor.black
        self.addSubview(title!)

        
        content = UITextView(frame:CGRect(x: 0, y: ppV_Cell.layerHight - 8, width:  Int(fullSize.width) - 50, height: ppV_Cell.layerHight))
        content!.font = UIFont(name: "Helvetica-Light", size: 18)
        content!.textColor = UIColor.black
        self.addSubview(content!)
        
        imageButton = UIButton(frame: CGRect(x: Int(fullSize.width) - 50, y: Int(0),
                                    width: 50, height: 50))
        imageButton!.setTitleColor(UIColor.black, for: .normal)
        imageButton!.backgroundColor = UIColor.clear

        imageButton!.isEnabled = true
        self.addSubview(imageButton!)
        
        content?.isScrollEnabled = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

