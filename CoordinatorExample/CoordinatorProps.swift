//
//  BaseCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 23.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

class CoordinatorProps {
    weak var parent: Component?
    let children: ChildrenTracker = DictionaryChildrenTracker()
}

class DictionaryChildrenTracker: ChildrenTracker {
    private var children: [String: Component] = [:]
    
    var all: [Component] {
        return Array(children.values)
    }
    
    func child(_ identifier: String) -> Component? {
        return children[identifier]
    }
    
    func child<T: Component>(_ childType: T.Type, identifier: String) -> T? {
        return children[identifier] as? T
    }
    
    func insert(_ child: Component) {
        children[child.identifier] = child
    }
    
    func remove(_ child: Component) {
        children[child.identifier] = nil
    }
}

class ArrayOfComponents: ChildrenTracker {
    private var children: [Component] = []
    
    var all: [Component] {
        return children
    }
    
    func child(_ identifier: String) -> Component? {
        return children.first(where: { $0.identifier == identifier })
    }
    
    func child<T: Component>(_ childType: T.Type, identifier: String) -> T? {
        return children.first(where: { $0.identifier == identifier }) as? T
    }
    
    func insert(_ child: Component) {
        children.append(child)
    }
    
    func remove(_ child: Component) {
        if let idx = children.index(where: { $0 === child }) {
            children.remove(at: idx)
        }
    }
}

class ChildrenArrayOf<T: Component>: ChildrenTracker {
    var items: [T] = []
    
    var all: [Component] {
        return items
    }
    
    func child(_ identifier: String) -> Component? {
        return items.first(where: { $0.identifier == identifier })
    }
    
    func child<T: Component>(_ childType: T.Type, identifier: String) -> T? {
        return items.first(where: { $0.identifier == identifier }) as? T
    }
    
    func insert(_ child: Component) {
        items.append(child as! T)
    }
    
    func remove(_ child: Component) {
        if let idx = items.index(where: { $0 === child }) {
            items.remove(at: idx)
        }
    }
}
