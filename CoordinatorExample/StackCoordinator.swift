//
//  StackCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 22.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

class StackCoordinator: CoordinatorProps, Coordinator, CreatableComponent {
    
    var sceneViewController: UIViewController { return stackViewController }
    let stackViewController = StackViewController()
    
    required init(parameters: Any?) {
        super.init()
    }
    
    func start(completion: Callback?) {
        addElement()
        completion?(self)
    }
    
    func stop(completion: Callback?) {
        completion?(self)
    }

    func addElement() {
        travel(to: .child, context: children.count)
    }
    
    func removeChild(coordinator: Coordinator) {
        disconnect(coordinator, context: 0, completion: nil)
    }
    
    func connectingChildComponent(_ component: Component) {
        let child = component as! ChildCoordinator
        child.output = self
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
    
    func addArrangedViewController(_ viewController: UIViewController) {
        addChildViewController(viewController)
        stackView.addArrangedSubview(viewController.view)
        viewController.didMove(toParentViewController: self)
    }
    
    func removeArrangedViewController(_ viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        stackView.removeArrangedSubview(viewController.view)
        viewController.removeFromParentViewController()
    }
}
