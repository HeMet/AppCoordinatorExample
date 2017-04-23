//
//  StackCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 22.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

class StackCoordinator: CoordinatorProps, Coordinator {
    
    var sceneViewController: UIViewController { return stackViewController }
    let stackViewController = StackViewController()
    
    func start(completion: CoordinatorCallback?) {
        addElement()
        completion?(self)
    }
    
    func stop(completion: CoordinatorCallback?) {
        completion?(self)
    }

    func addElement() {
        let child = makeChildCoordinator()
        
        startChild(child) { [weak self] childCoordinator in
            self?.addChildSceneViewController(childCoordinator)
        }
    }
    
    func makeChildCoordinator() -> ChildCoordinator {
        let child = ChildCoordinator(colorSeed: children.count)
        child.output = self
        return child
    }
    
    func removeChild(coordinator: Coordinator) {
        stopChild(identifier: coordinator.identifier) { [weak self] childCoordinator in
            self?.removeChildSceneViewController(childCoordinator)
        }
    }
    
    func addChildSceneViewController(_ coordinator: Coordinator) {
        let childScene = coordinator.sceneViewController

        stackViewController.addChildViewController(childScene)
        stackViewController.stackView.addArrangedSubview(childScene.view)

        childScene.didMove(toParentViewController: stackViewController)
    }
    
    func removeChildSceneViewController(_ coordinator: Coordinator) {
        coordinator.sceneViewController.willMove(toParentViewController: nil)
        stackViewController.stackView.removeArrangedSubview(coordinator.sceneViewController.view)
        coordinator.sceneViewController.removeFromParentViewController()
    }
}

extension StackCoordinator: ChildCoordinatorOutput {
    func childCoordinatorAdd(_ sender: ChildCoordinator) {
        addElement()
    }
    
    func childCoordinatorRemove(_ sender: ChildCoordinator) {
        removeChild(coordinator: sender)
    }
}

class StackViewController: UIViewController {
    var coordinator: StackCoordinator!
    
    var stackView: UIStackView {
        return view as! UIStackView
    }
    
    override func loadView() {
        let _view = UIStackView()
        _view.axis = .vertical
        _view.distribution = .fillEqually
        view = _view
    }
}
