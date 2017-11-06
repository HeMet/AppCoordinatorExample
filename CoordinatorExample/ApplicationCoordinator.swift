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
        switch mode {
        case .modalExample:
            travel(to: .main)
        case .stackExample:
            travel(to: .stack)
        }
    }
    
    func stop(completion: Callback?) {
        completion?(self)
    }
}
