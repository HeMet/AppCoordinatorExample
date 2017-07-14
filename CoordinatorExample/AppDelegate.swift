//
//  AppDelegate.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 12.03.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var appCoordinator: ApplicationCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let wnd = UIWindow(frame: UIScreen.main.bounds)
        window = wnd
        
        appCoordinator = ApplicationCoordinator(window: wnd, mode: .stackExample)
        appCoordinator.start(context: none).subscribe()
        
        return true
    }
}

func notImplemented() -> Never {
    fatalError("Not implemented yet.")
}
