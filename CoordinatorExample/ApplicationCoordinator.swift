//
//  ApplicationCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 23.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit
import RxSwift

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
    
    func start(context: Any) -> Observable<Void> {
        let child = makeChild(mode: mode)
        
        return startChild(child, context: ExampleTarget(example: mode, stackItems: 3, showModalScreen: false))
    }
    
    func makeChild(mode: Mode) -> ExamplesCoordinator {
        return ExamplesCoordinator()
    }
    
    func stop(context: Any) -> Observable<Void> {
        return .just()
    }
    
    func presentChild(_ childCoordinator: Coordinator, context: Any) -> Observable<Void> {
        return .perform {
            self.window.rootViewController = childCoordinator.sceneViewController
            self.window.makeKeyAndVisible()
        }
    }
    
    func dismissChild(_ childCoordinator: Coordinator, context: Any) -> Observable<Void> {
        return .just()
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
        
        let _child = children.all.first!
        stopChild(_child, context: none)
            .flatMap { [unowned self] _ -> Observable<Void> in
                let newChild = self.makeChild(mode: exTarget.example)
                return self.startChild(newChild, context: target)
            }
            .subscribe()
    }
}

struct ExampleTarget {
    let example: ApplicationCoordinator.Mode
    let stackItems: Int
    let showModalScreen: Bool
}
