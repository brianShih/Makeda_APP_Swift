//
//  tripplanViewController.swift
//  Makeda
//
//  Created by Brian on 2019/11/20.
//  Copyright © 2019 breadcrumbs.tw. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import GoogleMobileAds


class TripplanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, GADBannerViewDelegate {
    let debug = 0
    let dayslimit = 50
    let fullScreenSize = UIScreen.main.bounds.size
    var bannerView: GADBannerView!
    var days_scrollview: UIScrollView?
    var planPPTableV: UITableView?
    var days_collectionView: UICollectionView?
    var editButton: UIButton?
    var db : TPLSDBAccess?
    var editModeStatus = 0
    var removeIndex = -1
    let StartY = 50
    let StartX = 20
    var offsetY = 0
    let ButtonWidth = 30
    let ButtonHight = 40
    let goBackButtonID = 1001
    let AddDayButtonID = 1002
    let EditButtonID = 1003
    var selDay: String? = "DAY1"
    var undefList: [NSManagedObject] = []
    var dayList: [NSManagedObject] = []
    var daysitem = [String]()
    var planname : String?
    var navBtnIndexPath = [Int]()
    var callBtnIndexPath = [Int]()
    
    struct contentStruct : Codable {
        public var content: [String: [ppModel]] = [:]
    }
    
    struct ppModel: Codable {
        var id : Int
        var name : String
        var phone : String
        var country : String
        var addr : String
        var fb : String
        var web : String
        var blogInfo : String
        var opentime : String
        var tag_note : String
        var descrip : String
        var distance : Int
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        db = TPLSDBAccess()
        loadGoogleBannerAD()
        buttonLayerLoad()
        addDayButtonLoad()
        collectionViewLoad()
        collectionDayLoad()
        tableViewLoad()
        undefListLoad()
    }
    
    func buttonLayerLoad() {
        let backButton = UIButton(
            frame: CGRect(x: StartX, y: StartY, width: ButtonWidth, height: ButtonHight + 3))
        backButton.titleLabel?.font = UIFont(name: "Helvetica-Light", size: 20)
        backButton.setTitle("＜", for: .normal)
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.backgroundColor = UIColor.clear
        backButton.tag = goBackButtonID
        
        // 按鈕是否可以使用
        backButton.isEnabled = true
        
        // 按鈕按下後的動作
        backButton.addTarget(
            self,
            action: #selector(self.goBack),
            for: .touchUpInside)
        
        self.view.addSubview(backButton)
        
        editButton = UIButton(
            frame: CGRect(x: Int(fullScreenSize.width) - (StartX + ButtonWidth), y: StartY + 5, width: Int(ButtonWidth - 5), height: Int(ButtonHight - 15)))
        editButton!.setImage(UIImage(named: "edit@x3.png"), for: .normal)
        editButton!.setTitleColor(UIColor.black, for: .normal)
        editButton!.backgroundColor = UIColor.clear
        editButton!.tag = EditButtonID
        
        // 按鈕是否可以使用
        editButton!.isEnabled = true
        
        // 按鈕按下後的動作
        editButton!.addTarget(
            self,
            action: #selector(self.editMode),
            for: .touchUpInside)
        
        self.view.addSubview(editButton!)
        //offsetY = StartY + ButtonHight + 3
        offsetY = StartY + ButtonHight + 3
    }
    
    func addDayButtonLoad() {
        let addDayButton = UIButton(
            frame: CGRect(x: StartX, y: offsetY + 5, width: ButtonWidth, height: ButtonHight + 3))
        //addDayButton.setTitle("＜", for: .normal)
        addDayButton.setImage(UIImage(named: "plus@x3.png"), for: .normal)
        addDayButton.setTitleColor(UIColor.black, for: .normal)
        addDayButton.backgroundColor = UIColor.clear
        addDayButton.tag = AddDayButtonID
        
        // 按鈕是否可以使用
        addDayButton.isEnabled = true
        
        // 按鈕按下後的動作
        addDayButton.addTarget(
            self,
            action: #selector(self.addDay),
            for: .touchUpInside)
        
        self.view.addSubview(addDayButton)
        //offsetY = StartY + ButtonHight + 3
    }
    
    func setPlanname( name : String) {
        planname = name
    }
    
