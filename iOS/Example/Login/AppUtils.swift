//
//  appUtil.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/24/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import UIKit
import ImSDK_Plus

// IMSDK APNS ID
#if DEBUG
    let timSdkBusiId: UInt32 = 18_069
#else
    let timSdkBusiId: UInt32 = 18_070
#endif

class AppUtils: NSObject {
    @objc static let shared = AppUtils()
    private override init() {}
    
    @objc var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    @objc var curUserId: String {
        #if NOT_LOGIN
            return ""
        #else
            return V2TIMManager.sharedInstance()?.getLoginUser() ?? ""
        #endif
    }

    //MARK: - UI
    @objc func showMainController() {
        appDelegate.showMainViewController()
    }
    
    @objc func alertUserTips(_ vc: UIViewController) {
        
    }
}
