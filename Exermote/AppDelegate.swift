//
//  AppDelegate.swift
//  Exermote
//
//  Created by Stephan Lerner on 14.01.17.
//  Copyright © 2017 Stephan Lerner. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        let arguments = ProcessInfo.processInfo.arguments
//        let UITest = arguments.contains("UITest")
//        if UITest {
//            
//            let dummyDataString = ["5d010199 d4b0e43c 5cec1f04 018871ad 21183200 0c73",
//                                   "5d010123 6085e8b1 f26b2a04 858de134 d6e12200 0c53",
//                                   "5d0101a5 2f372de9 5bcf9e04 01b941ac 07c8e300 0e53"]
//            
//            let dummyData = [[["kCBAdvDataManufacturerData": dummyDataString[0].dataFromHexadecimalString()],-57],
//                             [["kCBAdvDataManufacturerData": dummyDataString[1].dataFromHexadecimalString()],-42],
//                             [["kCBAdvDataManufacturerData": dummyDataString[2].dataFromHexadecimalString()],-61]]
//            
//            for data in dummyData {
//                BLEManager.instance.updateMeasurementPoints(advertisementData: data[0] as! [String : Any], rssi: data[1] as! NSNumber)
//            }
//            
//            let delay = DispatchTime.now() + 1/UI_MAXIMUM_UPDATE_FREQUENCY
//            DispatchQueue.main.asyncAfter(deadline: delay) {
//                for data in dummyData {
//                    BLEManager.instance.updateMeasurementPoints(advertisementData: data[0] as! [String : Any], rssi: data[1] as! NSNumber)
//                }
//            }
//        }
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore  {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            
            UserDefaults.standard.set(RECORDING_DURATION_MAXIMUM, forKey: USER_DEFAULTS_RECORDING_DURATION)
            UserDefaults.standard.set(RECORDING_FREQUENCY_INITIAL, forKey: USER_DEFAULTS_RECORDING_FREQUENCY)
            
            for key in USER_DEFAULTS_RECORDED_DATA {
                UserDefaults.standard.set(true, forKey: key)
            }
            
            UserDefaults.standard.set(true, forKey: USER_DEFAULTS_SHOW_FREQUENCY_ALERT)
            UserDefaults.standard.set(true, forKey: USER_DEFAULTS_SHOW_ICLOUD_ALERT)
        }
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGray, NSFontAttributeName: UIFont(name: "NotoSans", size: 20)!]
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

