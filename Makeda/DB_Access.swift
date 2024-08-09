//
//  db_access.swift
//  Makeda
//
//  Created by Brian on 2018/9/7.
//  Copyright © 2018年 breadcrumbs.tw. All rights reserved.
//
import Foundation
import CoreData
import UIKit

class DB_Access {
    let debug = 0
    private var cdc:CoreDataConnect?
    private let myEntityName = "CACHEDB"
    var default_db_enable = false
    let maxIndex = 1000
    var default_pp = ["TODO", "TODO", "台灣 | 彰化縣",
                      "TODO",
                      "TODO",
                      "https://makeda.breadcrumbs.tw",
                      "待補充",
                      "TODO",
                      "TODO",
                      "TODO",
                      "5"]
    func db_NSManagedObject() -> NSManagedObject?
    {
        let myContext:NSManagedObjectContext?
        if #available(iOS 10.0, *) {
            myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            myContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        }

        return NSEntityDescription.insertNewObject(forEntityName: myEntityName, into: myContext!)
    }
    
    func db_init()
    {
        let myContext:NSManagedObjectContext?
        if #available(iOS 10.0, *) {
            myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        } else {
            // Fallback on earlier versions
            myContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        }
        cdc = CoreDataConnect(context: myContext!)
    }
    
    func db_cleanup(){
        var coreDataConnect:CoreDataConnect
        if cdc == nil {
            let myContext:NSManagedObjectContext?
            if #available(iOS 10.0, *) {
                myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            } else {
                // Fallback on earlier versions
                myContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            }
            coreDataConnect = CoreDataConnect(context: myContext!)
        } else {
            coreDataConnect = cdc!
        }
        
        let selectResult = coreDataConnect.retrieve(myEntityName, predicate: nil, sort: [["id":true]], limit: nil)
        if let results = selectResult {
            for result in results {
                //print("db_cleanup: ","\(result.value(forKey: "id")!)")
                let temp = result.value(forKey: "id")!
                let predicate = "id = \(temp)"
                if debug == 1 {
                    print("db_cleanup predicate :", predicate)
                }
                let deleteResult = coreDataConnect.delete(myEntityName, predicate: predicate)
                if deleteResult {
                    if debug == 1 {
                        print(temp, "刪除資料成功")
                    }
                    //let NextID = id_save(seqID: 0)
                    //print("All data been cleaned , next ID:", NextID)
                }
            }
        }

    }
    
    func default_setup(){
        if debug == 1 {
            print("default_setup: Start")
        }
        var coreDataConnect:CoreDataConnect
        if cdc == nil {
            let myContext:NSManagedObjectContext?
            if #available(iOS 10.0, *) {
                myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            } else {
                // Fallback on earlier versions
                myContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            }
            coreDataConnect = CoreDataConnect(context: myContext!)
        } else {
            coreDataConnect = cdc!
        }
        // check default data
        // select

        let defautPP:String? = default_pp[0]
        let selectResult = coreDataConnect.retrieve(myEntityName, predicate: nil, sort: [["id":true]], limit: nil)
        if let results = selectResult {
            for result in results {
                if let temp = result.value(forKey: "pp_name") as? String
                {
                    if temp.range(of: defautPP!) != nil {
                        default_db_enable = true
                    }
                    else
                    {
                        if debug == 1 {
                            print("default_setup: data not == ", defautPP!)
                        }
                    }
                }
            }
        }
        if default_db_enable == false {
            if debug == 1 {
                print("無預設資料，現在新增中．．．")
            }

            if pp_insert(pp_name: default_pp[0], pp_phone: default_pp[1], pp_country: default_pp[2], pp_address: default_pp[3], pp_fb: default_pp[4], pp_web: default_pp[5] ,pp_blogger_intro: default_pp[6], pp_opentime: default_pp[7], pp_note: default_pp[8],pp_descrip: default_pp[9], pp_score: default_pp[10] ) > 0
            {
                if debug == 1 {
                    print("新增成功")
                }
            }
            else {
                if debug == 1 {
                    print("新增失敗")
                }
            }
        }
    }
    

    public func pp_getAll() -> [NSManagedObject]?
    {
        var cacheList: [NSManagedObject] = []
        var coreDataConnect:CoreDataConnect
        if cdc == nil {
            let myContext:NSManagedObjectContext?
            if #available(iOS 10.0, *) {
                myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            } else {
                // Fallback on earlier versions
                myContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            }
            coreDataConnect = CoreDataConnect(context: myContext!)
        } else {
            coreDataConnect = cdc!
        }

        let selectResult = coreDataConnect.retrieve(myEntityName, predicate: nil, sort: [["id":true]], limit: nil)
        if selectResult?.count == 0
        {
            return nil
        }
        if let results = selectResult {
            for result in results {
                if result.value(forKey: "id") as! Int == 0
                {
                    continue
                }
                else
                {
                    cacheList.append(result)
                }
            }
        }

        return cacheList
    }
    
    public func pp_searchByCountry( country: String) -> [NSManagedObject]?
    {
        if debug == 1 {
            print("pp_searchByCountry:Start")
            print("search ", country )
        }
        var coreDataConnect:CoreDataConnect
        if cdc == nil {
            let myContext:NSManagedObjectContext?
            if #available(iOS 10.0, *) {
                myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            } else {
                // Fallback on earlier versions
                myContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            }
            coreDataConnect = CoreDataConnect(context: myContext!)
        } else {
            coreDataConnect = cdc!
        }

        var cacheList: [NSManagedObject] = []
        
        // check default data
        // select
        let selectResult = coreDataConnect.retrieve(myEntityName, predicate: nil, sort: [["id":true]], limit: nil)
        if selectResult == nil
        {
            return nil
        }
        if let results = selectResult {
            for result in results {
                if result.value(forKey: "id") as! Int == 0
                {
                    continue
                }
                if let temp = result.value(forKey: "pp_country") as? String
                {
                    if (temp.hasPrefix(country))
                    {
                        cacheList.append(result)
                    }
                }
            }
            return cacheList
        }
        if debug == 1 {
            print("pp_searchByCountry no data --- nil")
        }
        return nil
    }
    
    public func pp_searchByName(name:String, country: String) -> [NSManagedObject]?
    {
        if debug == 1 {
            print("search ", name )
        }
        let tempList: [NSManagedObject] = pp_searchByCountry(country: country)!
        var cacheList: [NSManagedObject] = []
        for result in tempList {
            if debug == 1 {
                print("\(result.value(forKey: "id")!). \(result.value(forKey: "pp_name")!)")
            }
            
            
            if let temp = (result.value(forKey: "pp_name") as? String)
            {
                if debug == 1 {
                    print(temp)
                }
                if (temp.hasPrefix(name))
                {
                    cacheList.append(result)
                }
            }
        }
        if cacheList.isEmpty
        {
            if debug == 1 {
                print("pp_searchByName no data")
            }

            return nil
        }
        return cacheList
        
    }

    public func pp_searchByAddress(address:String, country: String) -> [NSManagedObject]?
    {
        let tempList: [NSManagedObject] = pp_searchByCountry(country: country)!
        var cacheList: [NSManagedObject] = []
        for result in tempList {
            if debug == 1 {
                print("\(result.value(forKey: "id")!). \(result.value(forKey: "pp_name")!)")
            }
            if let temp = (result.value(forKey: "pp_address") as? String)
            {
                if debug == 1 {
                    print(temp)
                    print("search ", address )
                }
                //if (temp.hasSuffix(country))//&&
                if (temp.hasPrefix(address))
                {
                    cacheList.append(result)
                    return cacheList
                }
            }
        }

        if cacheList.isEmpty
        {
            if debug == 1 {
                print("pp_searchByAddress no data")
            }
            return nil
        }
        return cacheList
    }
    
    public func pp_searchByCity(city: String) -> [NSManagedObject]?
    {
        if debug == 1 {
            print("pp_searchByCity: Start")
            print("search City: ", city )
        }
        var coreDataConnect:CoreDataConnect
        if cdc == nil {
            let myContext:NSManagedObjectContext?
            if #available(iOS 10.0, *) {
                myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            } else {
                // Fallback on earlier versions
                myContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            }
            coreDataConnect = CoreDataConnect(context: myContext!)
        } else {
            coreDataConnect = cdc!
        }

        var cacheList: [NSManagedObject] = []

        // check default data
        // select
        let selectResult = coreDataConnect.retrieve(myEntityName, predicate: nil, sort: [["id":true]], limit: nil)
        if selectResult?.count == 0
        {
            if debug == 1 {
                print("pp_searchByCity: db connect fail")
            }
            return nil
        }
        if let results = selectResult {
            for result in results {
                var currentCITY = 0
                if result.value(forKey: "id") as? Int == 0
                {
                    continue
                }
                if let cityFromCountry = (result.value(forKey: "pp_country") as? String)
                {
                    if cityFromCountry.range(of: city) != nil
                    {
                        currentCITY = 1
                    }
                }
                if let temp:String = (result.value(forKey: "pp_address") as? String)
                {
                    if temp.range(of: city) != nil
                    {
                        currentCITY = 1
                    }
                }
                if currentCITY == 1
                {
                    cacheList.append(result)
                }
            }
            if debug == 1 {
                print ("pp_searchByCity - Done the Search...")
                print("CacheList : ",cacheList)
            }
            return cacheList
        }
        if debug == 1 {
            print("pp_searchByCity --- nil")
        }
        return nil
    }
    
    /*
     id
     pp_name
     pp_phone
     pp_country
     pp_address
     pp_fb
     pp_web
     blogger_intro
     */
    func pp_insert(pp_name:String?, pp_phone:String?, pp_country:String?, pp_address:String?, pp_fb:String?, pp_web:String?, pp_blogger_intro:String?, pp_opentime:String?, pp_note:String?, pp_descrip:String?, pp_score:String? ) -> Int {
        var Save_id:String?
        var name:String?
        var phone:String?
        var country:String?
        var address:String?
        var fb:String?
        var web:String?
        var blogger_intro:String?
        var opentime: String?
        var note:String?
        var score:String?
        var descrip:String?

        var coreDataConnect:CoreDataConnect
        if cdc == nil {
            let myContext:NSManagedObjectContext?
            if #available(iOS 10.0, *) {
                myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            } else {
                // Fallback on earlier versions
                myContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            }
            coreDataConnect = CoreDataConnect(context: myContext!)
        } else {
            coreDataConnect = cdc!
        }
        
        let Int_Type_ID = id_generate()
        Save_id = String(Int_Type_ID)
        
        if pp_name == nil { name = "空" }
        else { name = pp_name }

        if pp_phone == nil { phone = "空" }
        else { phone = pp_phone }

        if pp_country == nil { country = "空" }
        else { country = pp_country }

        if pp_address == nil { address = "空" }
        else { address = pp_address }

        if pp_fb == nil { fb = "空" }
        else { fb = pp_fb }
        
        if pp_web == nil { web = "空" }
        else { web = pp_web }
        
        if pp_blogger_intro == nil { blogger_intro = "空" }
        else { blogger_intro = pp_blogger_intro }
        
        if pp_opentime == nil { opentime = " " }
        else { opentime = pp_opentime }
        
        if pp_note == nil { note = "空" }
        else { note = pp_note }
        
        if pp_descrip == nil { descrip = " " }
        else { descrip = pp_descrip }
        
        if pp_score == nil { score = "0" }
        else { score = pp_score }

        // insert
        let insertResult = coreDataConnect.insert(
            myEntityName, attributeInfo: [
                "id" : Save_id!,
                "pp_name" : name!,
                "pp_phone" : phone!,
                "pp_country" : country!,
                "pp_address" : address!,
                "pp_fb" : fb!,
                "pp_web" : web!,
                "blogger_intro" : blogger_intro!,
                "pp_opentime" : opentime!,
                "pp_note" : note!,
                "pp_descrip" : descrip!,
                "pp_score" : score!
            ])
        if insertResult && debug == 1 {
            print("新增資料成功")
            print("ID:",Save_id!)
            print("name:",name!)
            print("phone:",phone!)
            print("country:",country!)
            print("address",address!)
            print("fb",fb!)
            print("web",web!)
            print("blogger_intro",blogger_intro!)
            print("opentime",opentime!)
            print("note", note!)
            print("score", score!)
        }

        return Int_Type_ID
    }
    
    func pp_updateStatus(id:String!, pp_status:String!) -> Bool
    {
        var coreDataConnect:CoreDataConnect
        if cdc == nil {
            let myContext:NSManagedObjectContext?
            if #available(iOS 10.0, *) {
                myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            } else {
                // Fallback on earlier versions
                myContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            }
            coreDataConnect = CoreDataConnect(context: myContext!)
        } else {
            coreDataConnect = cdc!
        }
        var predicate:String? = "id="
        
        predicate = predicate! + id
        
        let updateResult = coreDataConnect.update(myEntityName, predicate: predicate, attributeInfo: [
            "pp_status" : pp_status
            ])
        if updateResult {
            if debug == 1 {
                print("pp_update: successful")
            }
            return true
        }
        if debug == 1 {
            print("pp_update: failure")
        }
        return false
    }
    
    //func pp_update(id:String!, pp_name:String!, pp_phone:String!, pp_country:String!, pp_address:String!, pp_fb:String!, pp_web:String!, pp_blogger_intro:String!) -> Bool
    func pp_update(id:String!, pp_name:String!, pp_phone:String!, pp_country:String!, pp_address:String!, pp_fb:String!, pp_web:String!, pp_blogger_intro:String!, pp_opentime:String!, pp_note:String!, pp_descrip:String!, pp_score:String!) -> Bool
    {
        var name:String?
        var phone:String?
        var country:String?
        var address:String?
        var fb:String?
        var web:String?
        var blogger_intro:String?
        var opentime:String?
        var note:String?
        var descrip:String?
        var score:String?
        if debug == 1 {
            print("pp_update: pp_update .. first 1")
        }
        var coreDataConnect:CoreDataConnect
        if cdc == nil {
            let myContext:NSManagedObjectContext?
            if #available(iOS 10.0, *) {
                myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            } else {
                // Fallback on earlier versions
                myContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            }
            coreDataConnect = CoreDataConnect(context: myContext!)
        } else {
            coreDataConnect = cdc!
        }
        var predicate:String? = "id="
        if self.debug == 1 {
            print("db_debug : prepare db ready...")
        }
        predicate = predicate! + id
        
        if pp_name == nil { name = "空" }
        else { name = pp_name }
        
        if pp_phone == nil { phone = "空" }
        else { phone = pp_phone }
        
        if pp_country == nil { country = "空" }
        else { country = pp_country }
        
        if pp_address == nil { address = "空" }
        else { address = pp_address }
        
        if pp_fb == nil { fb = "空" }
        else { fb = pp_fb }
        
        if pp_web == nil { web = "空" }
        else { web = pp_web }
        
        if pp_blogger_intro == nil { blogger_intro = "空" }
        else { blogger_intro = pp_blogger_intro }
        
        if pp_opentime == nil { opentime = "空" }
        else { opentime = pp_opentime }
        
        if pp_note == nil { note = "空" }
        else { note = pp_note }
        
        if pp_descrip == nil { descrip = "空" }
        else { descrip = pp_descrip }
        
        if pp_score == nil { score = "0" }
        else { score = pp_score }
        if debug == 1 {
            print("pp_update: id:",id!, " name:",name!, " phone:",phone!, " country:",country!," address:",address!, "fb: ", fb!, " web:",web!, " blogger:",blogger_intro!, " note:", note!, " score:", score!)
        }
        let updateResult = coreDataConnect.update(myEntityName, predicate: predicate, attributeInfo: [
            "pp_name" : name!,
            "pp_phone" : phone!,
            "pp_country" : country!,
            "pp_address" : address!,
            "pp_fb" : fb!,
            "pp_web" : web!,
            "blogger_intro" : blogger_intro!,
            "pp_opentime" : opentime!,
            "pp_note" : note!,
            "pp_descrip" : descrip!,
            "pp_score" : score!
            ])
        if updateResult {
            if debug == 1 {
                print("pp_update: successful")
            }
            return true
        }
        if debug == 1 {
            print("pp_update: failure")
        }
        return false
    }
    
    func pp_delete(id:String, ppName:String) -> Bool
    {
        // TODO - delete single pp and release ID
        if debug == 1 {
            print("pp_delete: start -> ", ppName)
        }
        var coreDataConnect:CoreDataConnect
        if cdc == nil {
            let myContext:NSManagedObjectContext?
            if #available(iOS 10.0, *) {
                myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            } else {
                // Fallback on earlier versions
                myContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            }
            coreDataConnect = CoreDataConnect(context: myContext!)
        } else {
            coreDataConnect = cdc!
        }
        var predicate:String? = "id="
        predicate = predicate! + id

        //func delete(_ myEntityName:String, predicate:String?)
        let deleteResult = coreDataConnect.delete(myEntityName, predicate: predicate)
        if deleteResult
        {
            if debug == 1 {
                print("pp_delete: delete successful")
            }
            return true
        }
        if debug == 1 {
            print("pp_delete: delete failure")
        }
        return false
    }
    
    
    func id_save(seqID:Int) -> Int
    {
        // TODO - re-define index ID and cache all IDs
        let myUserDefaults = UserDefaults.standard
        myUserDefaults.set(seqID, forKey: "idSeq")
        myUserDefaults.synchronize()
        
        var seq = 0
        if let idSeq = myUserDefaults.object(forKey: "idSeq") as? Int {
            seq = idSeq + 1
        }

        return (seq)
    }
    
    func ppCheck(nameStr:String) -> Bool
    {
        var coreDataConnect:CoreDataConnect
        if cdc == nil {
            let myContext:NSManagedObjectContext?
            if #available(iOS 10.0, *) {
                myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            } else {
                // Fallback on earlier versions
                myContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            }
            coreDataConnect = CoreDataConnect(context: myContext!)
        } else {
            coreDataConnect = cdc!
        }
        let selectResult = coreDataConnect.retrieve(myEntityName, predicate: nil, sort: [["id":true]], limit: nil)
        if let results = selectResult {
            for result in results {
                let db_name = result.value(forKey: "pp_name") as! String
                if (db_name == nameStr)
                {
                    return false
                }
            }
        }
        
        return true
    }
    
    func id_generate() -> Int
    {
        var ID:Int = 0
        var coreDataConnect:CoreDataConnect
        if cdc == nil {
            let myContext:NSManagedObjectContext?
            if #available(iOS 10.0, *) {
                myContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            } else {
                // Fallback on earlier versions
                myContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
            }
            coreDataConnect = CoreDataConnect(context: myContext!)
        } else {
            coreDataConnect = cdc!
        }
        
        // check default data
        // select
        let selectResult = coreDataConnect.retrieve(myEntityName, predicate: nil, sort: [["id":true]], limit: nil)
        if selectResult == nil
        {
            return ID
        }
        ID = 1
        if let results = selectResult {
            for result in results {
                let id_using = result.value(forKey: "id") as! Int
                if (ID == id_using)
                {
                    ID += 1
                }
            }
        }
        if debug == 1 {
            print("use ID : \(ID) ")
        }
        return ID
    }
}
