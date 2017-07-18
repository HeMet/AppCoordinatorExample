//
//  Transitable.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 07.07.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import Foundation

protocol TransitionDispatcher {
    func dispatchTransition(to: Any)
}

protocol Transitable {
    func performTransition(to: Any)
    static func canTransit(to: Any) -> Bool
}

extension Component {
    func transit(to target: Any) {
        if let rootTransitable = rootComponent as? TransitionDispatcher {
            rootTransitable.dispatchTransition(to: target)
        } else {
            fatalError("Root component must be TransitionDispatcher")
        }
    }
    
    var rootComponent: Component {
        var result: Component = self
        while let _parent = result.parent {
            result = _parent
        }
        return result
    }
}

extension TransitionDispatcher where Self: Component {
    typealias TransitableComponent = Component & Transitable
    func childFor(target: Any) -> TransitableComponent? {
        let child = children.all.first {
            if let transitable = $0 as? Transitable, type(of: transitable).canTransit(to: target) {
                return true
            }
            return false
        }
        return child as? TransitableComponent
    }
}

