//
//  GoogleAD_Helper.swift
//  Makeda
//
//  Created by Brian on 2019/8/11.
//  Copyright © 2019 breadcrumbs.tw. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import GoogleMobileAds
import CoreLocation

class GoogleAD_Helper {
    var bannerView: GADBannerView?
    var veiwCtrl:UIViewController?
    var view :UIView?

    func loadGoogleAD(viewController: UIViewController) -> GADBannerView {
        let request = GADRequest()
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView!.adUnitID = "TODO"
        //bannerView!.delegate = self
        bannerView!.rootViewController = viewController
        bannerView!.load(request)
        
        return bannerView!
    }
}
