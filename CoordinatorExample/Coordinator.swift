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
 Отображающий компонент - это компонент, который может отобразить
 координаторы. При этом он сам может являться координатором,
 но не обязательно.
 */
protocol PresentingComponent: Component {
    func present(childCoordinator: Coordinator, context: Any)
    func dismiss(childCoordinator: Coordinator, context: Any)
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

extension PresentingComponent {
    func presentChild(_ coordinator: Coordinator, context: Any = none, completion: Callback? = nil) {
        startChild(coordinator, context: context) { [weak self] child in
            self?.present(childCoordinator: coordinator, context: context)
            completion?(child)
        }
    }
    
    func dismissChild(identifier: String, context: Any = none, completion: Callback? = nil) {
        stopChild(identifier: identifier, context: context) { [weak self] child in
            guard let childCoordinator = child as? Coordinator else {
                fatalError("\(type(of:self)) tried to dismiss not a Coordinator")
            }
            self?.dismiss(childCoordinator: childCoordinator, context: context)
            completion?(child)
        }
    }
}

let none: Void = Void()
