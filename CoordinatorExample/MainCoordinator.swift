//
//  MainCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 20.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

// how to push data from Coordinator to ViewControllers?
class MainCoordinator: Coordinator {
    var sceneViewController: UIViewController {
        return navigator.sceneViewController
    }
    
    weak var parent: Coordinator?
    var children: [String: Coordinator] = [:]
    
    var navigator: MainNavigator!
    
    // sort of view model
    var selectedId: String?
    
    init() {
        navigator = MainNavigator(coordinator: self)
    }
    
    func start(completion: CoordinatorCallback?) {
        navigator.presentMaster { masterVC in
            
        }
    }
    
    func stop(completion: CoordinatorCallback?) {
        
    }
    
    func detailsTapped() {
        selectedId = UUID().uuidString
//        navigator.presentDetails { detailsVC in
//            
//        }
        let modal = ModalCoordinator()
        startChild(modal, completion: nil)
    }
}
