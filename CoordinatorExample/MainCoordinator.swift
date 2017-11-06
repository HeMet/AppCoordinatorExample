//
//  MainCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 20.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

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
    
    func start(completion: Callback?) {
        navigator.presentMaster { masterVC in
        }
        completion?(self)
    }
    
    func stop(completion: Callback?) {
        completion?(self)
    }
    
    func detailsTapped() {
        selectedId = UUID().uuidString
        travel(to: .modal)
    }
}
