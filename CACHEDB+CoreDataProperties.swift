//
//  CACHEDB+CoreDataProperties.swift
//  Makeda
//
//  Created by Brian on 2017/7/12.
//  Copyright © 2017年 breadcrumbs.tw. All rights reserved.
//

import Foundation
import CoreData


extension CACHEDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CACHEDB> {
        return NSFetchRequest<CACHEDB>(entityName: "CACHEDB")
    }

    @NSManaged public var blogger_intro: String?
    @NSManaged public var pp_address: String?
    @NSManaged public var pp_name: String?
    @NSManaged public var pp_phone: String?
    @NSManaged public var pp_web: String?

}
