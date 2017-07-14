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
    var children: [String: Component] { get set }
    
    // Component is self
    func start(context: Any) -> Observable<Component>
    func stop(context: Any) -> Observable<Component>
    
    // Component is child
    func startChild(_ coordinator: Component, context: Any) -> Observable<Component>
    func stopChild(identifier: String, context: Any) -> Observable<Component>
    
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
    func presentChild(_ childCoordinator: Coordinator, context: Any) -> Observable<Component>
    func dismissChild(_ childCoordinator: Coordinator, context: Any) -> Observable<Component>
}

typealias PresentingCoordinator = PresentingComponent & Coordinator

extension Component {
    var identifier: String { return String(describing: type(of: self)) }
    
    func startChild(_ coordinator: Component, context: Any) -> Observable<Component> {
        return add(child: coordinator)
            .flatMap { coordiantor in
                coordiantor.start(context: context)
            }
    }
    
    func stopChild(identifier: String, context: Any) -> Observable<Component> {
        guard let child = children[identifier] else {
            fatalError("Child coordinator with identifier \(identifier) not found.")
        }
        
        return child
            .stop(context: context)
            .flatMap {
                self.remove(identifier: $0.identifier)
        }
    }
    
    private func add(child: Component) -> Observable<Component> {
        return Observable.create { observer in
            self.children[child.identifier] = child
            child.parent = self
            observer.onNext(child)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    private func remove(identifier: String) -> Observable<Component> {
        return Observable.create { observer in
            guard let child = self.children[identifier] else {
                fatalError("Child coordinator with identifier \(identifier) not found.")
            }
            
            child.parent = nil
            self.children[identifier] = nil
            
            observer.onNext(child)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func childFinished(identifier: String) {
        //stopChild(identifier: identifier, context: none, completion: nil)
        stopChild(identifier: identifier, context: none).subscribe()
    }
}

extension Coordinator {
    // Component is Self
    func presentByParent(context: Any) -> Observable<Self> {
        guard let presenter = parent as? PresentingComponent else {
            notImplemented()
        }
        
        // TODO
        return presenter.presentChild(self, context: context).map { _ in self }
    }
    
    func dismissByParent(context: Any) -> Observable<Self> {
        guard let presenter = parent as? PresentingComponent else {
            notImplemented()
        }
        
        // TODO
        return presenter.dismissChild(self, context: context).map { _ in self }
    }
}

extension Coordinator {
    var parentCoordinator: Coordinator? {
        return parent as? Coordinator
    }
}

let none: Void = Void()


