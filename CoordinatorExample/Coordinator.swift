//
//  Coordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 12.03.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit
import RxSwift

/*
 Основной блок для организации приложения.
 Вместе с другими компонентами образует древовидную структуру.
 */
protocol Component: class {
    typealias Callback = (Component) -> Void
    
    var identifier: String { get }
    
    weak var parent: Component? { get set }
    var children: ChildrenTracker { get }
    
    // Component is self
    func start(context: Any) -> Observable<Void>
    func stop(context: Any) -> Observable<Void>
    
    // Component is child
    func startChild<T: Component>(_ coordinator: T, context: Any) -> Observable<T>
    func stopChild<T: Component>(_ coordinator: T, context: Any) -> Observable<T>
    //func stopAnyChild(_ coordinator: Component, context: Any) -> Observable<Component>
}

protocol ChildrenTracker {
    var all: [Component] { get }
    
    func insert(_ child: Component)
    func remove(_ child: Component)
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
    func presentChild(_ childCoordinator: Coordinator, context: Any) -> Observable<Component>
    func dismissChild(_ childCoordinator: Coordinator, context: Any) -> Observable<Component>
}

typealias PresentingCoordinator = PresentingComponent & Coordinator

extension Component {
    var identifier: String { return String(describing: type(of: self)) }
    
    func startChild<T: Component>(_ coordinator: T, context: Any) -> Observable<T> {
        return add(child: coordinator)
            .flatMap { coordiantor in
                coordiantor.start(context: context).map { coordinator }
            }
    }
    
    func stopChild<T: Component>(_ coordinator: T, context: Any) -> Observable<T> {
        return stopAnyChild(coordinator, context: context).map { $0 as! T }
    }
    
    private func stopAnyChild(_ coordinator: Component, context: Any) -> Observable<Component> {
        guard coordinator.parent === self else {
            fatalError("Child coordinator with identifier \(identifier) not found.")
        }
        
        return coordinator
            .stop(context: context)
            .flatMap {
                self._remove(child: coordinator)
            }
    }
    
    private func add(child: Component) -> Observable<Component> {
        return Observable<Component>.perform {
            self.children.insert(child)
            child.parent = self
            return child
        }
    }
    
    private func _remove(child: Component) -> Observable<Component> {
        return Observable<Component>.perform {
            child.parent = nil
            self.children.remove(child)
            return child
        }
    }
}

extension Coordinator {
    // Component is Self
    func presentByParent(context: Any) -> Observable<Void> {
        guard let presenter = parent as? PresentingComponent else {
            notImplemented()
        }
        
        // TODO
        return presenter.presentChild(self, context: context).map { _ in Void() }
    }
    
    func dismissByParent(context: Any) -> Observable<Void> {
        guard let presenter = parent as? PresentingComponent else {
            notImplemented()
        }
        
        // TODO
        return presenter.dismissChild(self, context: context).map { _ in Void() }
    }
}

extension Coordinator {
    var parentCoordinator: Coordinator? {
        return parent as? Coordinator
    }
}

let none: Void = Void()


