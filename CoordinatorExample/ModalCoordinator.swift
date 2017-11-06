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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: { [weak self] in
            if let `self` = self {
                self.parent?.disconnect(self, context: 0, completion: nil)
            }
        })
        
        completion?(self)
    }
    
    func stop(completion: Callback?) {
        completion?(self)
    }
}
