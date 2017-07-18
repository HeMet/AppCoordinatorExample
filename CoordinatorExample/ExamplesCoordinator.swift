//
//  ExamplesCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 11.07.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ExamplesCoordinator: CoordinatorProps, PresentingCoordinator {
    fileprivate let tabController = UITabBarController()
    
    var sceneViewController: UIViewController {
        return tabController
    }
    
    func start(context: Any) -> Observable<Void> {
        return Observable.combineLatest(
                startChild(StackCoordinator(), context: context),
                startChild(MainCoordinator(), context: context)
            )
            .flatMap { _ -> Observable<Void> in
                self.presentByParent(context: context)
                    .do(onNext: { [unowned self] in
                        self.onTransition(to: context)
                    })
            }
    }
    
    func stop(context: Any) -> Observable<Void> {
        guard let presenter = self.parent as? PresentingComponent else {
            notImplemented()
        }
        
        return presenter.dismissChild(self, context: context)
    }
    
    func presentChild(_ childCoordinator: Coordinator, context: Any) -> Observable<Void> {
        return .perform {
            let viewController = (self.tabController.viewControllers ?? []) + [childCoordinator.sceneViewController]
            self.tabController.setViewControllers(viewController, animated:true)
        }
    }
    
    func dismissChild(_ childCoordinator: Coordinator, context: Any) -> Observable<Void> {
        // не случается
        return .just()
    }
}

extension ExamplesCoordinator: Transitable {
    static func canTransit(to target: Any) -> Bool {
        return StackCoordinator.canTransit(to: target) || MainCoordinator.canTransit(to: target)
    }
    
    func performTransition(to: Any) {
        onTransition(to: to)
    }
    
    func onTransition(to: Any) {
        if MainCoordinator.canTransit(to: to) {
            self.tabController.selectedIndex = 1
        } else if StackCoordinator.canTransit(to: to) {
            self.tabController.selectedIndex = 0
        }
    }
}
