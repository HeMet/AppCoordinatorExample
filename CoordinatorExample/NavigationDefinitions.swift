//
//  NavigationDefinitions.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 05.11.2017.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import Foundation

let stack = ComponentConnector<StackCoordinator, Coordinator>(
    connect: { stack, coordinator, context, completion in
            let childScene = coordinator.sceneViewController
            let stackViewController = stack.stackViewController
            stackViewController.addArrangedViewController(childScene)

            completion()
        },
    disconnect: { stack, coordinator, context, completion in
            stack.stackViewController.removeArrangedViewController(coordinator.sceneViewController)
        
            completion()
        }
)

let app = ComponentConnector<ApplicationCoordinator, Coordinator>(
    connect: { (appCoordiantor: ApplicationCoordinator, coordinator: Coordinator, context: Any?, completion: () -> Void) in
        appCoordiantor.window.rootViewController = coordinator.sceneViewController
        appCoordiantor.window.makeKeyAndVisible()
        completion()
        },
    disconnect: { (appCoordiantor: ApplicationCoordinator, coordinator: Coordinator, context: Any?, completion: () -> Void) in
        /// nothing
    })

let modally = ComponentConnector<Coordinator, Coordinator>(
    connect: { parent, child, context, completion in
        parent.sceneViewController.present(child.sceneViewController, animated: true) {
            completion()
        }
    },
    disconnect: { parent, child, context, completion in
        parent.sceneViewController.dismiss(animated: true) {
            completion()
        }
    }
)

let all = AppConnector(connectors: [stack, app, modally])
