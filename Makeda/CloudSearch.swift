//
//  CloudSearch.swift
//  Makeda
//
//  Created by Brian on 2019/8/17.
//  Copyright © 2019 breadcrumbs.tw. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class CloudSearch: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let debug = 0
    let URL_PP_HELPER = "TODO"
    let fullScreenSize = UIScreen.main.bounds.size
    let StartY = 50
    let StartX = 10
    let BtnHeight = 30
    let searchTextfieldHeight = 30
    let goBackButtonID = 1001
    let SearchTextFieldID = 1002
    let searchButtonID = 1003
    var searchTextfield : UITextField?
    var searchVC_ScrollView : UIScrollView?
    var search_TableView : UITableView?
    var infoList: [NSManagedObject] = []
    var userLogin = 0
    var db:DB_Access!
    var alertShortMessage : UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = DB_Access()
        db.db_init()
        goBackBtn()
        searchTextLoad()
        searchButtonLoad()
        scrollViewLoad()
        tabViewLoad()
        
        // 增加一個觸控事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(tapG:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        self.view.backgroundColor = UIColor.white
    }
    
    func goBackBtn() {
        let backButton = UIButton(
            frame: CGRect(x: StartX, y: StartY, width: 30, height: BtnHeight))
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
    }
    
    func searchTextLoad() {
        let ySeat = StartY + BtnHeight
        let widthSize = Int(fullScreenSize.width) - 30 - 20
        searchTextfield = UITextField(frame: CGRect(x: StartX, y: ySeat, width: widthSize, height: searchTextfieldHeight))
        searchTextfield!.placeholder = " 輸入搜尋關鍵字 "
        searchTextfield!.borderStyle = .roundedRect
        searchTextfield!.clearButtonMode = .whileEditing
        searchTextfield!.keyboardType = .default
        searchTextfield!.returnKeyType =  UIReturnKeyType.continue
        searchTextfield!.textColor = UIColor.gray
        
        searchTextfield!.tag = SearchTextFieldID
        //searchTextfield!.delegate = self
        searchTextfield!.backgroundColor = UIColor.clear
        
        self.view.addSubview(searchTextfield!)
    }
    
    func searchButtonLoad() {
        let ySeat = StartY + BtnHeight
        let xSeat = Int(fullScreenSize.width) - 25 - 10
        let searchButton = UIButton(
            frame: CGRect(x: xSeat, y: ySeat, width: 25, height: 25))
        searchButton.setImage(UIImage(named: "search@x3.png"), for: .normal)
        searchButton.tag = searchButtonID
        searchButton.isEnabled = true
        searchButton.addTarget(
            self,
            action: #selector(self.searchAction),
            for: .touchUpInside)
        
        self.view.addSubview(searchButton)
    }
    
    func scrollViewLoad()
    {
        let ySeat = StartY + BtnHeight + 35
        searchVC_ScrollView = UIScrollView()
        
        // 設置尺寸 也就是可見視圖範圍
        searchVC_ScrollView!.frame = CGRect(x: 0, y: ySeat, width: Int(fullScreenSize.width), height: Int(fullScreenSize.height) - ySeat)
        
        // 實際視圖範圍 為 3*2 個螢幕大小
        searchVC_ScrollView!.contentSize = CGSize(width: fullScreenSize.width, height: fullScreenSize.height * 2)
        
        // 是否顯示水平的滑動條
        searchVC_ScrollView!.showsHorizontalScrollIndicator = false
        
        // 是否顯示垂直的滑動條
        searchVC_ScrollView!.showsVerticalScrollIndicator = false
        
        // 滑動條的樣式
        searchVC_ScrollView!.indicatorStyle = .black
        
        // 是否可以滑動
        searchVC_ScrollView!.isScrollEnabled = false
        
        // 是否可以按狀態列回到最上方
        searchVC_ScrollView!.scrollsToTop = false
        
        // 限制滑動時只能單個方向 垂直或水平滑動
        searchVC_ScrollView!.isDirectionalLockEnabled = false
        
        // 滑動超過範圍時是否使用彈回效果
        searchVC_ScrollView!.bounces = true
        
        // 縮放元件的預設縮放大小
        //myScrollView.zoomScale = 1.0
        
        // 縮放元件可縮小到的最小倍數
        //myScrollView.minimumZoomScale = 0.5
        
        // 縮放元件可放大到的最大倍數
        //myScrollView.maximumZoomScale = 2.0
        
        // 縮放元件縮放時是否在超過縮放倍數後使用彈回效果
        searchVC_ScrollView!.bouncesZoom = true
        
        // 設置委任對象
        searchVC_ScrollView!.delegate = self
        
        // 起始的可見視圖偏移量 預設為 (0, 0)
        // 設定這個值後 就會將原點滑動至這個點起始
        //myScrollView.contentOffset = CGPoint(x: fullSize.width * 0.5, y: fullSize.height)
        
        // 以一頁為單位滑動
        searchVC_ScrollView!.isPagingEnabled = false
        
        // 加入到畫面中
        self.view.addSubview(searchVC_ScrollView!)
    }
    
    func tabViewLoad()
    {
        let scrollViewY = StartY + BtnHeight + 35
        search_TableView = UITableView(frame: CGRect(
            x: 0, y: 0,
            width: Int(fullScreenSize.width),
            height: Int(fullScreenSize.height) - scrollViewY
        ), style: .grouped)
        search_TableView!.register(
            search_ViewCell.self, forCellReuseIdentifier: search_ViewCell.reuseID)
        search_TableView!.delegate = self
        search_TableView!.dataSource = self
        search_TableView!.separatorStyle = .singleLine
        //ppV_TableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20)
        search_TableView!.allowsSelection = true
        search_TableView!.allowsMultipleSelection = false
        searchVC_ScrollView!.addSubview(search_TableView!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (infoList.count == 0)
        {
            return 0
        }
        return infoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 取得 tableView 目前使用的 cell
        let cell = tableView.dequeueReusableCell(withIdentifier: search_ViewCell.reuseID, for: indexPath) as UITableViewCell
        
        // 顯示的內容
        cell.accessoryType = .detailDisclosureButton
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
        //print("選擇的是 \(name)")
        let ppV = PP_Viewer()
        ppV.PPdetail = pp
        ppV.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(ppV, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath)
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
                    //self.ppList_updated = 1
                    //self.Reload_ppList()
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
                            //var c_idx = 0
                            //for c in self.cloudList
                            //{
                            //    if c.value(forKey: "pp_name") as? String == pp_name
                            //    {
                            //        break
                            //    }
                            //    c_idx = c_idx + 1
                            //}
                            //self.cloudList.remove(at: c_idx)
                            //print("saveAction: Successful")
                            
                        }
                    }
                    
                    tableView.isEditing = false; // 退出編輯模式
                    tableView.reloadData()
                    //self.ppList_updated = 1
                    //self.Reload_ppList()
            }
            actionSave!.backgroundColor =  UIColor.red
        }
        // 建立刪除按鈕
        let actionCencel:UITableViewRowAction =
            UITableViewRowAction(style: UITableViewRowActionStyle.default,
                                 title: "取消")
            {
                (action, indexPath) in
                //let select:Int = indexPath.row
                //let name = "\(self.infoList[select].value(forKey: "pp_name") as! String)"
                //let id:String = "\(self.infoList[select].value(forKey: "id")!)"
                //print("cancel : ID: ",id, "NAME: ",name)
                
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
    
    // 每個 section 的標題
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "線上資料庫- 搜尋結果"
    }
    
    // 有幾組 section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion:nil)
    }
    
    @objc func searchAction() {
        let keywords = (searchTextfield!.text)
        sendCloudSearch(keywords: keywords!)
    }
    
    @objc func sendCloudSearch(keywords: String) {
        self.view.endEditing(true)
        infoList.removeAll()
        addAlertMessage(Title: "請稍候", msgStr: "麥奇兜線上資料庫搜尋中...")
        //'CMD' : 'TODO', 'keywords':u'老宅,食,麵包屑&三合院'
        let parameters: Parameters = [
            "CMD":"TODO",
            "keywords" : keywords
        ]
        closeAlertMessage()
        
        //Sending http post request
        Alamofire.request(self.URL_PP_HELPER, method: .post, parameters: parameters).responseJSON
        { response in
            var PPs_List_fromCloud:[NSDictionary] = []
            if let result = response.result.value {
                let jsonData = result as! NSDictionary
                if self.debug == 1 {
                    print("jsonData : ",jsonData)
                }
                if let status:Int = jsonData.value(forKey: "status") as? Int
                {
                    if self.debug == 1 {
                        print("Cloud feeback ： ", status)
                    }
                }
                else if let count:Int = jsonData.value(forKey: "count") as? Int
                {
                    if self.debug == 1 {
                        print("Get data from Cloud count: ",count)
                    }
                    for i in 1...count
                    {
                        let ppdata = jsonData.value(forKey: "\(i)") as! NSDictionary
                        PPs_List_fromCloud.append(ppdata)
                        if self.debug == 1 {
                            print(".")
                        }
                    }
                    //self.Cloud_Feeback = true
                    self.mergeList_to_cloudList(ns_cloudList: PPs_List_fromCloud)
                }
                else
                {
                    if self.debug == 1 {
                        print("No Status and Count feeback")
                    }
                    self.addViewHint(Title: "網路異常", msgStr: "請稍後再試", btnTitle: "確認")
                }
            }
            else
            {
                if self.debug == 1 {
                    print("HTTPS_jsonHandler : something wrong..")
                }
                self.addViewHint(Title: "景點搜尋", msgStr: "伺服器忙碌中，請稍候重試", btnTitle: "確認")
            }
        }
    }
    
    @objc func mergeList_to_cloudList(ns_cloudList : [NSDictionary])
    {
        if debug == 1 {
            print ("Cloud List : ", ns_cloudList)
        }
        //cloudList.removeAll()
        //let db = DB_Access()
        for p in ns_cloudList
        {
            var InInfoList = 0
            for cloudP in infoList
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
                
                infoList.append(nsmObjc!)
            }
        }
        
        //ppList_updated = 1
        //Reload_ppList()
        search_TableView!.reloadData()
        alertShortMessage!.dismiss(animated: true, completion: nil)
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
    
    @objc func addViewHint(Title:String, msgStr: String, btnTitle:String) {
        
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
    
    // 按空白處會隱藏編輯狀態
    @objc func hideKeyboard(tapG:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
}

private class search_ViewCell: UITableViewCell {
    
    static let reuseID = "searchVC_Cell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
