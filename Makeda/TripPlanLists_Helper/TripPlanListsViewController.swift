//
//  TripPlanListsViewController.swift
//  Makeda
//
//  Created by Brian on 2019/11/14.
//  Copyright © 2019 breadcrumbs.tw. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import GoogleMobileAds

class TripPlanListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    let debug = 0
    let fullScreenSize = UIScreen.main.bounds.size
    var addPlanButton : UIButton?
    var tripplanliststv : UITableView?
    var addPlanAlert: UIAlertController?
    var bannerView: GADBannerView!
    var planTableV: UITableView?
    var db : TPLSDBAccess?
    var alertShortMessage : UIAlertController?
    var planList: [NSManagedObject] = []
    let StartY = 50
    let StartX = 10
    var offsetY = 0
    let ButtonWidth = 30
    let ButtonHight = 30
    let goBackButtonID = 1001

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        db = TPLSDBAccess()
        loadGoogleBannerAD()
        let offY = StartY + ButtonHight
        tripplanliststv = UITableView(frame: CGRect(
            x: 0, y: offY,
            width: Int(fullScreenSize.width),
            height: Int(fullScreenSize.height) - offY
        ), style: .grouped)
        tripplanliststv!.register(
            viewcell.self, forCellReuseIdentifier: viewcell.reuseID)
        tripplanliststv!.delegate = self
        tripplanliststv!.dataSource = self
        tripplanliststv!.separatorStyle = .singleLine
        tripplanliststv!.allowsSelection = true
        tripplanliststv!.allowsMultipleSelection = false
        self.view.addSubview(tripplanliststv!)
        buttonLayerInit()
        tableViewLoad()
        renew_planlist()
    }
    
    func buttonLayerInit() {
        let offX = Int(fullScreenSize.width) - ButtonWidth - StartX
        addPlanButton = UIButton(
            frame: CGRect(x: offX, y: StartY, width: ButtonWidth, height: ButtonHight))
        addPlanButton!.setImage(UIImage(named: "plus@x3.png"), for: .normal)
        addPlanButton!.isEnabled = true
        addPlanButton!.addTarget(
            self,
            action: #selector(add_plan),
            for: .touchUpInside)
        self.view.addSubview(addPlanButton!)
        
        let backButton = UIButton(
            frame: CGRect(x: StartX, y: StartY, width: ButtonWidth, height: ButtonHight + 3))
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
        offsetY = StartY + ButtonHight + 3
    }
    
    func tableViewLoad() {
        //let tabbarHight = Int((self.tabBarController?.tabBar.frame.size.height)!)
        let adsHight = Int(self.bannerView.frame.size.height)
        let buttonlayerH = offsetY
        let tabView_h = Int(fullScreenSize.height) - adsHight - buttonlayerH//tagsButtonHigh
        planTableV = UITableView(frame: CGRect(
            x: 0, y: Int(buttonlayerH),
            width: Int(fullScreenSize.width),
            height: tabView_h
            ), style: .grouped)
        planTableV!.register(
            viewcell.self, forCellReuseIdentifier: viewcell.reuseID)
        planTableV!.delegate = self // as! UITableViewDelegate
        planTableV!.dataSource = self // as! UITableViewDataSource
        planTableV!.separatorStyle = .singleLine
        planTableV!.allowsSelection = true
        planTableV!.allowsMultipleSelection = false
        self.view.addSubview(planTableV!)
    }
    
    func renew_planlist() {
        if let all = db!.getAll() {
            planList = all
        }
        planTableV!.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (planList.count == 0)
        {
            return 0
        }
        return planList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 取得 tableView 目前使用的 cell
        let cell = tableView.dequeueReusableCell(withIdentifier: viewcell.reuseID, for: indexPath) as UITableViewCell
        cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.detailTextLabel?.numberOfLines = 0

        if planList.count > 0
        {
            if let name = planList[indexPath.row].value(forKey: "planname")
            {
                cell.textLabel?.text = name as? String
                var detailStr : String = "計畫中的旅程: 國家 - "
                let cities = TripplanViewController().getPlanCities(name: name as! String)
                let countries = TripplanViewController().getPlanCountries(name: name as! String)
                countries.forEach { (country) in
                    detailStr = detailStr + country
                }
                detailStr = detailStr + "城市 - "
                cities.forEach { (city) in
                    detailStr = detailStr + city
                }
                cell.detailTextLabel?.text = detailStr
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath)
        -> [UITableViewRowAction]?
    {
        var actionArr:Array<UITableViewRowAction> = [UITableViewRowAction]()
        // 建立刪除按鈕
        let actionDelete =
            UITableViewRowAction(style: UITableViewRowActionStyle.default,
                                 title: "刪除")
            {
                (action, indexPath) in
                if let id = self.planList[indexPath.row].value(forKey: "id") ,
                    let planname = self.planList[indexPath.row].value(forKey: "planname") {
                    if ((self.db?.delete(id: "\(id)", planname: "\(planname)"))!)
                    {
                        self.planList.remove(at: indexPath.row)//removeAt(indexPath.row)
                        self.addAlertMessage(Title: "刪除成功", msgStr: "計畫刪除成功")
                        self.closeAlertMessage()
                        self.renew_planlist()
                    } else {
                        self.addAlertMessage(Title: "刪除失敗", msgStr: "計畫刪除失敗")
                        self.closeAlertMessage()
                    }
                }
            }
        actionDelete.backgroundColor =  UIColor.red
        actionArr.append(actionDelete)
        return actionArr
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // open plan detail..
        if let planname = self.planList[indexPath.row].value(forKey: "planname") {
            let tripplan = TripplanViewController()
            tripplan.setPlanname(name: planname as! String)
            tripplan.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.present(tripplan, animated: true, completion: nil)
        }
    }
    
    // 有幾組 section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func getplanlistname() -> [String] {
        var ret = [String]()
        let l_db = TPLSDBAccess()
        let all = l_db.getAll()
        for it in all!
        {
            if let name = it.value(forKey: "planname")
            {
                ret.append(name as! String)
            }
        }
        return ret
    }
    
    func addPP(ppList: NSManagedObject, planname : String) {
        var jsonString : String?
        let l_db = TPLSDBAccess()
        let plan = l_db.searchByName(name: planname)
        let pp = TripplanViewController.ppModel(id: ppList.value(forKey: "id") as! Int,
                name: ppList.value(forKey: "pp_name") as! String,
                phone: ppList.value(forKey: "pp_phone") as! String,
                country: ppList.value(forKey: "pp_country") as! String,
                addr: ppList.value(forKey: "pp_address") as! String,
                fb: ppList.value(forKey: "pp_fb") as! String,
                web: ppList.value(forKey: "pp_web") as! String,
                blogInfo: ppList.value(forKey: "blogger_intro") as! String,
                opentime: ppList.value(forKey: "pp_opentime") as! String,
                tag_note: ppList.value(forKey: "pp_note") as! String,
                descrip: ppList.value(forKey: "pp_descrip") as! String,
                distance: 0)
        print("TripPlanListsViewController : addPP : pp : \(pp)")
        let jsonEncoder = JSONEncoder()
        let id_str = "\(plan!.value(forKey : "id") as! Int)"
        let content = plan!.value(forKey: "contentJsonFormat") as! String
        do {
            if content.isEmpty {
                var contentJson = TripplanViewController.contentStruct()
                contentJson.content = ["UNDEF":[pp],"DAY1":[]]// = pp//["UNDEF"][0] = pp
                let jsonData = try jsonEncoder.encode(contentJson)
                jsonString = String(data: jsonData, encoding: .utf8)!
                print("JSON String : " + jsonString!)
            } else {
                print("TripPlanListsViewController : addPP : ")
                let jsondata = content.data(using: .utf8)
                let decoder = JSONDecoder()
                var de_json = try decoder.decode(TripplanViewController.contentStruct?.self, from: jsondata!)
                if de_json!.content["UNDEF"] != nil {
                    de_json!.content["UNDEF"]?.append(pp)
                    print(" +  1. \(String(describing: de_json?.content["UNDEF"]!))")
                } else {
                    de_json!.content.updateValue([], forKey: "UNDEF")//[dayStr:[]]// = pp//["UNDEF"][0] = pp
                }
                let jsonData = try jsonEncoder.encode(de_json)
                jsonString = String(data: jsonData, encoding: .utf8)!
                print("JSON String : " + jsonString!)
            }
            if l_db.updateContent(id: id_str, name: planname, contentJsonFormat: jsonString) {
                if self.debug == 1 {
                    print("TripPlanListsViewController : addPP - Successful")
                }
            } else {
                if self.debug == 1 {
                    print("TripPlanListsViewController : addPP - Failure")
                }
            }
        }
        catch {
            if self.debug == 1 {
                print("TripPlanListsViewController : addPP - Failure")
            }
        }
    }
    
    @objc func add_plan () {
        self.addPlanAlert = UIAlertController(
            title: "建立旅遊計畫",
            message: "旅遊計畫名稱",
            preferredStyle: .alert)
        //create value change
        self.addPlanAlert!.addTextField { (textfield: UITextField) in
            textfield.font = UIFont(name: "Helvetica-Light", size: 16)
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
                let myUserDefaults = UserDefaults.standard
                if let email = myUserDefaults.value(forKey: "user_email") as? String
                {
                    let planname = self.addPlanAlert!.textFields![0].text!
                    let id = self.db?.insert(planname: planname, author: email, grouplist: "", contentJsonFormat: "", log: "")
                    if (id! > 0) {
                        self.addAlertMessage(Title: "新增成功", msgStr: "計畫新增成功")
                        self.closeAlertMessage()
                        self.renew_planlist()
                    } else {
                        self.addAlertMessage(Title: "新增失敗", msgStr: "計畫新增失敗")
                        self.closeAlertMessage()
                    }
                } else {
                    self.addAlertMessage(Title: "請先登入", msgStr: "請先登入會員唷！")
                    self.closeAlertMessage()
                }
        })
        
        let cancel = UIAlertAction(title: "取消", style: .destructive, handler: { (action) -> Void in })
        
        //self.editeValueCtrl!.view.addSubview(cusTextView)
        self.addPlanAlert!.addAction(cancel)
        self.addPlanAlert!.addAction(sendAction)
        
        // 顯示提示框
        self.present(self.addPlanAlert!, animated: true, completion: nil)
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion:nil)
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
            completion: nil)
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

private class viewcell: UITableViewCell {
    
    static let reuseID = "tripPlanLists_cell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
