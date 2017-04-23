//
//  Router.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 12.03.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

protocol Router: class {
    var childRouters: [Router] { get }
    var coordinator: Coordinator { get }
    
    func present(viewController: UIViewController)
    //func present()
    
    func respondsTo(link: String) -> Bool
}

// Отвечает за навигацию с точностью до координатора
class RootRouter: Router {
    var childRouters: [Router] = []
    var coordinator: SignUpCoordiantor
    
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        self.coordinator = SignUpCoordiantor()
    }
    
    func present(viewController: UIViewController) {
        
    }
    
    func respondsTo(link: String) -> Bool {
        return link == "signUp"
    }
    
    func present(args: SignUpCoordiantor.Step) {
        let vc = coordinator.sceneViewController
        window.rootViewController = vc
        window.makeKeyAndVisible()
        
        (coordinator as! SignUpCoordiantor).start(step: args)
    }
}
