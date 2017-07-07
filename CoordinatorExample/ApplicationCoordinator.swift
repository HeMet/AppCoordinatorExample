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
    
    func start(context: Any, completion: Callback?) {
        let child = makeChild(mode: mode)
        
        presentChild(child) { [weak self] coordinator in
            if let `self` = self {
                completion?(self)
            }
        }
    }
    
    func makeChild(mode: Mode) -> Coordinator {
        switch mode {
        case .modalExample:
            return MainCoordinator()
        case .stackExample:
            return StackCoordinator()
        }
    }
    
    func stop(context: Any, completion: Callback?) {
        completion?(self)
    }
    
    func present(childCoordinator: Coordinator, context: Any) {
        window.rootViewController = childCoordinator.sceneViewController
        window.makeKeyAndVisible()
    }
    
    func dismiss(childCoordinator: Coordinator, context: Any) {
        // ничего
    }
}

extension ApplicationCoordinator: TransitionDispatcher {
    func dispatchTransition(to target: Any) {
        if let child = childFor(target: target) {
            child.performTransition(to: target)
            return
        }
        
        guard let exTarget = target as? ExampleTarget else {
            return
        }
        
        let child = children.first!.value
        dismissChild(identifier: child.identifier) { [unowned self] _ in
            let child = self.makeChild(mode: exTarget.example)
            self.presentChild(child, context: target)
        }
    }
}

struct ExampleTarget {
    let example: ApplicationCoordinator.Mode
    let stackItems: Int
}
