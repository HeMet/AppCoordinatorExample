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
    
    func start(context: Any) -> Observable<Component> {
        return Observable.combineLatest(
                startChild(StackCoordinator(), context: context),
                startChild(MainCoordinator(), context: context)
            )
            .flatMap { _ -> Observable<Component> in
                self.presentByParent(context: context)
                    .do(onNext: { this in
                        this.onTransition(to: context)
                    })
                    .map { $0 }
            }
    }
    
    func stop(context: Any) -> Observable<Component> {
        guard let presenter = self.parent as? PresentingComponent else {
            notImplemented()
        }
        
        return presenter.dismissChild(self, context: context)
    }
    
    func presentChild(_ childCoordinator: Coordinator, context: Any) -> Observable<Component> {
        return Observable.create { observer in
            let viewController = (self.tabController.viewControllers ?? []) + [childCoordinator.sceneViewController]
            self.tabController.setViewControllers(viewController, animated:true)
            observer.onNext(childCoordinator)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func dismissChild(_ childCoordinator: Coordinator, context: Any) -> Observable<Component> {
        // не случается
        return .just(childCoordinator)
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
