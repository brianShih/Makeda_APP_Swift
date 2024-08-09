//
//  NotifViewController.swift
//  Makeda
//
//  Created by Brian on 2018/8/31.
//  Copyright © 2018年 breadcrumbs.tw. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Contacts
import CoreLocation
import GoogleMobileAds
import UserNotifications

class NotifViewController: UIViewController, CLLocationManagerDelegate,
                            UITextFieldDelegate, UIScrollViewDelegate,
                            UITableViewDelegate, UITableViewDataSource,
                            GADBannerViewDelegate {
    let debug = 0
    var bannerView: GADBannerView!
    //var locSwitch = 1
    var myLocationManager :CLLocationManager!
    var myMapView :MKMapView!
    let fullSize = UIScreen.main.bounds.size
    var myScrollView: UIScrollView!
    var myTableView:UITableView!
    var currCountry :String?
    var currCity :String?
    var currTown :String?
    var currLocate : String?
    var currStreet : String?
    var updatedCity :String?
    let msgItemsCount = 2
    var loc_Inited = 0
    var backsideWorking = 0

    override func viewWillAppear(_ animated: Bool) {
        self.myTableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        LocationInit()
        loadGoogleBannerAD()
        scrollViewLoad()
        tabViewLoad()
    }
    
    func LocationInit()
    {
        // Do any additional setup after loading the view, typically from a nib.
        // 建立一個 CLLocationManager
        if (loc_Inited == 0)
        {
            if (debug == 1)
            {
                print("NotifViewControl : First time Init GPS...")
            }
        }
        else
        {
            return
        }
        loc_Inited = 1
        myLocationManager = CLLocationManager()
        /* locSwitch
        let myUserDefaults = UserDefaults.standard
        if let GPSSwitchFunc = myUserDefaults.object(forKey: "gpsBackgroundFunc") {
            locSwitch = GPSSwitchFunc as! Int
        }
        else
        {
            myUserDefaults.set(locSwitch, forKey: "gpsBackgroundFunc")
        }
        
        myUserDefaults.synchronize()
        */
        // 設置委任對象
        myLocationManager.delegate = self
        
        // 距離篩選器 用來設置移動多遠距離才觸發委任方法更新位置
        myLocationManager.distanceFilter =
        kCLLocationAccuracyKilometer
        
        // 取得自身定位位置的精確度
        myLocationManager.desiredAccuracy =
        kCLLocationAccuracyBest
        // 開啟背景更新(預設為 false)
        myLocationManager.allowsBackgroundLocationUpdates = false//(locSwitch == 1)
        // 不間斷的在背景更新(預設為 true)
        myLocationManager.pausesLocationUpdatesAutomatically = true//(locSwitch == 0)
        // 詢問使用者是否在背景也可取用其位置的隱私
        myLocationManager.requestAlwaysAuthorization()

        // 首次使用 向使用者詢問定位自身位置權限
        if CLLocationManager.authorizationStatus()
            == .notDetermined {
            // 取得定位服務授權
            myLocationManager.requestWhenInUseAuthorization()
            
            // 開始定位自身位置
            myLocationManager.startUpdatingLocation()
        }
            // 使用者已經拒絕定位自身位置權限
        else if CLLocationManager.authorizationStatus()
            == .denied {
            // 提示可至[設定]中開啟權限
            let alertController = UIAlertController(
                title: "定位權限已關閉",
                message:
                "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
                preferredStyle: .alert)
            let okAction = UIAlertAction(
                title: "確認", style: .default, handler:nil)
            alertController.addAction(okAction)
            self.present(
                alertController,
                animated: true, completion: nil)
        }
            // 使用者已經同意定位自身位置權限
        else if CLLocationManager.authorizationStatus()
            == .authorizedWhenInUse {
            // 開始定位自身位置
            myLocationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 停止定位自身位置
        //myLocationManager.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        var reload = false
        // 印出目前所在位置座標
        let currentLocation :CLLocation =
            locations[0] as CLLocation
        if debug == 1 {
            print("\(currentLocation.coordinate.latitude)")
            print(", \(currentLocation.coordinate.longitude)")
        }
        
        currLocate = "\(String(format: "%.6f", currentLocation.coordinate.latitude)) \(String(format: "%.6f", currentLocation.coordinate.longitude))"
        let geocoder = CLGeocoder()
        let realLocation = CLLocation(latitude: currentLocation.coordinate.latitude,
                                         longitude: currentLocation.coordinate.longitude)
        geocoder.reverseGeocodeLocation(realLocation, completionHandler: {
            (placemarks:[CLPlacemark]?, error:Error?) -> Void in
            //强制转成中文
            let array = NSArray(object: "zh-TW")
            UserDefaults.standard.set(array, forKey: "AppleLanguages")
            //显示所有信息
            if error != nil {
                if self.debug == 1 {
                    print("錯誤：\(error!.localizedDescription))")
                }
                //self.textView.text = "错误：\(error!.localizedDescription))"
                return
            }
            
            if let placemark = placemarks?[0] {
                var address = ""
                if placemark.subThoroughfare != nil {
                    address += placemark.subThoroughfare! + " "
                }
                if placemark.thoroughfare != nil {
                    address += placemark.thoroughfare! + "\n"
                    self.currStreet = placemark.thoroughfare!
                }
                if placemark.subLocality != nil {
                    address += placemark.subLocality! + "\n"
                }
                
                if placemark.administrativeArea != nil && placemark.administrativeArea != placemark.country
                {
                    address += placemark.administrativeArea! + "\n"
                    if self.currCity != placemark.administrativeArea!
                    {
                        reload = true
                    }
                    self.currCity = placemark.administrativeArea!
                }
                else if placemark.subAdministrativeArea != nil
                {
                    if self.currCity != placemark.subAdministrativeArea!
                    {
                        reload = true
                    }
                    self.currCity = placemark.subAdministrativeArea!
                }
                if placemark.addressDictionary!["State"] != nil
                {
                    _ = placemark.addressDictionary!["State"]!
                }
                if placemark.addressDictionary!["City"] != nil && placemark.isoCountryCode == "JP"
                {
                    let city = placemark.addressDictionary!["City"] as! String
                    if self.currTown != city
                    {
                        reload = true
                    }
                    self.currTown = city
                }
                if placemark.subLocality != nil  && placemark.isoCountryCode != "JP"
                {
                    if self.currTown != placemark.subLocality!
                    {
                        reload = true
                    }
                    self.currTown = placemark.subLocality!
                }
                else if placemark.locality != nil && placemark.isoCountryCode != "JP"
                {
                    if self.currTown != placemark.locality!
                    {
                        reload = true
                    }
                    self.currTown = placemark.locality!
                }

                if placemark.postalCode != nil {
                    address += placemark.postalCode! + "\n"
                }
                if placemark.country != nil {
                    address += placemark.country!
                    if self.currCountry != placemark.country! && self.currCountry != nil
                    {
                        reload = true
                    }
                    self.currCountry = placemark.country!
                }
                //self.address.text = String(address)
                if self.debug == 1 {
                    print("address: ", address)
                    print("placemark.addressDictionary ", placemark.addressDictionary as Any )
                }
            }
            if reload && (self.myTableView != nil)
            {
                self.myTableView.reloadData()
            }
        })
    }
    
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
        myScrollView.isScrollEnabled = false
        
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
    
    //tabview
    func tabViewLoad()
    {
        myTableView = UITableView(frame: CGRect(
            x: 0, y: 50,
            width: fullSize.width,
            height: fullSize.height - 30),
                                  style: .grouped)
        // init infoList ... TODO
        
        // 註冊 cell
        myTableView.register(
            UITableViewCell.self, forCellReuseIdentifier: "msgCell")
        
        // 設置委任對象
        myTableView.delegate = self // as! UITableViewDelegate
        myTableView.dataSource = self // as! UITableViewDataSource
        
        // 分隔線的樣式
        myTableView.separatorStyle = .singleLine
        
        // 分隔線的間距 四個數值分別代表 上、左、下、右 的間距
        myTableView.separatorInset =
            UIEdgeInsetsMake(0, 20, 0, 20)
        
        // 是否可以點選 cell
        myTableView.allowsSelection = true
        
        // 是否可以多選 cell
        myTableView.allowsMultipleSelection = false
        
        // 加入到畫面中
        myScrollView.addSubview(myTableView)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currCity == nil || currCountry == nil
        {
            return 1
        }
        else
        {
            return msgItemsCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 取得 tableView 目前使用的 cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "msgCell", for: indexPath) as UITableViewCell
        
        // 顯示的內容
        if let myLabel = cell.textLabel {
            if (indexPath.row == 0)
            {
                if currCountry == nil || currCity == nil
                {
                    myLabel.text = "正在取得您的所在位置"
                }
                else
                {
                    myLabel.text = "所在位置：\(currCountry!) | \(currCity!) | \(currTown!)"
                }
            }
            else if (indexPath.row == 1)
            {
                let db:DB_Access = DB_Access()
                if currCity == nil
                {

                }
                else if let pp_caches = db.pp_searchByCity(city: currCity!)
                {
                    myLabel.text = "有 \(pp_caches.count) 個你私房景點"
                }
                else
                {
                    myLabel.text = "有 \(0) 個你私房景點"
                }
            }
        }
        
        return cell
    }
    
    // 點選 cell 後執行的動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
        if debug == 1 {
            print("按下的是 \(indexPath.row)")
        }
        
        if indexPath.row == 1
        {
            if currCountry != nil && currCity != nil
            {
                if let dashViewController = self.tabBarController?.viewControllers?[2] as? DashViewController{
                    dashViewController.cleanAllCacheDB()
                    DashViewController.country = self.currCountry!
                    DashViewController.city = self.currCity!
                    if debug == 1 {
                        print("\(DashViewController.country),\(DashViewController.city)")
                    }
                    dashViewController.set_AreaNCountry(country_in: currCountry!,city_in: self.currCity!)
                    dashViewController.CountryNCity = "\(DashViewController.country)   |   \(DashViewController.city)"
                    dashViewController.dashTextField!.text = dashViewController.CountryNCity
                    dashViewController.ppList_updated = 1
                    dashViewController.Reload_ppList()
                    self.tabBarController?.selectedIndex = 2
                }
            }
        }
    }
    
    // 點選 Accessory 按鈕後執行的動作
    // 必須設置 cell 的 accessoryType
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if debug == 1 {
            print("按下的是 - 不可能出現才對")
        }
        // TODO - Create new View and detail info
    }
    
    // 有幾組 section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 每個 section 的標題
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "最新訊息"
    }
    
    func getCurrCountry() -> String? {
        return self.currCountry
    }
    
    func getCurrTown() -> String? {
        return self.currTown
    }
    
    func getCurrCity() -> String? {
        return self.currCity
    }
    
    func getStreet() -> String? {
        return self.currStreet
    }
    
    func getLatLong() -> String? {
        return self.currLocate
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
            print("NotifVC: adView:didFailToReceiveAdWithError : \(error)")
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