    func dayListLoad(day: String) {
        dayList = []
        if self.debug == 1 {
            print("TripplanViewController : dayListLoad:")
        }
        let l_db = TPLSDBAccess()
        let plan = l_db.searchByName(name: planname!)
        //let jsonEncoder = JSONEncoder()
        //let id_str = "\(plan!.value(forKey : "id") as! Int)"
        let content = plan!.value(forKey: "contentJsonFormat") as! String
        do {
            if !content.isEmpty {
                let jsondata = content.data(using: .utf8)
                let decoder = JSONDecoder()
                let de_json = try decoder.decode(TripplanViewController.contentStruct?.self, from: jsondata!)
                de_json!.content[day]?.forEach({ (ppModel) in
                    let pp = DB_Access().db_NSManagedObject()
                    if self.debug == 1 {
                        print("TripplanViewController : dayListLoad: moving - \(ppModel.name)")
                    }

                    pp!.setValuesForKeys(["pp_name" : ppModel.name,
                                          "pp_phone" : ppModel.phone,
                                          "pp_country" : ppModel.country,
                                          "pp_address" : ppModel.addr,
                                          "pp_fb" : ppModel.fb,
                                          "pp_web" : ppModel.web,
                                          "blogger_intro" : ppModel.blogInfo,
                                          "pp_opentime" : ppModel.opentime,
                                          "pp_note" : ppModel.tag_note,
                                          "pp_descrip" : ppModel.descrip
                                        ])

                    if self.debug == 1 {
                        print("TripplanViewController : dayListLoad: move - \(ppModel.name) Done")
                    }
                    dayList.append(pp!)
                })
            }
        } catch {
            if self.debug == 1 {
                print("TripplanViewController : dayListLoad - Error")
            }
        }
        if planPPTableV != nil {
            planPPTableV!.reloadData()
        }
        if days_collectionView != nil {
            days_collectionView!.reloadData()
        }
    }
    
    func undefListLoad() {
        undefList = []
        if self.debug == 1 {
            print("TripplanViewController : undefListLoad:")
        }
        let l_db = TPLSDBAccess()
        let plan = l_db.searchByName(name: planname!)
        //let jsonEncoder = JSONEncoder()
        //let id_str = "\(plan!.value(forKey : "id") as! Int)"
        let content = plan!.value(forKey: "contentJsonFormat") as! String
        do {
            if !content.isEmpty {
                let jsondata = content.data(using: .utf8)
                let decoder = JSONDecoder()
                let de_json = try decoder.decode(TripplanViewController.contentStruct?.self, from: jsondata!)
                de_json!.content["UNDEF"]?.forEach({ (ppModel) in
                    
                    let pp = DB_Access().db_NSManagedObject()
                    if self.debug == 1 {
                        print("TripplanViewController : undefListLoad: moving - \(ppModel.name)")
                    }

                    pp!.setValuesForKeys(["pp_name" : ppModel.name,
                                          "pp_phone" : ppModel.phone,
                                          "pp_country" : ppModel.country,
                                          "pp_address" : ppModel.addr,
                                          "pp_fb" : ppModel.fb,
                                          "pp_web" : ppModel.web,
                                          "blogger_intro" : ppModel.blogInfo,
                                          "pp_opentime" : ppModel.opentime,
                                          "pp_note" : ppModel.tag_note,
                                          "pp_descrip" : ppModel.descrip
                                        ])

                    if self.debug == 1 {
                        print("TripplanViewController : undefListLoad: move - \(ppModel.name) Done")
                    }
                    undefList.append(pp!)
                })
            }
        } catch {
            if self.debug == 1 {
                print("TripplanViewController : undefListLoad - Error")
            }
        }
        planPPTableV!.reloadData()
    }
    
