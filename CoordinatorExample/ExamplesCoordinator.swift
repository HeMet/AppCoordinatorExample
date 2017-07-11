//
//  ExamplesCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 11.07.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import Foundation
import UIKit

class ExamplesCoordinator: CoordinatorProps, PresentingCoordinator {
    private let tabController = UITabBarController()
    
    var sceneViewController: UIViewController {
        return tabController
    }
    
    func start(context: Any, completion: Component.Callback?) {
        let example = (context as? ExampleTarget)?.example ?? .stackExample
        
        startChild(StackCoordinator(), context: context) { _ in
            self.startChild(MainCoordinator(), context: context) { _ in
                guard let presenter = self.parent as? PresentingComponent else {
                    notImplemented()
                }
                
                presenter.presentChild(childCoordinator: self, context: context) { _ in
                    switch example {
                    case .modalExample:
                        self.tabController.selectedIndex = 1
                    case .stackExample:
                        self.tabController.selectedIndex = 0
                    }
                    
                    completion?(self)
                }
            }
        }
    }
    
    func stop(context: Any, completion: Component.Callback?) {
        guard let presenter = self.parent as? PresentingComponent else {
            notImplemented()
        }
        
        presenter.dismissChild(childCoordinator: self, context: context, completion: completion)
    }
    
    func presentChild(childCoordinator: Coordinator, context: Any, completion: Callback?) {
        let viewController = (tabController.viewControllers ?? []) + [childCoordinator.sceneViewController]
        tabController.setViewControllers(viewController, animated:true)
        completion?(self)
    }
    
    func dismissChild(childCoordinator: Coordinator, context: Any, completion: Callback?) {
        // не случается
        completion?(self)
    }
}
