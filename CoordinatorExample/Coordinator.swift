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
    
    func start(context: Any, completion: Callback?)
    func stop(context: Any, completion: Callback?)
    
    func startChild(_ coordinator: Component, context: Any, completion: Callback?)
    func stopChild(identifier: String, context: Any, completion: Callback?)
    
    func childFinished(identifier: String)
}

/*
 Координатор - это компонент, который координирует работу
 представления (View) и модели (Model)
 */
protocol Coordinator: Component {
    var sceneViewController: UIViewController { get }
}

/*
 Отображающий компонент - это компонент, который сам решает, 
 как отображать дочерние координаторы. При этом он сам может являться координатором,
 но не обязательно.
 */
protocol PresentingComponent: Component {
    func presentChild(childCoordinator: Coordinator, context: Any, completion: Callback?)
    func dismissChild(childCoordinator: Coordinator, context: Any, completion: Callback?)
}

typealias PresentingCoordinator = PresentingComponent & Coordinator

extension Component {
    var identifier: String { return String(describing: type(of: self)) }
    
    func startChild(_ coordinator: Component, context: Any = none, completion: Callback?) {
        children[coordinator.identifier] = coordinator
        coordinator.parent = self
        coordinator.start(context: context, completion: completion)
    }
    
    func stopChild(identifier: String, context: Any = none, completion: Callback?) {
        guard let child = children[identifier] else {
            fatalError("Child coordinator with identifier \(identifier) not found.")
        }
        
        child.stop(context: context) { [weak self] coordinator in
            coordinator.parent = nil
            self?.children[identifier] = nil
            completion?(coordinator)
        }
    }
    
    func childFinished(identifier: String) {
        stopChild(identifier: identifier, context: none, completion: nil)
    }
}

extension Coordinator {
    var parentCoordinator: Coordinator? {
        return parent as? Coordinator
    }
}

let none: Void = Void()
