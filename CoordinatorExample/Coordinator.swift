//
//  Coordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 12.03.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

/*
 Основной блок для организации приложения.
 Вместе с другими компонентами образует древовидную структуру.
 */
protocol Component: class {
    typealias Callback = (Component) -> Void
    
    var identifier: String { get }
    
    weak var parent: Component? { get set }
    var children: [String: Component] { get set }
    
    func start(completion: Callback?)
    func stop(completion: Callback?)
    
    func startChild(_ coordinator: Component, completion: Callback?)
    func stopChild(identifier: String, completion: Callback?)
    
    func childFinished(identifier: String)
}

/*
 Координатор - это компонент, который координирует работу
 представления (View) и модели (Model)
 */
protocol Coordinator: Component {
    var sceneViewController: UIViewController { get }
}

extension Component {
    var identifier: String { return String(describing: type(of: self)) }
    
    func startChild(_ coordinator: Component, completion: Callback?) {
        children[coordinator.identifier] = coordinator
        coordinator.parent = self
        coordinator.start(completion: completion)
    }
    
    func stopChild(identifier: String, completion: Callback?) {
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
