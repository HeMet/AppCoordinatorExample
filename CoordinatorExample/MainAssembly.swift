//
//  MainAssembly.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 20.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

class MainAssembly {
    func sceneViewController() -> UINavigationController {
        return UINavigationController()
    }
    
    func masterViewController() -> MasterViewController {
        return MasterViewController()
    }
    
    func detailViewController() -> DetailViewController {
        return DetailViewController()
    }
}

class MasterViewController: UIViewController {
    
    var coordinator: MainCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Master"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Detail", style: .plain, target: self, action: #selector(detailsTapped))
    }
    
    func detailsTapped() {
        coordinator.detailsTapped()
    }
}

class DetailViewController: UIViewController {
    
    var coordinator: MainCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = coordinator.selectedId ?? ""
    }
}
