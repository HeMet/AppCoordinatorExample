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
    func startChild(_ coordinator: Component, context: Any) -> Observable<Void>
    func stopChild(_ coordinator: Component, context: Any) -> Observable<Void>
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
    func presentChild(_ childCoordinator: Coordinator, context: Any) -> Observable<Void>
    func dismissChild(_ childCoordinator: Coordinator, context: Any) -> Observable<Void>
}

typealias PresentingCoordinator = PresentingComponent & Coordinator

extension Component {
    var identifier: String { return String(describing: type(of: self)) }
    
    func startChild(_ coordinator: Component, context: Any) -> Observable<Void> {
        return add(child: coordinator)
            .flatMap {
                coordinator.start(context: context)
            }
    }
    
    func stopChild(_ coordinator: Component, context: Any) -> Observable<Void> {
        guard coordinator.parent === self else {
            fatalError("Child coordinator with identifier \(identifier) not found.")
        }
        
        return coordinator
            .stop(context: context)
            .flatMap {
                self._remove(child: coordinator)
            }
    }
    
    private func add(child: Component) -> Observable<Void> {
        return .perform {
            self.children.insert(child)
            child.parent = self
        }
    }
    
    private func _remove(child: Component) -> Observable<Void> {
        return .perform {
            child.parent = nil
            self.children.remove(child)
        }
    }
}

extension Coordinator {
    // Component is Self
    func presentByParent(context: Any) -> Observable<Void> {
        guard let presenter = parent as? PresentingComponent else {
            notImplemented()
        }
        
        return presenter.presentChild(self, context: context)
    }
    
    func dismissByParent(context: Any) -> Observable<Void> {
        guard let presenter = parent as? PresentingComponent else {
            notImplemented()
        }
        
        return presenter.dismissChild(self, context: context)
    }
}

extension Coordinator {
    var parentCoordinator: Coordinator? {
        return parent as? Coordinator
    }
}

let none: Void = Void()