    func tableViewLoad() {
        var lpgr:UILongPressGestureRecognizer?
        lpgr = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        let adsHight = Int(self.bannerView.frame.size.height)
        let buttonlayerH = offsetY// + colvc
        let tabView_h = Int(fullScreenSize.height) - adsHight - buttonlayerH//tagsButtonHigh
        planPPTableV = UITableView(frame: CGRect(
            x: 0, y: Int(buttonlayerH),
            width: Int(fullScreenSize.width),
            height: tabView_h
            ), style: .grouped)
        planPPTableV!.register(
            tripPlan_cell.self, forCellReuseIdentifier: tripPlan_cell.reuseID)
        planPPTableV!.rowHeight = CGFloat(ButtonHight) * 2.8
        planPPTableV!.delegate = self // as! UITableViewDelegate
        planPPTableV!.dataSource = self // as! UITableViewDataSource
        planPPTableV!.separatorStyle = .singleLine
        planPPTableV!.allowsSelection = true
        planPPTableV!.allowsMultipleSelection = false
        planPPTableV!.addGestureRecognizer(lpgr!)
        self.view.addSubview(planPPTableV!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return dayList.count
        } else if (section == 1) {
            return undefList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 取得 tableView 目前使用的 cell
        let cell = tableView.dequeueReusableCell(withIdentifier: tripPlan_cell.reuseID, for: indexPath) as! tripPlan_cell
        switch (indexPath.section)
        {
        case 0:
            cell.titleLabel.text = dayList[indexPath.row].value(forKey: "pp_name") as? String
            cell.detailLabel.text = dayList[indexPath.row].value(forKey: "pp_note") as? String
            break
        case 1:
            cell.titleLabel.text = undefList[indexPath.row].value(forKey: "pp_name") as? String
            cell.detailLabel.text = undefList[indexPath.row].value(forKey: "pp_note") as? String
            break
        default:
            break;
        }
        //navBtnIndexPath[indexPath.section] = indexPath.row
        cell.navButton.tag = indexPath.section * 1000 + indexPath.row
        cell.navButton.addTarget(
            self,
            action: #selector(self.navGo),
            for: .touchUpInside)
        
        cell.callButton.tag = indexPath.section * 1000 + indexPath.row
        cell.callButton.addTarget(
            self,
            action: #selector(self.callGo),
            for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath)
        -> [UITableViewRowAction]?
    {
        var day = "UNDEF"
        var list : [NSManagedObject]?
        if indexPath.section == 0 {
            day = selDay!
            list = dayList
        } else if indexPath.section == 1 {
            list = undefList
        }
        var actionArr:Array<UITableViewRowAction> = [UITableViewRowAction]()
        // 建立刪除按鈕
        let actionDelete =
        UITableViewRowAction(style: UITableViewRowActionStyle.default,
                           title: "刪除")
        {
          (action, indexPath) in
            self.delPP(ppObj: list![indexPath.row], day: day)
            if indexPath.section == 0 {
                self.dayList.remove(at: indexPath.row)
            } else {
                self.undefList.remove(at: indexPath.row)
            }
            self.planPPTableV!.reloadData()
        }
        actionDelete.backgroundColor =  UIColor.red
        actionArr.append(actionDelete)
        return actionArr
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var list:[NSManagedObject] = []
        // open plan detail..
        if indexPath.section == 0 {
            list = dayList
        } else if indexPath.section == 1 {
            list = undefList
        }
        let pp = list[indexPath.row]
        let ppV = PP_Viewer()
        ppV.PPdetail = pp
        ppV.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(ppV, animated: true, completion: nil)
    }
    
    // 有幾組 section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title : String?
        switch (section) {
        case 0:
            title = selDay
            break
        case 1:
            title = "未定義景點"
            break
        default:
            break
        }
        
        return title
    }
    
    func collectionDayLoad() {
        daysitem = []
        let l_db = TPLSDBAccess()
        let plan = l_db.searchByName(name: planname!)
        var jsonString : String?
        let jsonEncoder = JSONEncoder()
        let id_str = "\(plan!.value(forKey : "id") as! Int)"
        let content = plan!.value(forKey: "contentJsonFormat") as! String
        do {
            if !content.isEmpty {
                let jsondata = content.data(using: .utf8)
                let decoder = JSONDecoder()
                let de_json = try decoder.decode(TripplanViewController.contentStruct?.self, from: jsondata!)
                //var day = 0
                for day in 1...dayslimit {
                    if de_json!.content["DAY\(day)"] != nil {
                        daysitem.append("DAY\(day)")
                    }
                }
            } else {
                daysitem.append("DAY\(1)")
                var contentJson = TripplanViewController.contentStruct()
                contentJson.content = ["UNDEF":[],"DAY1":[]]// = pp//["UNDEF"][0] = pp
                let jsonData = try jsonEncoder.encode(contentJson)
                jsonString = String(data: jsonData, encoding: .utf8)!
                if jsonString!.isEmpty { return }
                if l_db.updateContent(id: id_str, name: planname!, contentJsonFormat: jsonString!) {
                   //if self.debug == 1 {
                       print("TripplanViewController : collectionDayLoad - Successful")
                   //}
                } else {
                   //if self.debug == 1 {
                       print("TripplanViewController : collectionDayLoad - Failure")
                   //}
                }
            }
        } catch {
            if self.debug == 1 {
                print("TripplanViewController : collectionDayLoad - Error")
            }
        }
        days_collectionView!.reloadData()
    }
    
    func collectionViewLoad() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        
        let itemWidth = view.frame.width / 5 + CGFloat(ButtonWidth)
        layout.itemSize = CGSize(width: CGFloat(itemWidth), height: CGFloat(ButtonHight))

        days_collectionView = UICollectionView(frame: CGRect(x: CGFloat(ButtonWidth + StartX), y: CGFloat(offsetY), width: fullScreenSize.width - CGFloat(ButtonWidth + StartX), height: CGFloat(ButtonHight)*1.5), collectionViewLayout: layout)
        //let tap = UITapGestureRecognizer(target: self, action: #selector(saveTapLoc(tapG:)))
        //days_collectionView!.addGestureRecognizer(tap)
        days_collectionView!.register(TripPlanCollectionViewCell.self, forCellWithReuseIdentifier: "days_Cell")
        days_collectionView!.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        days_collectionView!.backgroundColor =  UIColor.white//UIColor(red: 0, green: 160/255, blue: 1, alpha: 1)
        days_collectionView!.isScrollEnabled = true
        days_collectionView!.delegate = self
        days_collectionView!.dataSource = self
        self.view.addSubview(days_collectionView!)
        daysitem.append("DAY\(daysitem.count + 1)")
        dayListLoad(day: selDay!)
        days_collectionView!.reloadData()
        offsetY = offsetY + Int(CGFloat(ButtonHight) * 1.5)
    }
    
    //collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = daysitem.count

