//
//  PP_EditViewController.swift
//  
//
//  Created by Brian on 2019/8/20.
//

import Foundation
import UIKit
import CoreData

class PP_EditViewController: UIViewController {
    let fullScreenSize = UIScreen.main.bounds.size
    //var db:DB_Access!
    var indexRow = 0
    var PPdetail:NSManagedObject! = nil
    var pp_editContent:UITextView! = nil
    let startX = 10
    let startY = 30
    let buttonHeight = 30
    let goBackButtonHeight = 30
    
    override func viewWillAppear(_ animated: Bool) {
    
    }
    
    override func viewDidLoad() {
        goBackBtn()
        saveBtn()
        editTextLoad()
        loadContent()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(tapG:)))
        tap.cancelsTouchesInView = false
        // 加在最基底的 self.view 上
        self.view.addGestureRecognizer(tap)
    }
    
    func loadContent() {
        pp_editContent!.text = PPdetail.value(forKey: PP_Viewer.tabStr().dbName[indexRow]) as? String
    }
    
    func goBackBtn()
    {
        let backButton = UIButton(
            frame: CGRect(x: 5, y: startY, width: 30, height: buttonHeight))
        backButton.setTitle("＜", for: .normal)
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.backgroundColor = UIColor.clear
        //backButton.setImage(UIImage(named: "if_back@x3"), for: .normal)
        //backButton.tag = goBackButtonID
        
        // 按鈕是否可以使用
        backButton.isEnabled = true
        
        // 按鈕按下後的動作
        backButton.addTarget(
            self,
            action: #selector(PP_EditViewController.goBack),
            for: .touchUpInside)
        
        self.view.addSubview(backButton)
    }
    
    func saveBtn()
    {
        let buttonX = Int(fullScreenSize.width) - 5 - buttonHeight
        let saveButton = UIButton(
            frame: CGRect(x: buttonX, y: startY, width: 30, height: buttonHeight))
        //saveButton.setTitle("＜", for: .normal)
        //saveButton.setTitleColor(UIColor.black, for: .normal)
        saveButton.setImage(UIImage(named: "save@x3.png"), for: .normal)
        saveButton.backgroundColor = UIColor.clear
        //backButton.setImage(UIImage(named: "if_back@x3"), for: .normal)
        //backButton.tag = goBackButtonID
        
        // 按鈕是否可以使用
        saveButton.isEnabled = true
        
        // 按鈕按下後的動作
        saveButton.addTarget(
            self,
            action: #selector(PP_EditViewController.save),
            for: .touchUpInside)
        
        self.view.addSubview(saveButton)
    }
    
    func editTextLoad() {
        let textViewWitdh = Int(fullScreenSize.width) - startX*2
        let textViewHeight = Int(fullScreenSize.height) - startY - goBackButtonHeight*2
        
        pp_editContent = UITextView(frame: CGRect(x: startX, y: startY + goBackButtonHeight, width: textViewWitdh, height: textViewHeight))
        pp_editContent.layer.borderColor = UIColor.lightGray.cgColor
        pp_editContent.layer.borderWidth = 0.5
        pp_editContent.layer.cornerRadius = 5.0
        pp_editContent.keyboardType = .default
        pp_editContent.font = UIFont(name: "Helvetica-Light", size: 18)
        
        // 鍵盤上的 return 鍵樣式 這邊選擇 Done
        pp_editContent.returnKeyType =  UIReturnKeyType.default
        
        // 輸入文字的顏色
        pp_editContent.textColor = UIColor.gray
        
        //pp_editContent.tag = DescriptTextFieldTag
        
        // Delegate
        //pp_descriptTextView.delegate = self
        
        // UITextField 的背景顏色
        pp_editContent.backgroundColor = UIColor.white
        
        self.view.addSubview(pp_editContent)

    }
    
    @objc func save() {
        PPdetail.setValue(pp_editContent.text!, forKey: PP_Viewer.tabStr().dbName[indexRow])
        let id = PPdetail.value(forKey: "id") as! Int
        if (id == 0) {
            // update to cloud
            handlrViewHint(Title: "異常", msgStr: "非管理者權限，無法編輯線上資料", BtnTitle: "確認")
        } else {
            updateToDB()
        }
        goBack()
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion:nil)
    }
    
    // 按空白處會隱藏編輯狀態
    @objc func hideKeyboard(tapG:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    @objc func updateToDB() {
        let db:DB_Access? = DB_Access()
        if let id = PPdetail.value(forKey: "id") as? Int,
            let name = PPdetail.value(forKey: "pp_name") as? String
        {
            var phone = PPdetail.value(forKey: "pp_phone") as? String
            if phone == nil { phone = " " }
            var country = PPdetail.value(forKey: "pp_country") as? String
            if country == nil { country = " " }
            var address = PPdetail.value(forKey: "pp_address") as? String
            if address == nil { address = " " }
            var fb = PPdetail.value(forKey: "pp_fb") as? String
            if fb == nil { fb = " " }
            var web = PPdetail.value(forKey: "pp_web") as? String
            if web == nil { web = " " }
            var bloggerIntro = PPdetail.value(forKey: "blogger_intro") as? String
            if bloggerIntro == nil { bloggerIntro = " " }
            var opentime = PPdetail.value(forKey: "pp_opentime") as? String
            if opentime == nil { opentime = " " }
            var note = PPdetail.value(forKey: "pp_note") as? String
            if note == nil { note = " " }
            var descrip = PPdetail.value(forKey: "pp_descrip") as? String
            if descrip == nil { descrip = " " }
            
            if (db?.pp_update(id: "\(id)", pp_name: name, pp_phone: phone!, pp_country: country!, pp_address: address!, pp_fb: fb!, pp_web: web!, pp_blogger_intro: bloggerIntro!, pp_opentime: opentime!, pp_note: note!, pp_descrip: descrip!, pp_score: "0"))!
            {
                handlrViewHint(Title: "完成", msgStr: "更新完成", BtnTitle: "確認")
            } else {
                handlrViewHint(Title: "異常", msgStr: "請重新操作", BtnTitle: "確認")
            }
        } else {
            handlrViewHint(Title: "異常2", msgStr: "請重新操作", BtnTitle: "確認")
        }
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

        })
        alertController.addAction(okAction)
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    }
}
