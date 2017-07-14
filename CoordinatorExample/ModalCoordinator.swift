//
//  ModalCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 21.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit
import RxSwift

class ModalCoordinator: CoordinatorProps, Coordinator {
    
    let sceneViewController = UIViewController()
    
    func start(context: Any) -> Observable<Component> {
        guard let parent = parentCoordinator else {
            return .just(self)
        }
        return parent.sceneViewController.rx
            .present(sceneViewController, animated: true)
            .map { self }
            .do(onNext: { component in
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                    component.parent?.childFinished(identifier: self.identifier)
                })
            })
    }
    
    func stop(context: Any) -> Observable<Component>  {
        guard let parent = parentCoordinator else {
            return .just(self)
        }
        return parent.sceneViewController.rx
            .dismiss(animated: true)
            .map { self }
    }
}
