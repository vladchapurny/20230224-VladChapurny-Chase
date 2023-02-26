//
//  AppDelegate.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import UIKit

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //Setting up to use App Delegate instead of Scene Delegate
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Setup
        window?.backgroundColor = UIColor.systemBackground
        window?.rootViewController = UINavigationController(rootViewController: MainViewController())
        window?.makeKeyAndVisible()
        
        return true
    }
}
