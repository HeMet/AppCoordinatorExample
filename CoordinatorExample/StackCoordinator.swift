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
        let common = { (completion: Callback?) in
            if let target = context as? ExampleTarget, target.example == .stackExample {
                for _ in 0..<max(1, target.stackItems) {
                    self.addElement()
                }
            } else {
                self.addElement()
            }
            completion?(self)
        }
        
        if let presenter = parent as? PresentingComponent {
            presenter.presentChild(childCoordinator: self, context: context) { _ in
                common(completion)
            }
        } else {
            notImplemented()
        }
    }
    
    func stop(context: Any, completion: Callback?) {
        if let presenter = parentCoordinator as? PresentingComponent {
            presenter.dismissChild(childCoordinator: self, context: context, completion: completion)
        } else {
            completion?(self)
        }
    }

    func addElement() {
        guard children.count < 3 else {
            let target = ExampleTarget(example: .modalExample, stackItems: 1)
            transit(to: target)
            return
        }
        
        let child = makeChildCoordinator()
        startChild(child, completion: nil)
    }
    
    func makeChildCoordinator() -> ChildCoordinator {
        let child = ChildCoordinator(colorSeed: children.count)
        child.output = self
        return child
    }
    
    func removeChild(coordinator: Coordinator) {
        stopChild(identifier: coordinator.identifier, completion: nil)
    }
    
    func presentChild(childCoordinator coordinator: Coordinator, context: Any, completion: Callback?) {
        let childScene = coordinator.sceneViewController

        stackViewController.addChildViewController(childScene)
        stackViewController.stackView.addArrangedSubview(childScene.view)

        childScene.didMove(toParentViewController: stackViewController)
        
        completion?(self)
    }
    
    func dismissChild(childCoordinator coordinator: Coordinator, context: Any, completion: Callback?) {
        coordinator.sceneViewController.willMove(toParentViewController: nil)
        stackViewController.stackView.removeArrangedSubview(coordinator.sceneViewController.view)
        coordinator.sceneViewController.removeFromParentViewController()
        
        completion?(self)
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
                    stopChild(identifier: id, completion: nil)
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
