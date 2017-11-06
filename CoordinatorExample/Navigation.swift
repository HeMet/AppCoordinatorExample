//
//  Navigation.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 05.11.2017.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import Foundation

extension Component {
    func connect(_ child: Component, context: Any?, completion: (() -> Void)?) {
        all.connect(parent: self, with: child, context: context) {
            completion?()
        }
    }
    
    func disconnect(_ child: Component, context: Any, completion: (() -> Void)?) {
        all.disconnect(parent: self, with: child, context: context) {
            completion?()
        }
    }
}

protocol AnyComponentConnector {
    func canConnect(parent: Component, with child: Component) -> Bool
    func unsafeConnect(parent: Component, child: Component, context: Any?, completion: @escaping () -> Void)
    func unsafeDisconnect(parent: Component, child: Component, context: Any?, completion: @escaping  () -> Void)
}

final class ComponentConnector<Parent, Child>: AnyComponentConnector {
    typealias Action = (Parent, Child, Any?, @escaping () -> Void) -> Void
    
    let connect: Action
    let disconnect: Action
    
    init(connect: @escaping Action, disconnect: @escaping Action) {
        self.connect = connect
        self.disconnect = disconnect
    }
    
    func canConnect(parent: Component, with child: Component) -> Bool {
        return parent is Parent && child is Child
    }
    
    func unsafeConnect(parent: Component, child: Component, context: Any?, completion: @escaping () -> Void) {
        connect(parent as! Parent, child as! Child, context, completion)
    }
    
    func unsafeDisconnect(parent: Component, child: Component, context: Any?, completion: @escaping () -> Void) {
        disconnect(parent as! Parent, child as! Child, context, completion)
    }
}


final class AppConnector {
    typealias Action<Parent, Child> = (Parent, Child, Any?, () -> Void) -> Void
    
    private var connectors: [AnyComponentConnector] /// ComponentConnector
    
    init(connectors: [AnyComponentConnector]) {
        self.connectors = connectors
    }
    
    func connect(parent: Component,
                 with child: Component,
                 context: Any?,
                 completion: @escaping () -> Void) {
            
            parent.children[child.identifier] = child
            child.parent = parent
            
            let completion = {
                child.start { _ in
                    completion()
                }
            }
            
            connectors.lazy
                .filter { $0.canConnect(parent: parent, with: child) }
                .first?
                .unsafeConnect(parent: parent, child: child, context: context, completion: completion)
    }
    
    func disconnect(parent: Component,
                    with child: Component,
                    context: Any?,
                    completion: @escaping () -> Void) {
            
        guard parent.children[child.identifier] != nil else {
            fatalError("Child coordinator with identifier \(child.identifier) not found.")
        }
        
        child.stop { [weak parent, weak self] coordinator in
            guard let parent = parent, let `self` = self else {
                return
            }
            
            self.connectors.lazy
                .filter { $0.canConnect(parent: parent, with: child) }
                .first?
                .unsafeDisconnect(parent: parent, child: child, context: context) {
                    coordinator.parent = nil
                    parent.children[child.identifier] = nil
                }
        }
    }
}


