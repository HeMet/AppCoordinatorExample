//
//  ModalCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 21.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

class ModalCoordinator: CoordinatorProps, Coordinator {
    
    let sceneViewController = UIViewController()
    
    func start(completion: Callback?) {
        parentCoordinator?.sceneViewController.present(sceneViewController, animated: true) { [weak self] in
            if let `self` = self {
                completion?(self)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                if let `self` = self {
                    self.parent?.childFinished(identifier: self.identifier)
                }
            })
        }
    }
    
    func stop(completion: Callback?) {
        parentCoordinator?.sceneViewController.dismiss(animated: true) { [weak self] in
            if let `self` = self {
                completion?(self)
            }
        }
    }
}
