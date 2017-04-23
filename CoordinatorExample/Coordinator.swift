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
    
    func startChild<T: Coordinator>(_ coordinator: T, completion: CoordinatorCallback?)
    func stopChild(identifier: String, completion: CoordinatorCallback?)
    
    func childFinished(identifier: String)
}

extension Coordinator {
    var identifier: String { return String(describing: type(of: self)) }
    
    func startChild<T: Coordinator>(_ coordinator: T, completion: CoordinatorCallback?) {
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
