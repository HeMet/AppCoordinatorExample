//
//  Coordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 12.03.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

typealias CoordinatorCallback = (Coordinator) -> Void

protocol Coordinator: class {
    var identifier: String { get }
    
    weak var parent: Coordinator? { get set }
    var children: [String: Coordinator] { get set }
    
    var sceneViewController: UIViewController { get }
    
    func start(completion: CoordinatorCallback?)
    func stop(completion: CoordinatorCallback?)
    
    func startChild(_ coordinator: Coordinator, completion: CoordinatorCallback?)
    func stopChild(identifier: String, completion: CoordinatorCallback?)
    
    func childFinished(identifier: String)
}

protocol PresentingCoordinator: Coordinator {
    func present(childCoordinator: Coordinator)
    func dismiss(childCoordinator: Coordinator)
}

extension Coordinator {
    var identifier: String { return String(describing: type(of: self)) }
    
    func startChild(_ coordinator: Coordinator, completion: CoordinatorCallback?) {
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

extension PresentingCoordinator {
    func presentChild(_ coordinator: Coordinator, completion: CoordinatorCallback? = nil) {
        startChild(coordinator) { [weak self] child in
            self?.present(childCoordinator: child)
            completion?(child)
        }
    }
    
    func dismissChild(identifier: String, completion: CoordinatorCallback? = nil) {
        stopChild(identifier: identifier) { [weak self] child in
            self?.dismiss(childCoordinator: child)
            completion?(child)
        }
    }
}
