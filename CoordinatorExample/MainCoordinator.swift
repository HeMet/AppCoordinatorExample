//
//  MainCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 20.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit
import RxSwift

// how to push data from Coordinator to ViewControllers?
class MainCoordinator: CoordinatorProps, Coordinator {
    var sceneViewController: UIViewController {
        return navigator.sceneViewController
    }
    
    var navigator: MainNavigator!
    
    // sort of view model
    var selectedId: String?
    
    override init() {
        super.init()
        navigator = MainNavigator(coordinator: self)
    }
    
    func start(context: Any) -> Observable<Component> {
        navigator.presentMaster { masterVC in
            
        }
        
        if let presenter = self.parent as? PresentingComponent {
            return presenter.presentChild(childCoordinator: self, context: context)
        } else {
            notImplemented()
        }
    }
    
    func stop(context: Any) -> Observable<Component> {
        if let presenter = parentCoordinator as? PresentingComponent {
            return presenter.dismissChild(childCoordinator: self, context: context)
        } else {
            return .just(self)
        }
    }
    
    func detailsTapped() {
        selectedId = UUID().uuidString
        let modal = ModalCoordinator()
        startChild(modal, context: none).subscribe()
//        transit(to: ExampleTarget(example: .stackExample, stackItems: 3))
    }
}

extension MainCoordinator: Transitable {
    func performTransition(to: Any) {
        // ничего
    }
    
    static func canTransit(to target: Any) -> Bool {
        if let example = target as? ExampleTarget {
            return example.example == .modalExample
        }
        return false
    }
}
