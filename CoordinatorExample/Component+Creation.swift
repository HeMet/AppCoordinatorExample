//
//  Component+Creation.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 06.11.2017.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import Foundation

protocol DestinationType: Equatable {
    
}

enum Destination: DestinationType {
    case stack
    case main
    case modal
    case child
}

protocol CreatableComponent: Component {
    init(parameters: Any?)
}

class ComponentRegistry<Destination> where Destination: DestinationType {
    struct Item {
        let destination: Destination
        let factory: (Any?) -> Component
    }
    
    var items: [Item] = []
    
    func register(_ componentType: CreatableComponent.Type, destination: Destination) -> ComponentRegistry {
        items.append(Item(destination: destination,
                          factory: { componentType.init(parameters: $0) }))
        return self
    }
    
    @discardableResult
    func register(_ componentType: Component.Type, destination: Destination, factory: @escaping (Any?) -> Component) -> ComponentRegistry {
        items.append(Item(destination: destination,
                          factory: factory))
        return self
    }
    
    @discardableResult
    func component(for destination: Destination, parameters: Any?) -> Component? {
        return items
            .first(where: { $0.destination == destination })?
            .factory(parameters)
    }
}

let sharedComponentRegistry = ComponentRegistry<Destination>()

extension Component {    
    func travel(to destination: Destination, context: Any? = nil, completion: (() -> Void)? = nil) {
        let result = sharedComponentRegistry.component(for: destination, parameters: context)!
        connectingChildComponent(result)
        connect(result, context: context, completion: completion)
    }
}
