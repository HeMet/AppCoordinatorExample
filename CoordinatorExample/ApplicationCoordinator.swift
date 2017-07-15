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
            .map { _ in Void() }
    }
    
    func makeChild(mode: Mode) -> ExamplesCoordinator {
        return ExamplesCoordinator()
    }
    
    func stop(context: Any) -> Observable<Void> {
        return .just()
    }
    
    func presentChild(_ childCoordinator: Coordinator, context: Any) -> Observable<Component> {
        return .perform {
            self.window.rootViewController = childCoordinator.sceneViewController
            self.window.makeKeyAndVisible()
            return self
        }
    }
    
    func dismissChild(_ childCoordinator: Coordinator, context: Any) -> Observable<Component> {
        return .just(self)
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
        
        let _child = children.first!.value
        stopAnyChild(_child, context: none)
            .flatMap { [unowned self] _ -> Observable<ExamplesCoordinator> in
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
