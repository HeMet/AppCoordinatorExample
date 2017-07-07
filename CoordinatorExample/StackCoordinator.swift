//
//  StackCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 22.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

class StackCoordinator: CoordinatorProps, PresentingCoordinator {
    
    var sceneViewController: UIViewController { return stackViewController }
    let stackViewController = StackViewController()
    
    func start(context: Any, completion: Callback?) {
        if let target = context as? ExampleTarget, target.example == .stackExample {
            for _ in 0..<max(1, target.stackItems) {
                addElement()
            }
        } else {
            addElement()
        }
        completion?(self)
    }
    
    func stop(context: Any, completion: Callback?) {
        completion?(self)
    }

    func addElement() {
        guard children.count < 3 else {
            let target = ExampleTarget(example: .modalExample, stackItems: 1)
            transit(to: target)
            return
        }
        
        let child = makeChildCoordinator()
        presentChild(child)
    }
    
    func makeChildCoordinator() -> ChildCoordinator {
        let child = ChildCoordinator(colorSeed: children.count)
        child.output = self
        return child
    }
    
    func removeChild(coordinator: Coordinator) {
        dismissChild(identifier: coordinator.identifier)
    }
    
    func present(childCoordinator coordinator: Coordinator, context: Any) {
        let childScene = coordinator.sceneViewController

        stackViewController.addChildViewController(childScene)
        stackViewController.stackView.addArrangedSubview(childScene.view)

        childScene.didMove(toParentViewController: stackViewController)
    }
    
    func dismiss(childCoordinator coordinator: Coordinator, context: Any) {
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

extension StackCoordinator: Transitable {
    func performTransition(to target: Any) {
        if let target = target as? ExampleTarget, target.example == .stackExample {
            loop: while true {
                switch children.count.compare(target.stackItems) {
                case .orderedSame:
                    break loop
                case .orderedAscending:
                    let id = children.values.first!.identifier
                    dismissChild(identifier: id)
                case .orderedDescending:
                    addElement()
                }
            }
        }
    }
    
    static func canTransit(to target: Any) -> Bool {
        if let example = target as? ExampleTarget {
            return example.example == .stackExample
        }
        return false
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

extension Int {
    func compare(_ value: Int) -> ComparisonResult {
        if self == value {
            return .orderedSame
        }
        if self > value {
            return .orderedDescending
        }
        return .orderedAscending
    }
}
