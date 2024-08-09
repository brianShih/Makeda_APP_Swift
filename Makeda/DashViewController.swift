//
//  DashViewController.swift
//  Makeda
//
//  Created by Brian on 2018/8/31.
//  Copyright © 2018年 breadcrumbs.tw. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import GoogleMobileAds
import CoreLocation
//import Cocoa

class DashViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,
                            UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
                            //UIDocumentInteractionControllerDelegate {
    let debug = 0
    var tagsSelectedVC = tagsSelectedViewController()
    let tripplanlistsVC = TripPlanListsViewController()
    var bannerView: GADBannerView!
    var tagsLabel:UILabel?
    var tagsButton:UIButton?
    
    var locateBtn : UIButton?
    var tripPlanBtn : UIButton?
    var cloudBtn : UIButton?
    var filterBtn : UIButton?
    var searchBtn : UIButton?
    
    var refreshControl: UIRefreshControl!
    var dash_ScrollView: UIScrollView!
    var myTableView:UITableView!
    var dashTextField:UITextField!
    let fullScreenSize = UIScreen.main.bounds.size
    let pickTextHigh = 50
    var tagsButtonHigh = 40
    let buttonTabHigh = 30
    let startHeaderY = 50
    let buttonTabStartX = 30
    var tabView_h = 0
    private var sel_country = 0
    var ppList_updated = 1
    var tags_list = [String]()
    var tags_sel:[Int] = []
    var cloud_connect = 1
    var pp_selectedIndex = 0
    static var country = "台灣"
    static var city = "彰化縣"
    var CountryNCity: String?

    var selPlanOptions = [String]()
    var infoList: [NSManagedObject] = []
    var infoListCount = 0
    var dbList: [NSManagedObject] = []
    var dbListCount = 0
    var cloudList: [NSManagedObject] = []
    var cloudListCount = 0
    var formatter: DateFormatter! = nil
    var timer: Timer!
    var autorefresh_timer : Timer!
    let dashTextFieldTag = 100
    let dashPickerViewTag = 90
    var timerCount = 0
    var userLogin = 0
    var db:DB_Access!
    var alertShortMessage : UIAlertController?

    override func viewWillAppear(_ animated: Bool) {
        //print("viewWillAppear")
        var cloud_status = 0
        let myUserDefaults = UserDefaults.standard
        if let cloudst = myUserDefaults.value(forKey: "cloud_connected") as? Int
        {
            if cloud_connect != cloudst
            {
                cloud_status = 1
            }
            cloud_connect = cloudst
            
        } else {
            myUserDefaults.setValue(cloud_connect, forKey: "cloud_connected")
            myUserDefaults.synchronize()
        }
        if cloud_status == 1
        {
            if debug == 1 {
                print("Change the Cloud connected Status to :",cloud_status)
            }
            
            let selectedList:[Int] = tagsSelectedVC.getTagsSelectedList()
            let tagsList:[String] = tagsSelectedVC.getTagsList()
            if selectedList.count == 0 || tagsList.count == 0
            {
                
            }
            tagsSelectedVC.setPPList(ppList: infoList)
            ppList_updated = 1
        }
        Reload_ppList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = DB_Access()
        db.db_init()
        loadGoogleBannerAD()
        scrollViewLoad()
        buttonsTabLoad()
        pickerViewLoad()
        //TagsTabLoad()
        tabViewLoad()
        
        checkLocalDB()
        
        autorefresh_timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(DashViewController.refreshEvery5Secs), userInfo: nil, repeats: true)
        
        // 增加一個觸控事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(tapG:)))
        tap.cancelsTouchesInView = false
        
        // 加在最基底的 self.view 上
        self.view.addGestureRecognizer(tap)
        
        refreshControl = UIRefreshControl()
        myTableView.addSubview(refreshControl)
        
        if let notifVC = self.tabBarController?.viewControllers?[3] as? NotifViewController{
            notifVC.LocationInit()
        }
        
        if let homeNV = self.tabBarController?.viewControllers?[1] as? UINavigationController {
            if let addvc = homeNV.topViewController as? AddViewController
            {
                addvc.SearchTabVC = SearchResultTabViewController(nibName: "SearchTabVC", bundle: nil)
                addvc.SearchTabVC?.searchFuncInit()
            }
        }
        else
        {
            if debug == 1 {
                print ("addVC init fail")
            }
        }
    }
    
    func set_AreaNCountry(country_in:String, city_in:String)
    {
        if !country_in.isEmpty && !city_in.isEmpty {
            DashViewController.country = country_in
            DashViewController.city = city_in
        }
    }
    
    
    // UIPickerViewDataSource 必須實作的方法：UIPickerView 有幾列可以選擇
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
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
            return Cities().citiesOfTaiwan.count
        }
        else if sel_country == GloupID().all_groupID
        {
            return 1 //Cities().citiesOfAll.count
        }
        else if sel_country == GloupID().Japan_groupID
        {
            return Cities().citiesOfJapan.count
        }
        else if sel_country == GloupID().China_groupID
        {
            return Cities().citiesOfChina.count
        }

        return Cities().citiesOfTaiwan.count
        
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
        else if component == 1 {
            // 否則就是設置第二列
            // 設置為陣列 meals 的第 row 項資料

            if sel_country == GloupID().Taiwan_groupID
            {
                return Cities().citiesOfTaiwan[row]
            }
            else if sel_country == GloupID().all_groupID
            {
                return Cities().citiesOfAll
            }
            else if sel_country == GloupID().Japan_groupID
            {
                return Cities().citiesOfJapan[row]
            }
            else if sel_country == GloupID().China_groupID
            {
                return Cities().citiesOfChina[row]
            }
        }
        
        return "請選擇"
    }
    //pickerview
    // UIPickerView 改變選擇後執行的動作
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let spliteStr = " | "
        // 改變第一列時
        if component == 0 {
            // whatDay 設置為陣列 week 的第 row 項資料
            DashViewController.country = Countries().list[row]

            CountryNCity = DashViewController.country + spliteStr
            
            DashViewController.city = ""
            sel_country = row + 1
            if debug == 1
            {
                print("country row: \(row)" )
            }
        }
        if component == 1 {
            // 否則就是改變第二列
            // whatMeal 設置為陣列 meals 的第 row 項資料
            //DashViewController.city = searchCityList(CountryID: sel_country, ROW: row)
            DashViewController.city = "請選擇"
            if sel_country == GloupID().Taiwan_groupID
            {
                DashViewController.city = Cities().citiesOfTaiwan[row]
            }
            else if sel_country == GloupID().all_groupID
            {
                DashViewController.city = Cities().citiesOfAll
            }
            else if sel_country == GloupID().Japan_groupID
            {
                DashViewController.city = Cities().citiesOfJapan[row]
            }
            else if sel_country == GloupID().China_groupID
            {
                DashViewController.city = Cities().citiesOfChina[row]
            }

            if debug == 1
            {
                print("city row: \(row)" )
            }
            CountryNCity = DashViewController.country + spliteStr + DashViewController.city
        }
        pickerView.reloadComponent(1) // reload cities
        if dashTextField!.text != CountryNCity
        {
            cloudList.removeAll()
        }
        dashTextField?.text = CountryNCity//"\(DashViewController.country)   |   \(DashViewController.city)"
        // 將改變的結果印出來
        if debug == 1
        {
            print("選擇的是 \(DashViewController.country) ， \(DashViewController.city)")
        }
        ppList_updated = 1
        Reload_ppList()
        
        if debug == 1
        {
            print("search result count : \(String(describing: infoList.count))")
            for result in (infoList) {
                print(" pp : \(result.value(forKey: "pp_name") as! String), \(result.value(forKey: "pp_address") as! String)")
            }
        }
    }
    
    func Reload_ppList()
    {
        var dblistChanged = 0
        var cloudlistChanged = 0
        var tempList: [NSManagedObject] = []
        //dbList.removeAll()
        // re search from CoreData
        //let db:DB_Access = DB_Access()
        if DashViewController.country == "所有" && DashViewController.city == "所有"
        {
            let caches = db.pp_getAll()
            if (caches != nil)
            {
                if dbList.count != dbListCount
                {
                    dblistChanged = 1
                }
                dbList = (caches)!
            }
        }
        else if DashViewController.city == "所有" && DashViewController.country.isEmpty == false // 某個國家,所有城市的景點
        {
            let caches = db.pp_searchByCountry(country: DashViewController.country)
            if (caches != nil)
            {
                if dbList.count != dbListCount
                {
                    dblistChanged = 1
                }
                dbList = (caches)!
            }
        }
        else
        {
            if DashViewController.city.isEmpty == false {
                let caches = db.pp_searchByCity(city: DashViewController.city)
                if (caches != nil)
                {
                    if dbList.count != dbListCount
                    {
                        dblistChanged = 1
                        if debug == 1 {
                            print ("dbList.count = ", dbList.count, " dbListCount = ",dbListCount)
                        }
                    }
                    dbList = (caches)!
                    infoList.removeAll()
                    if debug == 1 {
                        print("Reload_ppList : Een Of Search , Total count : ",caches!.count)
                    }
                }
            }
        }
        tempList = dbList
        
        if cloud_connect == 1
        {
            if cloudList.count == 0
            {
                DownloadPPfromCloud()
            } else {
                if debug == 1 {
                    print("Cloud List count : ",cloudList.count)
                }
                tempList = mergeList(inList: cloudList, toList: tempList)
                if cloudList.count != cloudListCount
                {
                    cloudlistChanged = 1
                    if debug == 1 {
                        print ("cloudList.count = ", cloudList.count, " cloudListCount = ",cloudListCount)
                    }
                }
            }
        }
        if cloudlistChanged == 1 || dblistChanged == 1
        {
            if debug == 1 {
                print(" Clean up tags ..")
            }
            tagsSelectedVC = tagsSelectedViewController()
            tagsSelectedVC.setPPList(ppList: tempList)
        }

        let selectedList:[Int] = tagsSelectedVC.getTagsSelectedList()
        let tagsList:[String] = tagsSelectedVC.getTagsList()
        var selectedTags:[String] = []
        var unsel_count = 0
        if debug == 1 {
            print("selectedList count : ", selectedList.count, "tagsList count : ", tagsList.count)
        }
        if selectedList.count > 0 && tagsList.count > 0
        {
            if debug == 1 {
                print("Start to filter selected Tag from PP")
            }
            for i in 0...(selectedList.count - 1)
            {
                if (selectedList[i] == 1)
                {
                    if debug == 1 {
                        print ("Show selected Tag : ",tagsList[i])
                    }
                    selectedTags.append(tagsList[i])
                }
                else
                {
                    unsel_count = unsel_count + 1
                }
            }
        }
        if debug == 1 {
            print("SelectedTags.count = \(selectedTags.count), selectedList.count = \(selectedList.count)")
        }

        if (selectedTags.count > 0 && unsel_count <= selectedList.count)
            //&& !(selectedTags.count == 1)// && selectedTags[0] == String("線上資料"))
        {
            //tempList
            infoList = []
            for pp in tempList
            {
                var diffFlag = 0
                let note = pp.value(forKey: "pp_note") as? String
                let name = pp.value(forKey: "pp_name") as? String
                let phone = pp.value(forKey: "pp_phone") as? String
                for tag in selectedTags
                {
                    //if tag == "線上資料"
                    //{
                    //    continue
                    //} else {
                        if ((note?.range(of: tag)) == nil)
                        {
                            diffFlag = 1
                        }
                    //}
                }
                if diffFlag != 0
                {
                    continue
                }
                if (infoList.count > 0)
                {
                    var sameFlag = 0
                    for t in infoList
                    {
                        if name == t.value(forKey: "pp_name") as? String &&
                            phone == t.value(forKey: "pp_phone") as? String
                        {
                            sameFlag = 1
                        }
                    }
                    if sameFlag == 0
                    {
                        infoList.append(pp)
                    }
                }
                else
                {
                    infoList.append(pp)
                }
            }
        } else {
            if infoList.count == 0 && debug == 1
            {
                if (debug == 1) {
                    print("No Data in INFOLIST")
                }
            }
            infoList = tempList
        }
        
        myTableView.reloadData()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(endOfWork), userInfo: nil, repeats: true)
            Reload_ppList()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buttonsTabLoad() {
        let ButtonWidth = 30
        let buttonGap = 30
        let centerX = Int(fullScreenSize.width / 2)
        let ySeat = startHeaderY
        locateBtn = UIButton(
            frame: CGRect(x: centerX - (ButtonWidth*2 + buttonGap*2 + ButtonWidth/2), y: ySeat, width: ButtonWidth, height: buttonTabHigh))
        locateBtn!.setImage(UIImage(named: "tracker.png"), for: .normal)
        locateBtn!.isEnabled = true
        locateBtn!.addTarget(
            self,
            action: #selector(locate),
            for: .touchUpInside)
        dash_ScrollView.addSubview(locateBtn!)

        tripPlanBtn = UIButton(
                   frame: CGRect(x: centerX - (ButtonWidth + buttonGap + ButtonWidth/2), y: ySeat, width: ButtonWidth, height: buttonTabHigh - 2))
        tripPlanBtn!.setImage(UIImage(named: "tripplanlists@x3.png"), for: .normal)
        tripPlanBtn!.isEnabled = true
        tripPlanBtn!.addTarget(
               self,
               action: #selector(planninglists),
               for: .touchUpInside)
        dash_ScrollView.addSubview(tripPlanBtn!)
        
        cloudBtn = UIButton(
            frame: CGRect(x: centerX - (ButtonWidth/2), y: ySeat, width: ButtonWidth, height: buttonTabHigh + 3))
        let myUserDefaults = UserDefaults.standard
        if let cloudst = myUserDefaults.value(forKey: "cloud_connected") as? Int
        {
            if cloudst == 1 {
                cloudBtn!.setImage(UIImage(named: "cloud.png"), for: .normal)
            } else {
                cloudBtn!.setImage(UIImage(named: "nonCloud.png"), for: .normal)
            }
        } else {
            myUserDefaults.setValue(cloud_connect, forKey: "cloud_connected")
            if (cloud_connect == 1) {
                cloudBtn!.setImage(UIImage(named: "cloud.png"), for: .normal)
            } else {
                cloudBtn!.setImage(UIImage(named: "nonCloud.png"), for: .normal)
            }
        }
        cloudBtn!.isEnabled = true
        cloudBtn!.addTarget(
            self,
            action: #selector(cloundOnOff),
            for: .touchUpInside)
        dash_ScrollView.addSubview(cloudBtn!)
        
        filterBtn = UIButton(
            frame: CGRect(x: centerX + (ButtonWidth/2 + buttonGap), y: ySeat, width: ButtonWidth, height: ButtonWidth))
        filterBtn!.setImage(UIImage(named: "filter_light2.png"), for: .normal)
        filterBtn!.isEnabled = true
        filterBtn!.addTarget(
            self,
            action: #selector(sel_filter),
            for: .touchUpInside)
        dash_ScrollView.addSubview(filterBtn!)
        
        searchBtn = UIButton(
            frame: CGRect(x: centerX + (ButtonWidth/2 + buttonGap*2 + ButtonWidth), y: ySeat, width: ButtonWidth-5, height: buttonTabHigh-5))
        searchBtn!.setImage(UIImage(named: "search@x3.png"), for: .normal)
        searchBtn!.isEnabled = true
        searchBtn!.addTarget(
            self,
            action: #selector(searchCloud),
            for: .touchUpInside)
        dash_ScrollView.addSubview(searchBtn!)
    }

    func pickerViewLoad()
    {
        let ySeat = startHeaderY + buttonTabHigh + 5
        // 建立一個 UITextField
        dashTextField = UITextField(frame: CGRect(x: 0, y: ySeat, width: Int(fullScreenSize.width), height: pickTextHigh))
        tabView_h = Int(fullScreenSize.height) - pickTextHigh
        //print("tabView Hight = reduce pickview ", tabView_h)
        // 建立 UIPickerView
        let myPickerView = UIPickerView()
        myPickerView.tag = dashPickerViewTag
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
        dashTextField.inputView = myPickerView
        dashTextField.inputAccessoryView = toolBar
        
        // 設置 UITextField 預設的內容
        sel_country = GloupID().Taiwan_groupID
        DashViewController.country = Countries().list[sel_country - 1]
        DashViewController.city = Cities().citiesOfAll
        
        if sel_country == GloupID().Taiwan_groupID
        {
            DashViewController.city = Cities().citiesOfTaiwan[1]
        }
        else if sel_country == GloupID().all_groupID
        {
            DashViewController.city = Cities().citiesOfAll
        }
        else if sel_country == GloupID().Japan_groupID
        {
            DashViewController.city = Cities().citiesOfJapan[1]
        }
        else if sel_country == GloupID().China_groupID
        {
            DashViewController.city = Cities().citiesOfChina[1]
        }
        dashTextField.text = "\(DashViewController.country)   |   \(DashViewController.city)"
        
        // 設置 UITextField 的 tag 以利後續使用
        dashTextField.tag = dashTextFieldTag
        
        // 設置 UITextField 其他資訊並放入畫面中
        dashTextField.backgroundColor = UIColor(red: 0, green: 160/255, blue: 1, alpha: 0.8)
        //UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
        dashTextField.textAlignment = .center
        //dashTextField.center = CGPoint(x: fullScreenSize.width * 0.5, y: fullScreenSize.height * 0.1)

        dash_ScrollView.addSubview(dashTextField)

        // pre-load data
        //let db:DB_Access = DB_Access()
        //print("pickerViewLoad: prepare city:",DashViewController.city, " pps")
        if (DashViewController.city.isEmpty)
        {
            //print("pickerViewLoad: No selected City")
        }
        else
        {
            if let temp = db.pp_searchByCity(city: DashViewController.city)
            {
                infoList = temp //db.pp_searchByCity(city: city)!
            }
            else
            {
                //print("pickerViewLoad: DB Data is null...")
            }
        }
        
    }
    
    func TagsTabLoad()
    {
        tagsButton = UIButton(
            frame: CGRect(x: 0, y: startHeaderY + pickTextHigh, width: Int(fullScreenSize.width), height: tagsButtonHigh))
        tagsButton!.setTitle("▼ 使用篩選功能", for: .normal)
        tagsButton!.setTitleColor(UIColor.white, for: .normal)
        tagsButton!.isEnabled = true
        tagsButton!.backgroundColor = UIColor(red: 0, green: 190/255, blue: 1, alpha: 0.8)
        tagsButton!.addTarget(
            self,
            action: #selector(sel_filter),
            for: .touchUpInside)
        
        dash_ScrollView.addSubview(tagsButton!)
    }
    
    func checkLocalDB()
    {
        let https_hdlr = HTTPS_jsonHandler()
        https_hdlr.HTTPS_jsonHandler_Init()
        https_hdlr.checkLocalDB_PPStatus()
    }
    
    //tabview
    func tabViewLoad()
    {
        var lpgr:UILongPressGestureRecognizer?
        lpgr = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        let tabbarHight = Int((self.tabBarController?.tabBar.frame.size.height)!)
        let adsHight = Int(self.bannerView.frame.size.height)
        let headerHight = 10
        tabView_h = tabView_h - tabbarHight - adsHight - headerHight - buttonTabHigh//tagsButtonHigh
        myTableView = UITableView(frame: CGRect(
            x: 0, y: Int(pickTextHigh + startHeaderY + tagsButtonHigh),
            width: Int(fullScreenSize.width),
            height: tabView_h
            ), style: .grouped)
        myTableView.register(
            DashTableViewCell.self, forCellReuseIdentifier: DashTableViewCell.reuseID)
        myTableView.delegate = self // as! UITableViewDelegate
        myTableView.dataSource = self // as! UITableViewDataSource
        myTableView.separatorStyle = .singleLine
        myTableView.allowsSelection = true
        myTableView.allowsMultipleSelection = false
        myTableView.addGestureRecognizer(lpgr!)
        dash_ScrollView.addSubview(myTableView)
    }
    
    
    @objc func longPressAction(gestureReconizer: UILongPressGestureRecognizer) {
        //print("longPressAction gestureReconizer=\(gestureReconizer)")
       
        if gestureReconizer.state == UIGestureRecognizerState.ended {
            let curPoint:CGPoint = gestureReconizer.location(in: self.myTableView)
            if let indexPath = self.myTableView.indexPathForRow(at: curPoint) {
                if (self.debug == 1) {
                    print("CGPoint : \(curPoint)")
                    print("indexPath=\(indexPath)")
                    let curCell = self.myTableView.cellForRow(at: indexPath)
                    print("curCell name=\(String(describing: curCell!.textLabel?.text!))")
                }
                //let nameArray = tripplanlistsVC.getplanlistname()
                selPlanOptions = tripplanlistsVC.getplanlistname()
                if (self.debug == 1) {
                    print(" name Array = \(selPlanOptions)")
                }
                pp_selectedIndex = indexPath.row
                disp_TripPlanListSelectOpt(point: curPoint)//sender: <#UIBarButtonItem#>)
                if (self.debug == 1) {
                    print(" disp_TripPlanListSelectOpt proccessed")
                }
                //let pp = infoList[indexPath.row]
            } else {
                if (self.debug == 1) {
                    print("not find cell for current long press point")
                }
            }
        }
    }

    // 必須實作的方法：每一組有幾個 cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (infoList.count == 0)
        {
            return 0
        }
        return infoList.count
    }
    
    // 必須實作的方法：每個 cell 要顯示的內容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 取得 tableView 目前使用的 cell
        let cell = tableView.dequeueReusableCell(withIdentifier: DashTableViewCell.reuseID, for: indexPath) as UITableViewCell
        cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.detailTextLabel?.numberOfLines = 0
        var Image : UIImage?
        let id = infoList[indexPath.row].value(forKey: "id") as! Int
        if (id == 0) {
            Image = UIImage(named: "cloud")
        } else {
            Image = UIImage(named: "book")
        }
        let ImageView = UIImageView(image: Image)
        ImageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        cell.accessoryView = ImageView
        if infoList.count > 0
        {
            if let name = infoList[indexPath.row].value(forKey: "pp_name")
            {
                cell.textLabel?.text = name as? String
            }
            if let note = infoList[indexPath.row].value(forKey: "pp_note")
            {
                cell.detailTextLabel?.text = note as? String
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
        let pp = infoList[indexPath.row]
        let ppV = PP_Viewer()
        ppV.PPdetail = pp
        ppV.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(ppV, animated: true, completion: nil)

    }
    
    // 點選 Accessory 按鈕後執行的動作
    // 必須設置 cell 的 accessoryType
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if self.debug == 1 {
            let name = "\(infoList[indexPath.row].value(forKey: "pp_name") as! String)"
            print("按下的是 \(name) 的 detail")
        }
    }

    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath)
        -> [UITableViewRowAction]?
    {
        var ppL = 0 // local data - 0, cloud data - 1
        var actionArr:Array<UITableViewRowAction> = [UITableViewRowAction]()
        var actionDelete:UITableViewRowAction? = nil
        var actionSave:UITableViewRowAction? = nil

        if self.infoList[indexPath.row].value(forKey: "pp_status") as! Int == 1 || self.infoList[indexPath.row].value(forKey: "pp_status") as! Int == 0
        {
            ppL = 0
        } else if self.infoList[indexPath.row].value(forKey: "pp_status") as! Int == 2 {
            ppL = 1
        }

        if ppL == 0
        {
            // 建立刪除按鈕
            actionDelete =
                UITableViewRowAction(style: UITableViewRowActionStyle.default,
                                     title: "刪除")
                {
                    (action, indexPath) in
                    let select:Int = indexPath.row
                    let name = "\(self.infoList[select].value(forKey: "pp_name") as! String)"
                    let id:String = "\(self.infoList[select].value(forKey: "id")!)"
                    //print("delete : ID: ",id, "NAME: ",name)
                    //let db:DB_Access = DB_Access()
                    if (self.db.pp_delete(id: id,ppName: name))
                    {
                        self.infoList.remove(at: select)
                    }
                    tableView.isEditing = false; // 退出編輯模式
                    self.ppList_updated = 1
                    self.cleanAllCacheDB()
                    self.Reload_ppList()
                }
            actionDelete!.backgroundColor =  UIColor.red
        } else if ppL == 1 {
            actionSave =
                UITableViewRowAction(style: UITableViewRowActionStyle.default,
                                     title: "存入手冊")
                {
                    (action, indexPath) in
                    let myUserDefaults = UserDefaults.standard
                    if let email = myUserDefaults.value(forKey: "user_email") as? String
                    {
                        if !email.isEmpty
                        {
                            self.userLogin = 1
                        }
                    } else {
                        self.userLogin = 0
                    }
                    if self.userLogin == 0
                    {
                        self.addViewHint(Title: "會員未登入", msgStr: "請至設定頁面登入會員", btnTitle: "確定")
                        return
                    }
                    //print("Save PP")
                    let pp_name = self.infoList[indexPath.row].value(forKey: "pp_name") as! String
                    let pp_phone = self.infoList[indexPath.row].value(forKey: "pp_phone") as! String
                    let pp_country = self.infoList[indexPath.row].value(forKey: "pp_country") as! String
                    let pp_address = self.infoList[indexPath.row].value(forKey: "pp_address") as! String
                    let pp_fb = self.infoList[indexPath.row].value(forKey: "pp_fb") as! String
                    let pp_web = self.infoList[indexPath.row].value(forKey: "pp_web") as! String
                    let blogger_intro = self.infoList[indexPath.row].value(forKey: "blogger_intro") as! String
                    let pp_opentime = self.infoList[indexPath.row].value(forKey: "pp_opentime") as! String
                    let pp_note = self.infoList[indexPath.row].value(forKey: "pp_note") as! String
                    let pp_descrip = self.infoList[indexPath.row].value(forKey: "pp_descrip") as! String
                    let pp_score = self.infoList[indexPath.row].value(forKey: "pp_score") as! Int
                    
                    //print("Save \(pp_name) to local db")
                    //let db:DB_Access = DB_Access()
                    let pid = self.db.pp_insert(pp_name: pp_name, pp_phone: pp_phone, pp_country: pp_country, pp_address: pp_address, pp_fb: pp_fb, pp_web: pp_web, pp_blogger_intro: blogger_intro, pp_opentime: pp_opentime, pp_note: pp_note, pp_descrip: pp_descrip, pp_score: String(pp_score))
                    if pid > 0
                    {
                        if self.db.pp_updateStatus(id: "\(pid)", pp_status: "1")
                        {
                            self.infoList.remove(at: indexPath.row)
                            var c_idx = 0
                            for c in self.cloudList
                            {
                                if c.value(forKey: "pp_name") as? String == pp_name
                                {
                                    break
                                }
                                c_idx = c_idx + 1
                            }
                            self.cloudList.remove(at: c_idx)
                            //print("saveAction: Successful")
                            
                        }
                    }

                    tableView.isEditing = false; // 退出編輯模式
                    self.cleanAllCacheDB()
                    self.ppList_updated = 1
                    self.Reload_ppList()
            }
            actionSave!.backgroundColor =  UIColor.red
        }
        // 建立刪除按鈕
        let actionCencel:UITableViewRowAction =
            UITableViewRowAction(style: UITableViewRowActionStyle.default,
                                 title: "取消")
            {
                (action, indexPath) in
                tableView.isEditing = false; // 退出編輯模式
                tableView.reloadData() // 更新tableView
            }
        actionCencel.backgroundColor =  UIColor.gray

        // 將按鈕動作加入Array，並回傳
        actionArr.append(actionCencel)
        
        if ppL == 0
        {
            actionArr.append(actionDelete!)
        } else if ppL == 1 {
            actionSave?.backgroundColor = UIColor(red: 0, green: 190/255, blue: 1, alpha: 0.8)
            actionArr.append(actionSave!)
        }
        
        
        return actionArr;
    }
    
    // 有幾組 section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 每個 section 的標題
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "你的秘境"
    }
    
    func scrollViewLoad()
    {
        dash_ScrollView = UIScrollView()
        dash_ScrollView.frame = CGRect(x: 0, y: 0, width: fullScreenSize.width, height: fullScreenSize.height)
        dash_ScrollView.contentSize = CGSize(width: fullScreenSize.width, height: fullScreenSize.height * 1.5)
        dash_ScrollView.showsHorizontalScrollIndicator = false
        dash_ScrollView.showsVerticalScrollIndicator = false
        dash_ScrollView.indicatorStyle = .black
        dash_ScrollView.isScrollEnabled = false
        dash_ScrollView.scrollsToTop = false
        dash_ScrollView.isDirectionalLockEnabled = false
        dash_ScrollView.bounces = true
        dash_ScrollView.bouncesZoom = true
        dash_ScrollView.delegate = self
        dash_ScrollView.isPagingEnabled = false
        self.view.addSubview(dash_ScrollView)
    }
    
    func loadGoogleBannerAD()
    {
        //print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
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
            print("DashViewController: adView:didFailToReceiveAdWithError : \(error)")
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

    @objc func refreshEvery5Secs(){
        // refresh code
        myTableView.reloadData()
    }
    
    func mergeList(inList: [NSManagedObject], toList: [NSManagedObject]) -> [NSManagedObject]
    {
        var toL = toList
        for inP in inList
        {
            var eq = 0
            for toP in toList
            {
                let toP_name = toP.value(forKey: "pp_name") as? String
                let inP_name = inP.value(forKey: "pp_name") as? String
                if toP_name == inP_name
                {
                    eq = 1
                    break
                }
            }
            if eq == 0
            {
                toL.append(inP)
            }
        }
        return toL
    }
    
    func mergeList_to_cloudList(ns_cloudList : [NSDictionary])
    {
        if debug == 1 {
            print ("Cloud List : ", ns_cloudList)
        }
        //cloudList.removeAll()
        //let db = DB_Access()
        for p in ns_cloudList
        {
            var InInfoList = 0
            for cloudP in cloudList
            {
                let name = cloudP.value(forKey: "pp_name") as! String
                let cloud_p_name = p.value(forKey: "name") as! String
                if name == cloud_p_name {
                    //print("Already HAVE :\(name)/local \(cloud_p_name)/cloud")
                    InInfoList = 1
                    break
                }
            }
            if InInfoList == 0
            {
                let nsmObjc = db.db_NSManagedObject()
                if let name = p.value(forKey: "name") as? String
                { nsmObjc!.setValue(name, forKey: "pp_name") }
                else { nsmObjc!.setValue(" ", forKey: "pp_name") }
                
                if let phone = p.value(forKey: "phone") as? String
                { nsmObjc!.setValue(phone, forKey: "pp_phone") }
                else { nsmObjc!.setValue(" ", forKey: "pp_phone") }
                
                if let country = p.value(forKey: "country") as? String
                { nsmObjc!.setValue(country, forKey: "pp_country") }
                else { nsmObjc!.setValue(" ", forKey: "pp_country") }

                if let address = p.value(forKey: "address") as? String
                { nsmObjc!.setValue(address, forKey: "pp_address") }
                else { nsmObjc!.setValue(" ", forKey: "pp_address") }
                
                if let fb = p.value(forKey: "fb") as? String
                { nsmObjc!.setValue(fb, forKey: "pp_fb") }
                else { nsmObjc!.setValue(" ", forKey: "pp_fb") }
                
                if let web = p.value(forKey: "web") as? String
                { nsmObjc!.setValue(web, forKey: "pp_web") }
                else { nsmObjc!.setValue(" ", forKey: "pp_web") }

                if let bloggerIntro = p.value(forKey: "bloggerIntro") as? String
                { nsmObjc!.setValue(bloggerIntro, forKey: "blogger_intro") }
                else { nsmObjc!.setValue(" ", forKey: "blogger_intro") }

                if let tag_note = p.value(forKey: "tag_note") as? String
                { nsmObjc!.setValue(tag_note, forKey: "pp_note") }
                else { nsmObjc!.setValue(" ", forKey: "pp_note") }

                if let score = p.value(forKey: "score") as? Int
                { nsmObjc!.setValue(score, forKey: "pp_score") }
                else { nsmObjc!.setValue(0, forKey: "pp_score") }

                nsmObjc!.setValue(2, forKey: "pp_status")
                
                if let description = p.value(forKey: "description") as? String
                { nsmObjc!.setValue(description, forKey: "pp_descrip") }
                else { nsmObjc!.setValue(" ", forKey: "pp_descrip") }
                
                if let opentime = p.value(forKey: "opentime") as? String
                { nsmObjc!.setValue(opentime, forKey: "pp_opentime") }
                else { nsmObjc!.setValue(" ", forKey: "pp_opentime") }

                if let pic_url = p.value(forKey: "pic_url") as? String
                { nsmObjc!.setValue(pic_url, forKey: "pp_pic") }
                else { nsmObjc!.setValue(" ", forKey: "pp_pic") }
                
                cloudList.append(nsmObjc!)
            }
        }
 
        ppList_updated = 1
        Reload_ppList()
    }

    func DownloadPPfromCloud()
    {
        let cacheCity = DashViewController.city
        let cacheCountry = DashViewController.country
        let https_hdlr = HTTPS_jsonHandler()
        https_hdlr.HTTPS_jsonHandler_Init()
        if cacheCountry == "所有" || cacheCity == "所有" || https_hdlr.getCloudFeeback()
        {
            return
        }
        //print("Download")
        https_hdlr.HTTPS_Donwload_PPsOfCity(country_in: cacheCountry, city_in: cacheCity)
        addAlertMessage(Title:"下載景點", msgStr: "開始下載\(cacheCountry) | \(cacheCity)區域內的景點")
        //closeAlertMessage()
        let dispatchQueue = DispatchQueue(label: "q_wait_cloud_success", qos: .background)
        let additionalTime: DispatchTimeInterval = .seconds(2)
        
        //DispatchQueue.main.asyncAfter(deadline: .now() + additionalTime) {
        dispatchQueue.asyncAfter(deadline: .now() + additionalTime) {

            var delayCnt = 0
            while !https_hdlr.getCloudFeeback()
            {
                sleep(1)
                delayCnt = delayCnt + 1
                if delayCnt > 1000
                {
                    if self.debug == 1 {
                        print ("BREAK WHILE LOOP")
                    }
                    break
                }
            }
            if cacheCity != DashViewController.city || cacheCountry != DashViewController.country
            {
                https_hdlr.Clean_CloudStatus()
                self.closeAlertMessage()
                return
            }
            let temp = try? https_hdlr.Get_PPsList()
            DispatchQueue.main.async {
                self.mergeList_to_cloudList(ns_cloudList: temp!)
                https_hdlr.Clean_CloudStatus()
            }
        }
    }
    
    func cleanAllCacheDB() {
        dbList.removeAll()
        cloudList.removeAll()
    }
    
    @objc func searchCloud() {
        let searchVC = CloudSearch()
        searchVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(searchVC, animated: true, completion: nil)
    }
    
    @objc func cloundOnOff() {
        let myUserDefaults = UserDefaults.standard
        if (cloud_connect == 0) {
            addAlertMessage(Title:"連接伺服器中", msgStr: "開啟雲端資料庫連線功能")
            cloud_connect = 1
            myUserDefaults.setValue(cloud_connect, forKey: "cloud_connected")
            myUserDefaults.synchronize()
            
            Reload_ppList()
            tagsSelectedVC = tagsSelectedViewController()
            tagsSelectedVC.setPPList(ppList: infoList)
            cloudBtn!.setImage(UIImage(named: "cloud.png"), for: .normal)
        } else {
            addAlertMessage(Title:"中斷伺服器連接", msgStr: "停止雲端資料庫連線功能")
            cloud_connect = 0
            myUserDefaults.setValue(cloud_connect, forKey: "cloud_connected")
            myUserDefaults.synchronize()
            
            Reload_ppList()
            tagsSelectedVC = tagsSelectedViewController()
            tagsSelectedVC.setPPList(ppList: infoList)
            cloudBtn!.setImage(UIImage(named: "nonCloud"), for: .normal)
        }
        closeAlertMessage()
    }
    
    @objc func disp_TripPlanListSelectOpt(point: CGPoint)//(namearr: [String], select : NSManagedObject)
    {
        let alertController = UIAlertController(title: "請選擇", message: "存入哪一個計畫中？", preferredStyle: .actionSheet)

        let tripplansel_vc = TripPlanListSelectOpt()
        tripplansel_vc.setData(list: selPlanOptions)
        tripplansel_vc.setPP(selPP: self.infoList[pp_selectedIndex])
        alertController.setValue(tripplansel_vc, forKey: "contentViewController")
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        alertController.addAction(cancelAction)
        if self.debug == 1 { print("present  alertController..") }
        if alertController.popoverPresentationController != nil {
            //popoverPresentationController!.barButtonItem = sender
            alertController.popoverPresentationController!.sourceView = self.view
            alertController.popoverPresentationController!.sourceRect = CGRect(x: point.x, y: point.y + 148.0, width: 1.0, height: 1.0)
        }
        self.present(alertController, animated: true, completion: nil)
        //self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func planninglists() {
        tripplanlistsVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(tripplanlistsVC, animated: true, completion: nil)
    }
    
    @objc func locate() {
        addAlertMessage(Title:"定位中", msgStr: "正在鎖定您所在城市")
        closeAlertMessage()
        if let notifVC = self.tabBarController?.viewControllers?[3] as? NotifViewController{
            if let currCity = notifVC.getCurrCity(), let currCountry = notifVC.getCurrCountry() {
                cleanAllCacheDB()
                DashViewController.country = currCountry
                DashViewController.city = currCity
                set_AreaNCountry(country_in: currCountry, city_in: currCity)
                CountryNCity = "\(currCountry)   |   \(currCity)"
                self.dashTextField!.text = CountryNCity
                ppList_updated = 1
                Reload_ppList()
            }
        }
    }

    @objc func sel_filter()
    {
        if (ppList_updated == 1)
        {
            // create new
            if debug == 1
            {
                print("got new tagsSelectedVC...")
            }
            tagsSelectedVC = tagsSelectedViewController()
            tagsSelectedVC.setPPList(ppList: infoList)

            dbListCount = dbList.count
            cloudListCount = cloudList.count
            ppList_updated = 0
        }
        else
        {
            if (dbListCount != dbList.count) || (cloudListCount != cloudList.count)
            {
                tagsSelectedVC = tagsSelectedViewController()
                let ppList = mergeList(inList: dbList, toList: cloudList)
                tagsSelectedVC.setPPList(ppList: ppList)
            }
            else
            {
                if debug == 1 {
                    print("using old tab.....")
                }
            }
        }
        if debug == 1 {
            print("sel_filter : ppList_updated : ", ppList_updated)
        }
        tagsSelectedVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(tagsSelectedVC, animated: true, completion: nil)
    }

    @objc func doneSelect()
    {
        if dashTextField!.text != CountryNCity
        {
            cloudList.removeAll()
        }
        let spliteStr = " | "
        
        if !DashViewController.country.isEmpty
        {
            CountryNCity = DashViewController.country + spliteStr
        }
        if !DashViewController.city.isEmpty
        {
            CountryNCity = CountryNCity! + DashViewController.city
        } else {
            if sel_country == GloupID().Taiwan_groupID
            {
                DashViewController.city = Cities().citiesOfTaiwan[1]
            }
            else if sel_country == GloupID().all_groupID
            {
                DashViewController.city = Cities().citiesOfAll
            }
            else if sel_country == GloupID().Japan_groupID
            {
                DashViewController.city = Cities().citiesOfJapan[1]
            }
            else if sel_country == GloupID().China_groupID
            {
                DashViewController.city = Cities().citiesOfChina[1]
            }
            CountryNCity = CountryNCity! + DashViewController.city
        }
        
        dashTextField?.text = CountryNCity
        dashTextField?.resignFirstResponder()
        ppList_updated = 1
    }
    
    
    @objc func endOfWork() {
        refreshControl.endRefreshing()
        if timer != nil
        {
            timer.invalidate()
        }
        timer = nil
    }

    // 按空白處會隱藏編輯狀態
    @objc func hideKeyboard(tapG:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    @objc func closeAlertMessage() {
        alertShortMessage!.dismiss(animated: true, completion: nil)
    }
    
    @objc func addAlertMessage(Title:String, msgStr: String) {
        // 建立一個提示框
        alertShortMessage = UIAlertController(
            title: Title,
            message: msgStr,
            preferredStyle: .alert)
        // 顯示提示框
        self.present(
            alertShortMessage!,
            animated: true,
            completion: {
                self.alertShortMessage!.dismiss(animated: true, completion: nil)
        })
    }
    
    func addViewHint(Title:String, msgStr: String, btnTitle:String) {
        
        // 建立一個提示框
        let alertController = UIAlertController(
            title: Title,
            message: msgStr,
            preferredStyle: .alert)
        
        // 建立[確認]按鈕
        let okAction = UIAlertAction(
            title: btnTitle,
            style: .default,
            handler: {
                (action: UIAlertAction!) -> Void in
                if self.debug == 1 {
                    print("addViewHint:OK pressed")
                }
        })
        alertController.addAction(okAction)
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }

}

private class DashTableViewCell: UITableViewCell {
    
    static let reuseID = "DashTableViewCellID"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class TripPlanListSelectOpt : UITableViewController{
    var cells = [String]()
    var pp: NSManagedObject? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.separatorStyle = .singleLineEtched
        self.tableView.allowsSelection = true
        self.tableView.register(TripPlanListSelectOptCell.self, forCellReuseIdentifier: TripPlanListSelectOptCell.reuseID)
    }
    
    func setPP(selPP : NSManagedObject) {
        pp = selPP
    }
    
    func setData(list : [String]) {
        cells = list
    }
    
    // 必須實作的方法：每一組有幾個 cell
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (cells.count == 0)
        {
            return 0
        }
        return cells.count
    }
    
    // 必須實作的方法：每個 cell 要顯示的內容
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TripPlanListSelectOptCell.reuseID, for: indexPath) as! TripPlanListSelectOptCell
        cell.textLabel!.text = cells[indexPath.row]
        cell.textLabel!.backgroundColor = UIColor.clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
        if (pp != nil) {
            TripPlanListsViewController().addPP(ppList: pp!, planname: cells[indexPath.row])
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // 有幾組 section
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

private class TripPlanListSelectOptCell: UITableViewCell {
    
    static let reuseID = "TripPlanListSelectOptCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

