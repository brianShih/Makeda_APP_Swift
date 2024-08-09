//
//  CommentsViewController.swift
//  Makeda
//
//  Created by Brian on 2019/8/22.
//  Copyright © 2019 breadcrumbs.tw. All rights reserved.
//
import UIKit
import Alamofire
import CoreData

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let debug = 0
    let URL_PP_HELPER = "TODO"
    let fullScreenSize = UIScreen.main.bounds.size
    let COMMENTS_GET = 0
    let COMMENT_ADD = 1
    let COMMENT_UPDATE = 2
    let StartY = 30
    let StartX = 10
    let BtnHeight = 30
    let commentTextViewHeight = 60
    let goBackButtonID = 1001
    let CommentsTextFieldID = 1002
    let commentsButtonID = 1003
    var PPdetail:NSManagedObject! = nil
    var commentsTextView : UITextView?
    var commentsVC_ScrollView : UIScrollView?
    var comments_TableView : UITableView?
    var cmtsList: [NSDictionary] = []
    var userEmail = "email"
    var commented = 0
    var userLogin = 0
    var userCommentID = 0
    var alertShortMessage : UIAlertController?
    var db:DB_Access!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = DB_Access()
        db.db_init()
        let myUserDefaults = UserDefaults.standard
        if let email = myUserDefaults.value(forKey: "user_email") as? String
        {
            userEmail = email
        }
        
        goBackBtn()
        commentsTextLoad()
        commentButtonLoad()
        scrollViewLoad()
        tabViewLoad()
        
        if PPdetail != nil {
            sendCloud(status_in: COMMENTS_GET, comment: "")
        }
        // 增加一個觸控事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(tapG:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
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
    
    func commentsTextLoad() {
        let ySeat = StartY + BtnHeight
        let widthSize = Int(fullScreenSize.width) - 30 - 20
        commentsTextView = UITextView(frame: CGRect(x: StartX, y: ySeat, width: widthSize, height: commentTextViewHeight))
        commentsTextView!.font = UIFont(name: "Helvetica-Light", size: 18)
        commentsTextView!.keyboardType = .default
        commentsTextView!.returnKeyType =  UIReturnKeyType.continue
        commentsTextView!.textColor = UIColor.black
        commentsTextView!.backgroundColor = UIColor.clear
        
        self.view.addSubview(commentsTextView!)
    }
    
    func commentButtonLoad() {
        let ySeat = StartY + BtnHeight
        let xSeat = Int(fullScreenSize.width) - 25 - 10
        let commentButton = UIButton(
            frame: CGRect(x: xSeat, y: ySeat, width: 25, height: 25))
        commentButton.setImage(UIImage(named: "save@x3.png"), for: .normal)
        commentButton.tag = commentsButtonID
        commentButton.isEnabled = true
        commentButton.addTarget(
            self,
            action: #selector(self.commentAction),
            for: .touchUpInside)
        
        self.view.addSubview(commentButton)
    }
    
    func scrollViewLoad()
    {
        let ySeat = StartY + BtnHeight + commentTextViewHeight + 5
        commentsVC_ScrollView = UIScrollView()
        commentsVC_ScrollView!.frame = CGRect(x: 0, y: ySeat, width: Int(fullScreenSize.width), height: Int(fullScreenSize.height) - ySeat)
        commentsVC_ScrollView!.contentSize = CGSize(width: fullScreenSize.width, height: fullScreenSize.height * 2)
        commentsVC_ScrollView!.showsHorizontalScrollIndicator = false
        commentsVC_ScrollView!.showsVerticalScrollIndicator = false
        commentsVC_ScrollView!.indicatorStyle = .black
        commentsVC_ScrollView!.isScrollEnabled = false
        commentsVC_ScrollView!.scrollsToTop = false
        commentsVC_ScrollView!.isDirectionalLockEnabled = false
        commentsVC_ScrollView!.bounces = true
        commentsVC_ScrollView!.bouncesZoom = true
        commentsVC_ScrollView!.delegate = self
        commentsVC_ScrollView!.isPagingEnabled = false
        self.view.addSubview(commentsVC_ScrollView!)
    }
    
    func tabViewLoad()
    {
        let scrollViewY = StartY + BtnHeight + commentTextViewHeight + 5
        comments_TableView = UITableView(frame: CGRect(
            x: 0, y: 0,
            width: Int(fullScreenSize.width),
            height: Int(fullScreenSize.height) - scrollViewY
        ), style: .grouped)
        comments_TableView!.register(
            comments_ViewCell.self, forCellReuseIdentifier: comments_ViewCell.reuseID)
        comments_TableView!.delegate = self
        comments_TableView!.dataSource = self
        comments_TableView!.separatorStyle = .singleLine
        //ppV_TableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20)
        comments_TableView!.allowsSelection = true
        comments_TableView!.allowsMultipleSelection = false
        commentsVC_ScrollView!.addSubview(comments_TableView!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (cmtsList.count == 0)
        {
            return 0
        }
        return cmtsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 取得 tableView 目前使用的 cell
        let cell = tableView.dequeueReusableCell(withIdentifier: comments_ViewCell.reuseID, for: indexPath) as UITableViewCell
        cell.textLabel?.font =  UIFont(name: "Helvetica-Light", size: 12)
        cell.detailTextLabel?.font =  UIFont(name: "Helvetica-Light", size: 18)
        cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.detailTextLabel?.numberOfLines = 0
        // 顯示的內容
        //cell.accessoryType = .detailDisclosureButton
        if cmtsList.count > 0
        {
            if let name = cmtsList[indexPath.row].value(forKey: "comment_author") as? String
            {
                let date = cmtsList[indexPath.row].value(forKey: "comment_date") as! String
                cell.textLabel?.text = "\(name) | \(date)"
            }
            if let content = cmtsList[indexPath.row].value(forKey: "comment_content")
            {
                cell.detailTextLabel?.text = content as? String
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
    }
    /*
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath)
        -> [UITableViewRowAction]?
    {
        var actionArr:Array<UITableViewRowAction> = [UITableViewRowAction]()
        return actionArr;
    }*/
    
    // 有幾組 section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion:nil)
    }
    
    @objc func commentAction() {
        let comment = (commentsTextView!.text)
        if (commented == 0) {
            sendCloud(status_in: COMMENT_ADD, comment: comment!)
        } else {
            sendCloud(status_in: COMMENT_UPDATE, comment: comment!)
        }
    }
    
    @objc func sendCloud(status_in: Int, comment: String) {
        var parameters: Parameters?
        self.view.endEditing(true)
        cmtsList.removeAll()
        addAlertMessage(Title: "請稍候", msgStr: "評論資料庫連接中...")
        /*let COMMENTS_GET = 0
        let COMMENT_ADD = 1
        let COMMENT_UPDATE = 2*/
        if let name =  PPdetail.value(forKey: "pp_name") as? String {
            if (status_in == COMMENTS_GET) {
                //'CMD' : 'GET_PP_COMS', 'name' : u'麵包屑&三合院'
                parameters = [
                    "TODO":"TODO",
                    "name" : name
                ]
            } else if (status_in == COMMENT_ADD) {
                //'CMD' : 'ADD_PP_COM', 'email':'qfeel0215@gmail.com','name' : u'麵包屑&三合院', 'reply_id':'0','comment':'測試測試01'}
                parameters = [
                    "TODO":"TODO",
                    "TODO" : userEmail,
                    "TODO" : name,
                    "reply_id" : 0,
                    "comment" : comment
                ]
            } else if (status_in == COMMENT_UPDATE) {
                //'CMD' : 'EDIT_PP_COM', 'email':'qfeel0215@gmail.com','name' : u'麵包屑&三合院', 'id':'25','comment':'回應-測試測試01 + 更新測試'}
                if (userCommentID == 0) {
                    if self.debug == 1 {
                        print("no user comment ID")
                    }
                    closeAlertMessage()
                    return
                } else {
                    if self.debug == 1 {
                        print("User comment ID : ", userCommentID)
                    }
                    parameters = [
                        "TODO":"TODO",
                        "TODO" : userEmail,
                        "TODO" : name,
                        "id" : userCommentID,
                        "comment" : comment
                    ]
                }
            }
        }
        closeAlertMessage()
        
        //Sending http post request
        Alamofire.request(self.URL_PP_HELPER, method: .post, parameters: parameters).responseJSON
        { response in
            if let result = response.result.value {
                let jsonData = result as! NSDictionary
                if self.debug == 1 {
                    print("jsonData :", jsonData)
                }
                if (status_in == self.COMMENTS_GET)
                {
                    self.getCommentsList(jsonData: jsonData)
                }
                else {
                    if let status:Int = jsonData.value(forKey: "status") as? Int {
                        if status == 1 {
                            if status_in == self.COMMENT_UPDATE {
                                self.addViewHint(Title: "塗改足跡", msgStr: "更新您的評論囉！", btnTitle: "確認")
                            } else if status_in == self.COMMENT_ADD {
                                self.addViewHint(Title: "留下足跡", msgStr: "完成您的評論囉！", btnTitle: "確認")
                            }
                        } else {
                            if status_in == self.COMMENT_UPDATE {
                                self.addViewHint(Title: "失敗", msgStr: "更新評論失敗，稍後再試", btnTitle: "確認")
                            } else if status_in == self.COMMENT_ADD {
                                self.addViewHint(Title: "失敗", msgStr: "新增評論失敗，稍後再試", btnTitle: "確認")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func getCommentsList(jsonData : NSDictionary) {
        if self.debug == 1 {
            print("jsonData : ",jsonData)
        }
        if let status:Int = jsonData.value(forKey: "status") as? Int
        {
            if self.debug == 1 {
                print("Cloud feeback ： ", status)
            }
        }
        if let count:Int = jsonData.value(forKey: "count") as? Int
        {
            if self.debug == 1 {
                print("Get data from Cloud count: ",count)
            }
            for i in 1...count
            {
                let comment = jsonData.value(forKey: "\(i)") as! NSDictionary
                if let cmt_auth_email = comment.value(forKey:"comment_author_email") as? String {
                    if self.debug == 1 {
                        print ("userEmail : ", userEmail)
                        print("comment author email : ", cmt_auth_email)
                    }
                    if userEmail == cmt_auth_email {
                        if let content = comment.value(forKey:"comment_content") as? String {
                            commentsTextView!.text = content
                            commented = 1
                            if let commentID = comment.value(forKey:"commentID") as? Int {
                                userCommentID = commentID
                            }
                        }
                    } else {
                        cmtsList.append(comment)
                    }
                }
            }
            if self.debug == 1 {
                print("Reload data...")
            }
            comments_TableView?.reloadData()
        }
        else
        {
            if self.debug == 1 {
                print("No Status and Count feeback")
            }
            self.addViewHint(Title: "搶先評論", msgStr: "開始留下你的感想吧 :)", btnTitle: "確認")
            commentsTextView!.text = "<<按這裡>> 開始寫下評論吧！"
        }
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

private class comments_ViewCell: UITableViewCell {
    
    static let reuseID = "commentsVC_Cell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

