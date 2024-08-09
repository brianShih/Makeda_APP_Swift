//
//  MKPlacemark+Extension.swift
//  Makeda
//
//  Created by Brian on 2019/1/11.
//  Copyright © 2019 breadcrumbs.tw. All rights reserved.
//

import MapKit
import Contacts

extension MKPlacemark {
    var formattedAddress: String? {
        if let addrLines = addressDictionary!["FormattedAddressLines"] as? [String]
        {
            return addrLines[0]
        }
        else
        {
            return ""
        }
    }
}

