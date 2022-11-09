//
//  AppDelegate.swift
//  ATMultiBlocksDemo
//
//  Created by abiaoyo on 2022/11/9.
//

import UIKit
import ATMultiBlocks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        ATMultiBlocks.log = { log in
            print(log)
        }
        
        return true
    }

}

