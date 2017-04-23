//
//  ModalCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 21.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

class ModalCoordinator: Coordinator {
    
    weak var parent: Coordinator?
    var children: [String: Coordinator] = [:]
    let sceneViewController = UIViewController()
    
    func start(completion: CoordinatorCallback?) {
        parent?.sceneViewController.present(sceneViewController, animated: true) { [weak self] in
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
    
    func stop(completion: CoordinatorCallback?) {
        parent?.sceneViewController.dismiss(animated: true) { [weak self] in
            if let `self` = self {
                completion?(self)
            }
        }
    }
}

extension Optional {
    func applyTo(_ receiver: (Wrapped) -> Void) {
        switch self {
        case .some(let value):
            receiver(value)
        default:
            break
        }
    }
}
