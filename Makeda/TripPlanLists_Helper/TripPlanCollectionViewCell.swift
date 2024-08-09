//
//  TripPlanCollectionViewCell.swift
//  Makeda
//
//  Created by Brian on 2019/11/20.
//  Copyright © 2019 breadcrumbs.tw. All rights reserved.
//

import UIKit


class TripPlanCollectionViewCell: UICollectionViewCell {
    var imageButton:UIButton!
    var titleLabel:UILabel!
    var mode = 0
    let ButtonWidth:Int = 30
    let ButtonHight:Int = 30
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        // 取得螢幕寬度
        let w = Double(UIScreen.main.bounds.size.width)
        let width = w/5 - 10.0
        
        // 建立一個 UIImageView
        //imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: w/3 - 10.0, height: w/3 - 10.0))
        //self.addSubview(imageView)
        
        // 建立一個 UILabel
        titleLabel = UILabel(frame:CGRect(x: 0, y: 0, width:  Int(width), height: ButtonHight))
        titleLabel.font = UIFont(name: "Helvetica-Light", size: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        self.addSubview(titleLabel)

        imageButton = UIButton(frame: CGRect(x: Int(width) - Int(ButtonWidth / 6), y: Int(0),
                                    width: Int(ButtonWidth - 13), height: Int(ButtonHight - 13)))
        imageButton.setImage(UIImage(named: "close@x3.png"), for: .normal)
        imageButton.setTitleColor(UIColor.black, for: .normal)
        imageButton.backgroundColor = UIColor.clear

        imageButton.isEnabled = true
        self.addSubview(imageButton)
    }
    
    func setEditMode(editmode: Int) {
        mode = editmode
    }
    
    func clickCell(name: String) {
        //self.titleLabel.backgroundColor = UIColor(red: 0, green: 160/255, blue: 1, alpha: 0.8)
         titleLabel.textColor = UIColor.white
    }
    
    func configureCell(name: String) {
        self.titleLabel.text = name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
