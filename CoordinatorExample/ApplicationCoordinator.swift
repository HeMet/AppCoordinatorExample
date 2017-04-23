//
//  ApplicationCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 23.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

class ApplicationCoordinator: CoordinatorProps, PresentingComponent {

    enum Mode {
        case modalExample
        case stackExample
    }
    
    let window: UIWindow
    let mode: Mode
    
    init(window: UIWindow, mode: Mode) {
        self.window = window
        self.mode = mode
    }
    
    func start(completion: CoordinatorCallback?) {
        let child: Coordinator
        switch mode {
        case .modalExample:
            child = MainCoordinator()
        case .stackExample:
            child = StackCoordinator()
        }
        
        presentChild(child) { [weak self] coordinator in
            if let `self` = self {
                completion?(self)
            }
        }
    }
    
    func stop(completion: CoordinatorCallback?) {
        completion?(self)
    }
    
    func present(childCoordinator: Coordinator) {
        window.rootViewController = childCoordinator.sceneViewController
        window.makeKeyAndVisible()
    }
    
    func dismiss(childCoordinator: Coordinator) {
        // ничего
    }
}
