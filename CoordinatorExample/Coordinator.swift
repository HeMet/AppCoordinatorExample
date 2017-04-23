//
//  Coordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 12.03.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

typealias CoordinatorCallback = (Component) -> Void

protocol Component: class {
    var identifier: String { get }
    
    weak var parent: Component? { get set }
    var children: [String: Component] { get set }
    
    func start(completion: CoordinatorCallback?)
    func stop(completion: CoordinatorCallback?)
    
    func startChild(_ coordinator: Component, completion: CoordinatorCallback?)
    func stopChild(identifier: String, completion: CoordinatorCallback?)
    
    func childFinished(identifier: String)
}

protocol Coordinator: Component {
    var sceneViewController: UIViewController { get }
}

/*
 Component -> Coordinator
 Coordinator -> Coordinator
 */

protocol PresentingComponent: Component {
    func present(childCoordinator: Coordinator)
    func dismiss(childCoordinator: Coordinator)
}

typealias PresentingCoordinator = PresentingComponent & Coordinator

extension Component {
    var identifier: String { return String(describing: type(of: self)) }
    
    func startChild(_ coordinator: Component, completion: CoordinatorCallback?) {
        children[coordinator.identifier] = coordinator
        coordinator.parent = self
        coordinator.start(completion: completion)
    }
    
    func stopChild(identifier: String, completion: CoordinatorCallback?) {
        guard let child = children[identifier] else {
            fatalError("Child coordinator with identifier \(identifier) not found.")
        }
        
        child.stop { [weak self] coordinator in
            coordinator.parent = nil
            self?.children[identifier] = nil
            completion?(coordinator)
        }
    }
    
    func childFinished(identifier: String) {
        stopChild(identifier: identifier, completion: nil)
    }
}

extension Coordinator {
    var parentCoordinator: Coordinator? {
        return parent as? Coordinator
    }
}

extension PresentingComponent {
    func presentChild(_ coordinator: Coordinator, completion: CoordinatorCallback? = nil) {
        startChild(coordinator) { [weak self] child in
            self?.present(childCoordinator: child as! Coordinator)
            completion?(child)
        }
    }
    
    func dismissChild(identifier: String, completion: CoordinatorCallback? = nil) {
        stopChild(identifier: identifier) { [weak self] child in
            self?.dismiss(childCoordinator: child as! Coordinator)
            completion?(child)
        }
    }
}
