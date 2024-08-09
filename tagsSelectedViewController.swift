//
//  tagsSelectedViewController.swift
//  Makeda
//
//  Created by Brian on 2019/3/29.
//  Copyright © 2019 breadcrumbs.tw. All rights reserved.
//

import Foundation
import CoreData
import UIKit
//import CoreData

class tagsSelectedViewController: UIViewController, UIScrollViewDelegate
{
    let debug = 0
    var tagsButton:UIButton?
    var tagSelVC_ScrollView: UIScrollView?
    let tagsButtonID = 1000
    var tagsButtonHigh = 30
    let startHeaderY = 30
    var endOffsetY = 0
    let fullScreenSize = UIScreen.main.bounds.size
    var local_ppList:[NSManagedObject] = []
    var tags:[String] = []
    var btn_array:[Int] = []
    var cloud_connected = 0
    var townUnitCount = 0
    var mainItemCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewLoad()
        /*
        let myUserDefaults = UserDefaults.standard
        if let cloudst = myUserDefaults.value(forKey: "cloud_connected")
        {
            cloud_connected = cloudst as! Int
            if self.debug == 1 {
                print ("Cloud connect status : \(cloud_connected)")
            }
        }*/
        TagsTabLoad()
        PPTagsLoad()
        self.view.backgroundColor = UIColor.white
        // reset scrollview content size
        tagSelVC_ScrollView!.contentSize = CGSize(width: fullScreenSize.width, height: CGFloat(endOffsetY + 50))
    }
    
    func scrollViewLoad()
    {
        if self.debug == 1 {
            print("tagsSelectedViewController: scrollViewLoad")
        }
        // 建立 UIScrollView
        tagSelVC_ScrollView = UIScrollView()
        
        // 設置尺寸 也就是可見視圖範圍
        tagSelVC_ScrollView!.frame = CGRect(x: 0, y: CGFloat(tagsButtonHigh + startHeaderY), width: fullScreenSize.width, height: fullScreenSize.height - CGFloat(tagsButtonHigh + startHeaderY))
        
        // 實際視圖範圍 為 3*2 個螢幕大小
        tagSelVC_ScrollView!.contentSize = CGSize(width: fullScreenSize.width, height: fullScreenSize.height * 2)
        
        // 是否顯示水平的滑動條
        tagSelVC_ScrollView!.showsHorizontalScrollIndicator = false
        
        // 是否顯示垂直的滑動條
        tagSelVC_ScrollView!.showsVerticalScrollIndicator = false
        
        // 滑動條的樣式
        tagSelVC_ScrollView!.indicatorStyle = .black
        
        // 是否可以滑動
        tagSelVC_ScrollView!.isScrollEnabled = true
        
        // 是否可以按狀態列回到最上方
        tagSelVC_ScrollView!.scrollsToTop = false
        
        // 限制滑動時只能單個方向 垂直或水平滑動
        tagSelVC_ScrollView!.isDirectionalLockEnabled = false
        
        // 滑動超過範圍時是否使用彈回效果
        tagSelVC_ScrollView!.bounces = true
        
        // 縮放元件縮放時是否在超過縮放倍數後使用彈回效果
        tagSelVC_ScrollView!.bouncesZoom = true
        
        // 設置委任對象
        tagSelVC_ScrollView!.delegate = self
        
        // 起始的可見視圖偏移量 預設為 (0, 0)
        // 設定這個值後 就會將原點滑動至這個點起始
        //myScrollView.contentOffset = CGPoint(x: fullSize.width * 0.5, y: fullSize.height)
        
        // 以一頁為單位滑動
        tagSelVC_ScrollView!.isPagingEnabled = false
        
        // 加入到畫面中
        self.view.addSubview(tagSelVC_ScrollView!)
    }
    
    func spliteLabelLoad( X:Int , Y:Int, text: String)
    {
        let label = UILabel(frame: CGRect(x: X, y: Y, width: Int(fullScreenSize.width), height: 10))
        label.backgroundColor = UIColor.white
        label.text = text
        //tagsLabel!.text = //"運行版本"
        // 文字顏色
        //tagsLabel!.textColor = UIColor.black
        //tagsLabel!.attributedText = NSAttributedString(string: "食")
        // 文字的字型與大小
        label.font = UIFont(name: "Helvetica-Light", size: 14)
        
        // 設定文字位置 置左、置中或置右等等
        label.textAlignment = NSTextAlignment.center
        
        // 文字行數
        label.numberOfLines = 1//tags.count/3
        //versionLab!.bounds = CGRect(
        //        x: startXOffSet, y: startYOffSet, width: 80, height: 50)
        tagSelVC_ScrollView!.addSubview(label)
    }
    
    func PPTagsLoad()
    {
        checkPPList()
        if tags.count == 0
        {
            if self.debug == 1 {
                print ("None Tags come in")
            }
            return
        }

        //var btn:UIButton?
        let count = tags.count  //incloud cloud connected item
        var offsetY = 5//startHeaderY + tagsButtonHigh
        let X_StartOffset = 5
        let buttnGap = 5
        var offsetX = X_StartOffset
        if debug == 1 {
            print ("Town Count : ", townUnitCount, " Main Item Count : ", mainItemCount)
        }

        for i in 0 ... count - 1
        {
            let btnWidth = Int(tags[i].count * 20)
            
            if ((offsetX + btnWidth) > Int(fullScreenSize.width))
            {
                offsetY = offsetY + tagsButtonHigh + 5
                offsetX = X_StartOffset
            }
            if i == 0 {
                //spliteLabelLoad( X: 0, Y: (offsetY + tagsButtonHigh + 5), text: " - 區域 - ")
                spliteLabelLoad( X: 0, Y: (offsetY), text: " - 區域 - ")
                offsetY = offsetY + (tagsButtonHigh + 5)
                offsetX = X_StartOffset
            } else if i == (townUnitCount) {
                offsetY = offsetY + (tagsButtonHigh + 5)
                spliteLabelLoad( X: 0, Y: (offsetY), text: " - 參考項目 - ")
                offsetY = offsetY + (tagsButtonHigh + 5)
                offsetX = X_StartOffset
            } else if i == (townUnitCount + mainItemCount) {
                offsetY = offsetY + (tagsButtonHigh + 5)
                offsetX = X_StartOffset
            }
            
            let btn = UIButton(
                frame: CGRect(x: offsetX, y: offsetY, width: btnWidth, height: tagsButtonHigh))
            offsetX = offsetX + btnWidth + buttnGap
            //oneSingleLen = oneSingleLen + offsetX
            
            btn.setTitle(tags[i], for: .normal)
            btn.showsTouchWhenHighlighted = true
            btn.tag = tagsButtonID + i
            btn.layer.cornerRadius = 5.0
            btn.isEnabled = true
            /*
            if i == 0
            {
                if cloud_connected == 1 {
                    btn.backgroundColor = UIColor.lightGray
                } else {
                    btn.backgroundColor = UIColor(red: 0, green: 190/255, blue: 1, alpha: 0.8)
                }
            } else {
             */
                btn.backgroundColor = UIColor(red: 0, green: 190/255, blue: 1, alpha: 0.8)
            //}
            // 按鈕按下後的動作
            btn.addTarget(
                self,
                action: #selector(selectedTags(_:)),
                for: .touchUpInside)
            btn_array.append(0)
            /*
            if i != 0
            {
                btn_array.append(0)
            } else {
                if cloud_connected == 1 {
                    btn_array.append(1)
                } else {
                    btn_array.append(0)
                }
            }
             */
            tagSelVC_ScrollView!.addSubview(btn)
        }
        endOffsetY = offsetY
    }
    
    func isMainItem(inS : String) -> Bool {
        var isMainItem = 0
        for l in ppMainTags().list {
            if inS == l {
                if self.debug == 1 {
                    print (" unit string : ",l, " tag :", inS)
                }
                isMainItem = 1
            }
        }
        if isMainItem == 1 {
            return true
        }
        return false
    }
    
    func isTownUnit(inS : String)->Bool {
        var unitFlag = 0
        for l in TownUnit().list {
            var NotTownUnit = 0
            for n in TownUnit().notIncludes {
                if inS.range(of: n) != nil {
                    NotTownUnit = 1
                }
            }
            if inS.hasSuffix(l) && NotTownUnit == 0{
                if self.debug == 1 {
                    print (" unit string : ",l, " tag :", inS)
                }
                unitFlag = 1
            }
        }
        if unitFlag == 1 {
            return true
        }
        return false
    }
    
    func checkPPList()
    {
        if local_ppList.count > 0 && !local_ppList.isEmpty
        {
            for eachPP in local_ppList
            {
                let note = eachPP.value(forKey: "pp_note") as? String
                var newtags = note!.components(separatedBy: "#")
                newtags = note!.components(separatedBy: " ")
                let tags_filter = newtags.filter({$0 != "" && $0 != " "})
                if self.debug == 1
                {
                    print("Tags filter ...: ", tags_filter)
                }

                for ltag in tags_filter
                {
                    if !tags.contains(ltag)
                    {
                        var unitFlag = 0

                        if isTownUnit(inS: ltag) {
                            unitFlag = 1
                        }

                        if unitFlag == 1
                        {
                            tags.insert(ltag, at: townUnitCount)
                            townUnitCount = townUnitCount + 1
                        } else {
                            if isMainItem(inS: ltag)
                            {
                                if debug == 1 {
                                    print (" Is Main Item : ", ltag, " mainItemCount : ", mainItemCount)
                                }
                                tags.insert(ltag, at: townUnitCount)
                                mainItemCount = mainItemCount + 1
                            }
                            else {
                                tags.append(ltag)
                            }
                        }
                    }
                    else
                    {
                        if self.debug == 1 {
                            print ("HAS same : ",ltag)
                        }
                    }
                }
            }
        }
        else
        {
            if self.debug == 1 {
                print("local_ppList : is NULL")
            }
        }
        
        if self.debug == 1 {
            print ("TAGS : ", tags)
        }
    }
    
    
    func setPPList(ppList: [NSManagedObject])
    {
        if ppList.count > 0 &&
            !ppList.isEmpty {
            local_ppList = ppList
        }
    }
    
    func TagsTabLoad()
    {
        if self.debug == 1 {
            print("tagsSelectedViewController: TagsTabLoad")
        }
        tagsButton = UIButton(
            frame: CGRect(x: 0, y: startHeaderY, width: Int(fullScreenSize.width), height: tagsButtonHigh))
        //tagsButton!.layer.cornerRadius = 5.0
        // 按鈕文字
        tagsButton!.setTitle("▲ 回到私房手冊", for: .normal)
        
        // 按鈕文字顏色
        tagsButton!.setTitleColor(UIColor.white, for: .normal)
        // 按鈕是否可以使用
        tagsButton!.isEnabled = true
        // 按鈕背景顏色
        tagsButton!.backgroundColor = UIColor(red: 0, green: 190/255, blue: 1, alpha: 0.8)
        //UIColor(red: 0, green: 160/255, blue: 1, alpha: 0.8)
        //UIColor.darkGray
        // 按鈕按下後的動作
        tagsButton!.addTarget(
            self,
            action: #selector(back),
            for: .touchUpInside)
        
        self.view.addSubview(tagsButton!)
    }
    
    @IBAction func selectedTags(_ sender: UIButton!)
    {
        if self.debug == 1 {
            print("BUTTON\(sender.tag - tagsButtonID) pressed")
        }
        if btn_array[sender.tag - tagsButtonID] == 0
        {
            sender.backgroundColor = UIColor.lightGray//UIColor(red: 0, green: 190/255, blue: 1, alpha: 0.8)
            btn_array[sender.tag - tagsButtonID] = 1
        }
        else if btn_array[sender.tag - tagsButtonID] == 1
        {
            sender.backgroundColor = UIColor(red: 0, green: 190/255, blue: 1, alpha: 0.8)
            btn_array[sender.tag - tagsButtonID] = 0
        }
        /*
        // cache cloud connected status in user default
        if (sender.tag - tagsButtonID) == 0
        {
            if self.debug == 1 {
                print ("STORE button 0 status....")
            }
            let myUserDefaults = UserDefaults.standard
            cloud_connected = btn_array[sender.tag - tagsButtonID]
            myUserDefaults.setValue(cloud_connected, forKey: "cloud_connected")
            myUserDefaults.synchronize()
 
        }
         */
    }
    
    func getTagsList() -> [String]
    {
        //btn_array = set_tags_selected
        //tags = set_tags_list
        //return btn_array
        return tags
    }
    
    func getTagsSelectedList() -> [Int]
    {
        //btn_array = set_tags_selected
        //tags = set_tags_list
        return btn_array
    }

    @objc func back()
    {
       self.dismiss(animated: true, completion:nil)
    }
}


