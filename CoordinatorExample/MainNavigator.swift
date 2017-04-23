//
//  MainRouter.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 20.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

class MainNavigator {
    let assembly = MainAssembly()
    let coordinator: MainCoordinator
    let sceneViewController: UINavigationController
    
    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
        sceneViewController = assembly.sceneViewController()
    }
    
    func presentMaster(hook: (MasterViewController) -> Void) {
        let masterVC = assembly.masterViewController()
        masterVC.coordinator = coordinator
        hook(masterVC)
        sceneViewController.pushViewController(masterVC, animated: true)
    }
    
    func presentDetails(hook: (DetailViewController) -> Void) {
        let detailsVC = assembly.detailViewController()
        detailsVC.coordinator = coordinator
        hook(detailsVC)
        sceneViewController.pushViewController(detailsVC, animated: true)
    }
    
    var presentedMaster: MasterViewController? {
        return nil
    }
    
    var presentedDetails: DetailViewController? {
        return nil
    }
}
