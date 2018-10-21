//
//  AppDelegate.swift
//  COMP90018G37
//
//  Created by clefairy on 2018/9/21.
//  Copyright © 2018年 Group_37. All rights reserved.
//


import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UITabBar.appearance().tintColor = .black
        UINavigationBar.appearance().tintColor = .black
        FirebaseApp.configure()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}

