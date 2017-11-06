//
//  ApplicationCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 23.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

class ApplicationCoordinator: CoordinatorProps, Component {

    enum Mode {
        case modalExample
        case stackExample
    }
    
    let window: UIWindow
    let mode: Mode
    
    init(window: UIWindow, mode: Mode) {
        self.window = window
        self.mode = mode
    }
    
    func start(completion: Callback?) {
        let child: Component
        switch mode {
        case .modalExample:
            child = travel(to: .main)
        case .stackExample:
            child = travel(to: .stack)
        }
        
        self.connect(child, context: 0, completion: nil)
    }
    
    func stop(completion: Callback?) {
        completion?(self)
    }
}