        return count
    }
    
    // 必須實作的方法：每個 cell 要顯示的內容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "days_Cell", for: indexPath) as! TripPlanCollectionViewCell
        if (editModeStatus == 1) {
            cell.imageButton.isHidden = false
            cell.imageButton.tag = indexPath.row
            cell.imageButton.addTarget(
                self,
                action: #selector(self.removeTapped),
                for: .touchUpInside)
        } else {
            //cell.imageButton.isUserInteractionEnabled = false
            cell.imageButton.isHidden = true
        }
        cell.titleLabel.text = daysitem[indexPath.row]
        return cell
    }
    
    // 有幾個 section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // 點選 cell 後執行的動作
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)")
        selDay = daysitem[indexPath.item]
        dayListLoad(day: selDay!)
        planPPTableV!.reloadData()
    }
    
    func getPlanCountries(name : String) -> [String] {
        var countries = [String]()
        let l_db = TPLSDBAccess()
        let plan = l_db.searchByName(name: name)
        let content = plan!.value(forKey: "contentJsonFormat") as! String
        do {
            if !content.isEmpty {
                let jsondata = content.data(using: .utf8)
                let decoder = JSONDecoder()
                
                let de_json = try decoder.decode(TripplanViewController.contentStruct?.self, from: jsondata!)
                for d in 0...dayslimit {
                    if (de_json!.content.index(forKey: "DAY\(d)") != nil) {//[dayStr]!.isEmpty {
                        de_json!.content["DAY\(d)"]?.forEach({ (ppObj) in
                            let area = ppObj.country
                            let pp_area = area.split(separator: "|")
                            print("DAY\(d) - pp_area : \(pp_area)")
                            if countries.count == 0 { countries.append(String(pp_area[0])) }
                            else {
                                countries.forEach { (country) in
                                    print("DAY\(d) - country : \(country)")
                                    if !pp_area[0].isEmpty {
                                        if !pp_area[0].contains(country) {
                                            countries.append(String(pp_area[0]))
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
                if (de_json!.content.index(forKey: "UNDEF") != nil) {//[dayStr]!.isEmpty {
                    de_json!.content["UNDEF"]?.forEach({ (ppObj) in
                        let area = ppObj.country
                        let pp_area = area.split(separator: "|")
                        print("UNDEF - pp_area : \(pp_area)")
                        if countries.count == 0 { countries.append(String(pp_area[0])) }
                        else {
                            countries.forEach { (country) in
                                print("UNDEF - country : \(country)")
                                if !pp_area[0].isEmpty {
                                    if !pp_area[0].contains(country) {
                                        countries.append(String(pp_area[0]))
                                    }
                                }
                            }
                        }
                    })
                }
            }
        } catch {
            if self.debug == 1 {
                print("TripplanViewController : addDay - Error")
            }
        }
        if self.debug == 1 {
            print("countries : \(countries)")
        }
        return countries
    }
    
    func getPlanCities (name : String) -> [String] {
        var cities = [String]()
        let l_db = TPLSDBAccess()
        let plan = l_db.searchByName(name: name)
        let content = plan!.value(forKey: "contentJsonFormat") as! String
        do {
            if !content.isEmpty {
                let jsondata = content.data(using: .utf8)
                let decoder = JSONDecoder()
                
                let de_json = try decoder.decode(TripplanViewController.contentStruct?.self, from: jsondata!)
                for d in 0...dayslimit {
                    if (de_json!.content.index(forKey: "DAY\(d)") != nil) {//[dayStr]!.isEmpty {
                        de_json!.content["DAY\(d)"]?.forEach({ (ppObj) in
                            let area = ppObj.country
                            print("DAY\(d) - Area : \(area)")
                            let pp_area = area.split(separator: "|")
                            if cities.count == 0 { cities.append(String(pp_area[1])) }
                            else {
                                cities.forEach { (city) in
                                    print("DAY\(d) - city : \(city)")
                                    if !pp_area[1].isEmpty {
                                        if !pp_area[1].contains(city) {
                                            cities.append(String(pp_area[1]))
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
                
                if (de_json!.content.index(forKey: "UNDEF") != nil) {//[dayStr]!.isEmpty {
                    de_json!.content["UNDEF"]?.forEach({ (ppObj) in
                        let area = ppObj.country
                        print("UNDEF - Area : \(area)")
                        let pp_area = area.split(separator: "|")
                        if cities.count == 0 { cities.append(String(pp_area[1])) }
                        else {
                            cities.forEach { (city) in
                                print("UNDEF - city : \(city)")
                                if !pp_area[1].isEmpty {
                                    if !pp_area[1].contains(city) {
                                        cities.append(String(pp_area[1]))
                                    }
                                }
                            }
                        }
                    })
                }
            }
        } catch {
            if self.debug == 1 {
                print("TripplanViewController : addDay - Error")
            }
        }
        if self.debug == 1 {
            print("cities : \(cities)")
        }
        return cities
    }
    
    @objc func editMode() {
        if (editModeStatus == 0) {
            editModeStatus = 1
            editButton?.setImage(UIImage(named: "save@x3.png"), for: .normal)
        } else {
            editModeStatus = 0
            editButton?.setImage(UIImage(named: "edit@x3.png"), for: .normal)
        }
        days_collectionView!.reloadData()
    }
    
    /*@objc func saveTapLoc(tapG : UITapGestureRecognizer) {
        if tapG.state == UIGestureRecognizerState.ended {
            let curPoint:CGPoint = tapG.location(in: self.days_collectionView)
            let indexPath = self.days_collectionView!.indexPathForItem(at:curPoint)//indexPathForRow(at: curPoint) {
            print("saveTapLoc : index = \(indexPath!.row)")
            if editModeStatus == 1{
                removeIndex = indexPath!.row
            } else {
                removeIndex = -1
            }
            //}
        }
    }*/
    
    @objc func navGo (sender: UIButton) {
        var list :[NSManagedObject] = []
        let section = sender.tag / 1000
        let index = sender.tag - (section * 1000)
        
        if (section == 0) {
            list = dayList
        } else if (section == 1) {
            list = undefList
        }
        print("navGo : section : \(section), index : \(index)")
        let pp_name = list[index].value(forKey: "pp_name") as! String
        let pp_addr = list[index].value(forKey: "pp_address") as! String
        print("callGo: name : \(pp_name), address : \(pp_addr)")

        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!))
        {
            let callWebview =   UIWebView()
            let addr:NSString = pp_addr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! as NSString
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
                let addr:NSString = pp_addr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! as NSString
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
    
    @objc func callGo (sender: UIButton) {
        var list :[NSManagedObject] = []
        let section = sender.tag / 1000
        let index = sender.tag - (section * 1000)
        print("callGo : section : \(section), index : \(index)")
        if (section == 0) {
            list = dayList
        } else if (section == 1) {
            list = undefList
        }
        
        let pp_name = list[index].value(forKey: "pp_name") as! String
        let pp_phone = list[index].value(forKey: "pp_phone") as! String
        if (self.debug == 1) {
            print("callGo : section : \(section), index : \(index)")
            print("callGo: name : \(pp_name), address : \(pp_phone)")
        }
        
        if UIApplication.shared.canOpenURL(URL(string:"tel://")!) != true
        {
            if self.debug == 1 {
                print("Can 't Open tel://")
            }
            return
        }
        if pp_phone.isEmpty { return }
        let cleanNum = pp_phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
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
    
    @objc func removeTapped(sender:UIButton)
    {
        print("day: removeTapped()")
        removeIndex = sender.tag
        //let indexPath = self.days_collectionView!.indexPathForItem(at: <#T##CGPoint#>)
        if (removeIndex != -1) {
            if (removeIndex < daysitem.count) {
                // TODO - move pps to undef
                print( " removeTapped : removeIndex = \(removeIndex)")
                self.moveallOfDay(from: daysitem[removeIndex], to: "UNDEF")
                self.resortDayTtile()
            }
            removeIndex = -1
        }
        dayListLoad(day: selDay!)
        undefListLoad()
    }
    
    @objc func addDay() {
        let dayStr = "DAY\(daysitem.count + 1)"
        daysitem.append(dayStr)
        
        let l_db = TPLSDBAccess()
        let plan = l_db.searchByName(name: planname!)
        let jsonEncoder = JSONEncoder()
        var jsonString: String?
        let id_str = "\(plan!.value(forKey : "id") as! Int)"
        let content = plan!.value(forKey: "contentJsonFormat") as! String
        do {
            if !content.isEmpty {
                let jsondata = content.data(using: .utf8)
                let decoder = JSONDecoder()
                
                var de_json = try decoder.decode(TripplanViewController.contentStruct?.self, from: jsondata!)
                if (de_json!.content.index(forKey: dayStr) == nil) {//[dayStr]!.isEmpty {
                    de_json!.content.updateValue([], forKey: dayStr)//[dayStr:[]]// = pp//["UNDEF"][0] = pp
                    let jsonData = try jsonEncoder.encode(de_json)
                    jsonString = String(data: jsonData, encoding: .utf8)!
                    
                }
            } else {
                var contentJson = TripplanViewController.contentStruct()
                contentJson.content = ["UNDEF":[],"DAY1":[]]// = pp//["UNDEF"][0] = pp
                let jsonData = try jsonEncoder.encode(contentJson)
                jsonString = String(data: jsonData, encoding: .utf8)!
            }
            if jsonString == nil { return }
            if l_db.updateContent(id: id_str, name: planname!, contentJsonFormat: jsonString!) {
                if self.debug == 1 {
                    print("TripplanViewController : addDay - Successful")
                }
            } else {
                if self.debug == 1 {
                    print("TripplanViewController : addDay - Failure")
                }
            }
        } catch {
            if self.debug == 1 {
                print("TripplanViewController : addDay - Error")
            }
        }
        days_collectionView!.reloadData()
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion:nil)
    }
    
    @objc func longPressAction(gestureReconizer: UILongPressGestureRecognizer) {
        //print("longPressAction gestureReconizer=\(gestureReconizer)")
       
        if gestureReconizer.state == UIGestureRecognizerState.ended {
            let curPoint:CGPoint = gestureReconizer.location(in: self.planPPTableV)
            if let indexPath = self.planPPTableV!.indexPathForRow(at: curPoint) {
                let curCell = self.planPPTableV!.cellForRow(at: indexPath) as! tripPlan_cell
                if (self.debug == 1) {
                    print("indexPath=\(indexPath)")
                    print("curCell name=\(String(describing: curCell.titleLabel.text))")
                }
                //let nameArray = tripplanlistsVC.getplanlistname()
                if indexPath.section == 0 {
                    Day_toOther(point: curPoint, select: dayList[indexPath.row])
                } else if indexPath.section == 1 {
                    undef_move_toDay(point: curPoint, select: undefList[indexPath.row])
                }
                
                //let pp = infoList[indexPath.row]
            } else {
                if (self.debug == 1) {
                    print("not find cell for current long press point")
                }
            }
        }
    }
    
    // remove id - removeIndex
    // daysitem
    // selDay //current select
    func resortDayTtile() {
        let lastIndex = daysitem.count - 1
        if removeIndex != -1 {
            if removeIndex <= (lastIndex - 1){
                for i in removeIndex ... (lastIndex - 1) {
                    moveallOfDay(from : daysitem[i + 1], to: daysitem[i])
                }
            }
            if removeIndex == daysitem.count - 1 {
                selDay = daysitem[removeIndex - 1]
                //daysitem.remove(at: removeIndex)
            } else {
                selDay = daysitem[removeIndex]
            }
            daysitem.remove(at: daysitem.count - 1)
        }
    }
    
    func moveallOfDay(from : String, to : String) {
        let l_db = TPLSDBAccess()
        let plan = l_db.searchByName(name: planname!)
        //let pp :TripplanViewController.ppModel?
        var jsonString: String?
        let jsonEncoder = JSONEncoder()
        let id_str = "\(plan!.value(forKey : "id") as! Int)"
        let content = plan!.value(forKey: "contentJsonFormat") as! String
        do {
            if !content.isEmpty {
                print("TripplanViewController : moveallOfDay : ")

                let jsondata = content.data(using: .utf8)
                let decoder = JSONDecoder()
                var de_json = try decoder.decode(TripplanViewController.contentStruct?.self, from: jsondata!)
                var index = 0
                de_json!.content[from]?.forEach({ (ppMod) in
                    if de_json!.content[to] == nil {
                        de_json!.content.updateValue([ppMod], forKey: to)
                    } else {
                        var same = false
                        de_json!.content[to]?.forEach({ toPP in
                            if toPP.name == ppMod.name {
                                same = true
                            }
                        })
                        if same == false {
                            de_json!.content[to]!.append(ppMod)
                        }
                    }
                    index += 1
                })
                //print("SelectListSelectOpt : move : new fromlist : \(fromlist)")
                //print("de_json!.content[to] : \(de_json!.content[to])")
                de_json!.content.removeValue(forKey: from)
                
                
                
                let jsonData = try jsonEncoder.encode(de_json)
                jsonString = String(data: jsonData, encoding: .utf8)!
            }
            if jsonString!.isEmpty { return }
            if l_db.updateContent(id: id_str, name: planname!, contentJsonFormat: jsonString!) {
                if self.debug == 1 {
                    print("TripplanViewController : moveallOfDay - Successful")
                }
            } else {
                if self.debug == 1 {
                    print("TripplanViewController : moveallOfDay - Failure")
                }
            }
        }
        catch {
            //if self.debug == 1 {
                print("TripplanViewController : moveallOfDay - Failure")
            //}
        }
        planPPTableV!.reloadData()
    }
    
    func delPP(ppObj: NSManagedObject, day : String) {
        let l_db = TPLSDBAccess()
        let pp = TripplanViewController.ppModel(id: ppObj.value(forKey: "id") as! Int,
        name: ppObj.value(forKey: "pp_name") as! String,
        phone: ppObj.value(forKey: "pp_phone") as! String,
        country: ppObj.value(forKey: "pp_country") as! String,
        addr: ppObj.value(forKey: "pp_address") as! String,
        fb: ppObj.value(forKey: "pp_fb") as! String,
        web: ppObj.value(forKey: "pp_web") as! String,
        blogInfo: ppObj.value(forKey: "blogger_intro") as! String,
        opentime: ppObj.value(forKey: "pp_opentime") as! String,
        tag_note: ppObj.value(forKey: "pp_note") as! String,
        descrip: ppObj.value(forKey: "pp_descrip") as! String,
        distance: 0)
        let plan = l_db.searchByName(name: planname!)
        var jsonString: String?
        let jsonEncoder = JSONEncoder()
        let id_str = "\(plan!.value(forKey : "id") as! Int)"
        let content = plan!.value(forKey: "contentJsonFormat") as! String
        
        do {
            if !content.isEmpty {
                print("TripplanViewController : move : ")
                let jsondata = content.data(using: .utf8)
                let decoder = JSONDecoder()
                var de_json = try decoder.decode(TripplanViewController.contentStruct?.self, from: jsondata!)
                var index = 0
                de_json!.content[day]?.forEach({ (ppMod) in
                    if ppMod.name == pp.name {
                        de_json!.content[day]!.remove(at: index)
                    }
                    index += 1
                })

                let jsonData = try jsonEncoder.encode(de_json)
                jsonString = String(data: jsonData, encoding: .utf8)!
            }
            if jsonString!.isEmpty { return }
            if l_db.updateContent(id: id_str, name: planname!, contentJsonFormat: jsonString!) {
                if self.debug == 1 {
                    print("TripplanViewController : delPP - Successful")
                }
            } else {
                if self.debug == 1 {
                    print("TripplanViewController : delPP - Failure")
                }
            }
        }
        catch {
            if self.debug == 1 {
                print("TripplanViewController : addPP - Failure")
            }
        }
        planPPTableV!.reloadData()
    }
    
    func move(from : String, to : String, ppObj: NSManagedObject) {
        let l_db = TPLSDBAccess()
        let plan = l_db.searchByName(name: planname!)
        let pp = TripplanViewController.ppModel(id: ppObj.value(forKey: "id") as! Int,
                name: ppObj.value(forKey: "pp_name") as! String,
                phone: ppObj.value(forKey: "pp_phone") as! String,
                country: ppObj.value(forKey: "pp_country") as! String,
                addr: ppObj.value(forKey: "pp_address") as! String,
                fb: ppObj.value(forKey: "pp_fb") as! String,
                web: ppObj.value(forKey: "pp_web") as! String,
                blogInfo: ppObj.value(forKey: "blogger_intro") as! String,
                opentime: ppObj.value(forKey: "pp_opentime") as! String,
                tag_note: ppObj.value(forKey: "pp_note") as! String,
                descrip: ppObj.value(forKey: "pp_descrip") as! String,
                distance: 0)
        var jsonString: String?
        let jsonEncoder = JSONEncoder()
        let id_str = "\(plan!.value(forKey : "id") as! Int)"
        let content = plan!.value(forKey: "contentJsonFormat") as! String
        do {
            if !content.isEmpty {
                print("TripplanViewController : move : ")
                var fromlist: [TripplanViewController.ppModel] = []
                let jsondata = content.data(using: .utf8)
                let decoder = JSONDecoder()
                var de_json = try decoder.decode(TripplanViewController.contentStruct?.self, from: jsondata!)
                var index = 0
                de_json!.content[from]?.forEach({ (ppMod) in
                    if ppMod.name == pp.name {
                        if de_json!.content[to] == nil {
                            de_json!.content.updateValue([pp], forKey: to)
                        } else {
                            var same = false
                            de_json!.content[to]?.forEach({ toPP in
                                if toPP.name == pp.name {
                                    same = true
                                }
                                
                            })
                            if same == false {
                                de_json!.content[to]!.append(pp)
                            }
                        }
                    } else {
                        fromlist.append(ppMod)
                    }
                    index += 1
                })

                de_json!.content.updateValue(fromlist, forKey: from)
                let jsonData = try jsonEncoder.encode(de_json)
                jsonString = String(data: jsonData, encoding: .utf8)!
            }
            if jsonString!.isEmpty { return }
            if l_db.updateContent(id: id_str, name: planname!, contentJsonFormat: jsonString!) {
                if self.debug == 1 {
                    print("TripplanViewController : addPP - Successful")
                }
            } else {
                if self.debug == 1 {
                    print("TripplanViewController : addPP - Failure")
                }
            }
        }
        catch {
            if self.debug == 1 {
                print("TripplanViewController : addPP - Failure")
            }
        }
        planPPTableV!.reloadData()
    }
    
    @objc func Day_toOther(point: CGPoint, select : NSManagedObject) {
        var items = [String]()
        let alertController = UIAlertController(title: "請選擇", message: "存入哪一個計畫中？", preferredStyle: .actionSheet)
        items = daysitem
        //items!.append(contentsOf: daysitem)
        items.insert("UNDEF", at: items.count)//append("UNDEF")
        let selOpt = SelectListSelectOpt()
        selOpt.setView(vc: self)
        selOpt.setData(list: items)
        selOpt.setPP(selPP: select)
        selOpt.setCurr(curr: selDay!)
        selOpt.setPlanname(name: planname!)
        alertController.setValue(selOpt, forKey: "contentViewController")
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        alertController.addAction(cancelAction)
        if alertController.popoverPresentationController != nil {
            //popoverPresentationController!.barButtonItem = sender
            alertController.popoverPresentationController!.sourceView = self.view
            alertController.popoverPresentationController!.sourceRect = CGRect(x: point.x, y: point.y + 148.0, width: 1.0, height: 1.0)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func undef_move_toDay(point : CGPoint, select : NSManagedObject) {
        let alertController = UIAlertController(title: "請選擇", message: "存入哪一個計畫中？", preferredStyle: .actionSheet)

        let selOpt = SelectListSelectOpt()
        selOpt.setView(vc: self)
        selOpt.setData(list: daysitem)
        selOpt.setPP(selPP: select)
        selOpt.setCurr(curr: "UNDEF")
        selOpt.setPlanname(name: planname!)
        alertController.setValue(selOpt, forKey: "contentViewController")
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        alertController.addAction(cancelAction)
        if alertController.popoverPresentationController != nil {
            //popoverPresentationController!.barButtonItem = sender
            alertController.popoverPresentationController!.sourceView = self.view
            alertController.popoverPresentationController!.sourceRect = CGRect(x: point.x, y: point.y + 148.0, width: 1.0, height: 1.0)
        }
        self.present(alertController, animated: true, completion: nil)
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
        if self.debug == 1 {
            print("TripPlanListsViewController: adView:didFailToReceiveAdWithError : \(error)")
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

class tripPlan_cell: UITableViewCell {
    static let reuseID = "tripPlan_cell"
    var titleLabel:UILabel!
    var detailLabel:UILabel!
    var navButton: UIButton!
    var callButton: UIButton!
    //var delPPButton: UIButton!
    let ButtonWidth:Int = 30
    let ButtonHight:Int = 30
    let startX = 20
    let startY = 10
    var OffsetY = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        let w = Int(UIScreen.main.bounds.size.width)
        titleLabel = UILabel(frame:CGRect(x: startX, y: startY, width:  Int(w - startX*2), height: ButtonHight))
        titleLabel.font = UIFont(name: "Helvetica-Light", size: 20)
        //titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        self.addSubview(titleLabel)
        OffsetY += (ButtonHight + startY)
        
        detailLabel = UILabel(frame:CGRect(x: startX, y: OffsetY, width:  Int(w - startX*2), height: ButtonHight))
        detailLabel.font = UIFont(name: "Helvetica-Light", size: 14)
        //detailLabel.textAlignment = .center
        detailLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        detailLabel.numberOfLines = 0
        detailLabel.textColor = UIColor.black
        self.addSubview(detailLabel)
        OffsetY += ButtonHight
        
        navButton = UIButton(frame: CGRect(x: Int(w / 6 * 5), y: Int(OffsetY),
                                           width: Int(ButtonWidth), height: Int(ButtonHight)))
        navButton.setImage(UIImage(named: "iconfinder_navigation.png"), for: .normal)
        navButton.setTitleColor(UIColor.black, for: .normal)
        navButton.backgroundColor = UIColor.clear

        navButton.isEnabled = true
        self.addSubview(navButton)
        
        
        callButton = UIButton(frame: CGRect(x: Int(w / 6 * 4), y: Int(OffsetY + 4),
                                            width: Int(ButtonWidth - 8), height: Int(ButtonHight - 8)))
        callButton.setImage(UIImage(named: "call@x3.png"), for: .normal)
        callButton.setTitleColor(UIColor.black, for: .normal)
        callButton.backgroundColor = UIColor.clear

        callButton.isEnabled = true
        self.addSubview(callButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class SelectListSelectOpt : UITableViewController{
    var parentVC : TripplanViewController?
    var cells = [String]()
    var currSeat : String?
    var planname : String?
    var ppObj: NSManagedObject? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.separatorStyle = .singleLineEtched
        self.tableView.allowsSelection = true
        self.tableView.register(SelectListSelectOptCell.self, forCellReuseIdentifier: SelectListSelectOptCell.reuseID)
    }
    
    func setView(vc : TripplanViewController) {
        parentVC = vc
    }
    
    func setPlanname(name : String) {
        planname = name
    }
    
    func setPP(selPP : NSManagedObject) {
        ppObj = selPP
    }
    
    func setCurr(curr: String) {
        currSeat = curr
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
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectListSelectOptCell.reuseID, for: indexPath) as! SelectListSelectOptCell
        cell.textLabel!.text = cells[indexPath.row]
        cell.textLabel!.backgroundColor = UIColor.clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
        if (ppObj != nil) {
            parentVC!.move(from: currSeat!, to: cells[indexPath.row], ppObj: ppObj!)
            parentVC!.undefListLoad()
            
            if cells[indexPath.row] != "UNDEF" {
                parentVC!.selDay = cells[indexPath.row]
                parentVC!.dayListLoad(day: cells[indexPath.row])
            } else {
                parentVC!.selDay = currSeat
                parentVC!.dayListLoad(day: currSeat!)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // 有幾組 section
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

private class SelectListSelectOptCell: UITableViewCell {
    
    static let reuseID = "SelectListSelectOptCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

