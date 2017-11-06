//
//  Component+Registration.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 06.11.2017.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import Foundation

func registerComponents() {
    sharedComponentRegistry
        .register(StackCoordinator.self, destination: .stack)
        .register(MainCoordinator.self, destination: .main) { _ in
            MainCoordinator()
        }
        .register(ModalCoordinator.self, destination: .modal) { _ in
            ModalCoordinator()
        }
        .register(ChildCoordinator.self, destination: .child) { params -> Component in
            ChildCoordinator(colorSeed: params as! Int)
        }
}
