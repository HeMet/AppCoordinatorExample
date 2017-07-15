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
    
    func start(context: Any) -> Observable<Void> {
        guard let parent = parentCoordinator else {
            return .just()
        }
        return parent.sceneViewController.rx
            .present(sceneViewController, animated: true)
            .do(onNext: { [unowned self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                    self.parent?.stopChild(self, context: none).subscribe()
                })
            })
    }
    
    func stop(context: Any) -> Observable<Void>  {
        guard let parent = parentCoordinator else {
            return .just()
        }
        return parent.sceneViewController.rx
            .dismiss(animated: true)
    }
}
