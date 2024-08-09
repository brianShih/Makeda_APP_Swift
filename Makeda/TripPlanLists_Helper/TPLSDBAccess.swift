//
//  TPLSDBAccess.swift
//  Makeda
//
//  Created by Brian on 2019/11/14.
//  Copyright © 2019 breadcrumbs.tw. All rights reserved.
//

import CoreData
import UIKit

class TPLSDBAccess {
    let debug = 0
    private var cdc:CoreDataConnect?
    private let myEntityName = "TRIPPLANLISTS"
    var default_db_enable = false
    let maxIndex = 1000
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
                }
            }
        }

    }
    
    func default_setup(){
        if debug == 1 {
            print("default_setup: Start")
        }
    }
    

    public func getAll() -> [NSManagedObject]?
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
    
    public func updateContent(id: String, name: String, contentJsonFormat: String!) -> Bool {
        if id.isEmpty || name.isEmpty || contentJsonFormat.isEmpty { return false }
        
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
        
        let updateResult = coreDataConnect.update(myEntityName, predicate: predicate, attributeInfo: [
            "planname" : name,
            "contentJsonFormat" : contentJsonFormat!
            ])
        if updateResult {
            if debug == 1 {
                print("updateContent: successful")
            }
            return true
        }
        if debug == 1 {
            print("updateContent: failure")
        }
        return false
    }
    
    public func searchByName(name:String) -> NSManagedObject?
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

        var cacheList: NSManagedObject?

        // check default data
        // select
        let selectResult = coreDataConnect.retrieve(myEntityName, predicate: nil, sort: [["id":true]], limit: nil)
        if selectResult?.count == 0
        {
            if debug == 1 {
                print("searchByName: db connect fail")
            }
            return nil
        }
        if let results = selectResult {
            for result in results {
                if name == result.value(forKey: "planname") as? String
                {
                    cacheList = result
                    return cacheList
                }
            }
        }
        if debug == 1 {
            print("pp_searchByCity --- nil")
        }
        return nil
        
    }
    
    func insert(planname: String!, author: String!, grouplist:String!, contentJsonFormat: String!, log: String!) -> Int {
        var l_planname:String?
        var l_author:String?
        var l_grouplist:String?
        var l_content:String?
        var l_log:String?
        
        if planname == nil { return -1 } // planname cannot null
        else { l_planname = planname }

        if author == nil { l_author = "" }
        else { l_author = author }
        
        if grouplist == nil { l_grouplist = "" }
        else { l_grouplist = grouplist }
        
        if contentJsonFormat == nil { l_content = "" }
        else { l_content = contentJsonFormat }
        
        if log == nil { l_log = "" }
        else { l_log = log }

        var coreDataConnect:CoreDataConnect
        let Int_Type_ID = id_generate()
        let Save_id = String(Int_Type_ID)
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

        let insertResult = coreDataConnect.insert(
            myEntityName, attributeInfo: [
                "id" : Save_id,
                "planname" : l_planname!,
                "author" : l_author!,
                "grouplist" : l_grouplist!,
                "contentJsonFormat" : l_content!,
                "log" : l_log!
            ])
        if insertResult && debug == 1 {
            print("新增資料成功")
            print("ID:",Save_id)
        }

        return Int_Type_ID
    }
    
    func update(id: String!, planname: String!, author: String!, grouplist:String!, contentJsonFormat: String!, log: String!) -> Bool {
        var l_planname:String?
        var l_author:String?
        var l_grouplist:String?
        var l_content:String?
        var l_log:String?
        
        if debug == 1 {
            print("pp_update: pp_update .. first 1")
        }
        if planname == nil { return false } // planname cannot null
        else { l_planname = planname }

        if author == nil { l_author = "" }
        else { l_author = author }
        
        if grouplist == nil { l_grouplist = "" }
        else { l_grouplist = grouplist }
        
        if contentJsonFormat == nil { l_content = "" }
        else { l_content = contentJsonFormat }
        
        if log == nil { l_log = "" }
        else { l_log = log }
        
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
        
        let updateResult = coreDataConnect.update(myEntityName, predicate: predicate, attributeInfo: [
            "planname" : l_planname!,
            "author" : l_author!,
            "grouplist" : l_grouplist!,
            "contentJsonFormat" : l_content!,
            "log" : l_log!
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
    
    func delete(id:String, planname:String) -> Bool
    {
        // TODO - delete single pp and release ID
        if debug == 1 {
            print("pp_delete: start -> ", planname)
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

