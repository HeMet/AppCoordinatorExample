//
//  AppDelegate.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 12.03.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var appCoordinator: ApplicationCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let wnd = UIWindow(frame: UIScreen.main.bounds)
        window = wnd
        
        appCoordinator = ApplicationCoordinator(window: wnd, mode: .modalExample)
        appCoordinator.start(completion: nil)
        
        return true
    }
}

