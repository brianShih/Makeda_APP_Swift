//
//  HTTPS_jsonHandler.swift
//  Makeda
//
//  Created by Brian on 2019/3/23.
//  Copyright © 2019 breadcrumbs.tw. All rights reserved.
//

import Alamofire
import CoreData

class HTTPS_jsonHandler {
    let debug = 0
    let URL_PP_HANDLER = "TODO"
    var email:String? = nil
    var Cloud_Feeback:Bool = false
    var Cloud_DB_Ready: Bool = false
    var PPs_List_fromCloud:[NSDictionary] = []
    
    func HTTPS_jsonHandler_Init()
    {
        let myUserDefaults = UserDefaults.standard
        if let useremail = myUserDefaults.object(forKey: "user_email") as? String
        {
            email = useremail
        }
    }
    
    func Get_PPsList()  throws -> [NSDictionary]
    {
        return PPs_List_fromCloud
    }
    
    func Clean_CloudStatus()
    {
        Cloud_Feeback = false
    }
    
    func getCloudFeeback()->Bool
    {
        return Cloud_Feeback
    }
    
    
    func checkLocalDB_PPStatus()
    {
        if email == nil
        {
            return
        }
        let db:DB_Access = DB_Access()
        let caches = db.pp_getAll()
        if (caches != nil)
        {
            for result in (caches!) {
                if let status = result.value(forKey: "pp_status") as? Int,
                    let _ = result.value(forKey: "pp_name") as? String
                {
                    if status == 0
                    {
                        // update to cloud
                        let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
                        dispatchQueue.async{
                            if self.debug == 1 {
                                print("result : ", result)
                            }
                            self.add_pp(pp_values: result)
                        }

                    }
                }
            }
        }
    }
    
    func HTTPS_Donwload_PPsOfCity(country_in:String, city_in:String)
    {
        if !city_in.isEmpty && !country_in.isEmpty
        {
            self.get_pps_of_city(country: country_in, city: city_in)
        }
        
        let dispatchQueue = DispatchQueue(label: "queue_downloadPPS", qos: .background)
        let additionalTime: DispatchTimeInterval = .seconds(1)
        dispatchQueue.asyncAfter(deadline: .now() + additionalTime) {
            var delayCnt = 0
            while !self.getCloudFeeback()
            {
                sleep(1)
                delayCnt = delayCnt + 1
                if delayCnt > 500
                {
                    if self.debug == 1 {
                        print ("BREAK WHILE LOOP")
                    }
                    break
                }
            }
            if self.debug == 1 {
                print("Cloud feeback: ", self.PPs_List_fromCloud)
            }
        }
    }
    
    func get_pps_of_city(country:String, city:String)
    {
        PPs_List_fromCloud.removeAll()
        if debug == 1 {
            print("Download PPs of \(city),\(country) from Cloud")
        }
        let parameters: Parameters = [
            "TODO":"TODO",
            "Country" : country,
            "City" : city
        ]
        Alamofire.request(self.URL_PP_HANDLER, method: .post, parameters: parameters).responseJSON
        { response in
            //getting the json value from the server
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            let tbVC = appDelegate.window!.rootViewController as! UITabBarController
            let DashVC = tbVC.viewControllers?[2] as? DashViewController

            if let result = response.result.value {
                let jsonData = result as! NSDictionary
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
                        self.PPs_List_fromCloud.append(ppdata)
                        if self.debug == 1 {
                            print(".")
                        }
                    }
                    self.Cloud_Feeback = true
                }
                else
                {
                    if self.debug == 1 {
                        print("No Status and Count feeback")
                    }
                    DashVC?.addViewHint(Title: "網路異常", msgStr: "請稍後再試", btnTitle: "確認")
                }
            }
            else
            {
                if self.debug == 1 {
                    print("HTTPS_jsonHandler : something wrong..")
                }
                DashVC?.addViewHint(Title: "\(city)景點搜尋", msgStr: "伺服器忙碌中，請稍候重試", btnTitle: "確認")
            }
        }
    }
    
    func add_pp(pp_values:NSManagedObject)
    {
        if let name = pp_values.value(forKey: "pp_name") as? String,
            let country = pp_values.value(forKey: "pp_country") as? String,
            let address = pp_values.value(forKey: "pp_address") as? String,
            let tag_note = pp_values.value(forKey: "pp_note") as? String
        {
            var phone = ""
            var fb = ""
            var web = ""
            var bloggerInto = ""
            var opentime = ""
            var score = 0
            var pic_url = ""
            var descrip = ""
            if (pp_values.value(forKey: "pp_phone") != nil) {
                phone = pp_values.value(forKey: "pp_phone") as! String
            }
            if (pp_values.value(forKey: "pp_fb") != nil) {
                fb = pp_values.value(forKey: "pp_fb") as! String
            }
            if (pp_values.value(forKey: "pp_web") != nil) {
                web = pp_values.value(forKey: "pp_web") as! String
            }
            if (pp_values.value(forKey: "blogger_intro") != nil) {
                bloggerInto = pp_values.value(forKey: "blogger_intro") as! String
            }
            if (pp_values.value(forKey: "pp_opentime") != nil) {
                opentime = pp_values.value(forKey: "pp_opentime") as! String
            }
            if (pp_values.value(forKey: "pp_score") != nil) {
                score = pp_values.value(forKey: "pp_score") as! Int
            }
            if (pp_values.value(forKey: "pp_pic") != nil) {
                pic_url = pp_values.value(forKey: "pp_pic") as! String
            }
            if (pp_values.value(forKey: "pp_descrip") != nil) {
                descrip = pp_values.value(forKey: "pp_descrip") as! String
            }
            let comment = String("")
            let parameters: Parameters = [
                "TODO":"TODO",
                "email":email!,
                "name": name,
                "phone": phone,
                "country": country,
                "address": address,
                "fb": fb,
                "web": web,
                "bloggerIntro": bloggerInto,
                "tag_note": tag_note,
                "opentime": opentime,
                "score": score,
                "pic_url": pic_url,
                "description": descrip,
                "comment": comment
                ]
            
            Alamofire.request(self.URL_PP_HANDLER, method: .post, parameters: parameters).responseJSON
            { response in
                    //printing response
                    //print(response)
                
                    //getting the json value from the server
                    if let result = response.result.value {
                        let jsonData = result as! NSDictionary
                        let status = jsonData.value(forKey: "status") as! Int
                        var db_pp_status = 0
                        if status == 0
                        {
                            if let message = jsonData.value(forKey: "message") as? String
                            {
                                if self.debug == 1 {
                                    print("Alamofire response: ERROR message",message)
                                }
                                if message.range(of: "PP Already Exist") != nil
                                {
                                    db_pp_status = 1
                                }
                            }
                        }
                        else
                        {
                            db_pp_status = 1
                            if self.debug == 1 {
                                print("Alamofire response: suessful")
                            }
                        }
                        let loc_id = String(pp_values.value(forKey: "id") as! Int)
                        let loc_status = "\(db_pp_status)"
                        let db:DB_Access = DB_Access()
                        if db.pp_updateStatus(id: loc_id, pp_status: loc_status)
                        {
                            if self.debug == 1 {
                                print("Alamofire response: Change Local pp status successful")
                            }
                        }
                        //converting it as NSDictionary
                        //let jsonData = result as! NSDictionary
                        //let status = jsonData.value(forKey: "status") as! Int
                    }
            }
        }
        else
        {
            if self.debug == 1 {
                print("Value is not correctly")
            }
        }
    }
}
