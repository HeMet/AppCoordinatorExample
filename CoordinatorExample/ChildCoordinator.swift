//
//  ChildCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 23.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

protocol ChildCoordinatorOutput: class {
    func childCoordinatorAdd(_ sender: ChildCoordinator)
    func childCoordinatorRemove(_ sender: ChildCoordinator)
}

class ChildCoordinator: CoordinatorProps, Coordinator {
    
    let identifier: String = UUID().uuidString
    
    var sceneViewController: UIViewController { return childViewController as! UIViewController }
    var childViewController: ChildViewControllerInput = ChildViewController()
    
    weak var output: ChildCoordinatorOutput?
    
    private var colorSeed: Int
    private var timer: Timer!
    
    init(colorSeed: Int) {
        self.colorSeed = colorSeed
    }
    
    func start(completion: CoordinatorCallback?) {
        childViewController.output = self
        updateColor()
        
        timer = makeTimer()
        timer.star()
                
        completion?(self)
    }
    
    func stop(completion: CoordinatorCallback?) {
        timer.stop()
        
        completion?(self)
    }
    
    private func makeTimer() -> Timer {
        return Timer(interval: 2) { [weak self] in
            DispatchQueue.main.async {
                self?.updateColor()
            }
        }
    }
    
    private func updateColor() {
        childViewController.update(using: color(seed: colorSeed))
        colorSeed += 1
    }
    
    private func color(seed: Int) -> UIColor {
        let colors: [UIColor] = [.red, .green, .blue]
        return colors[seed % 3]
    }
}

extension ChildCoordinator: ChildViewControllerOutput {
    func childViewControllerTapped(_ sender: UIViewController) {
        output?.childCoordinatorAdd(self)
    }
    
    func childViewControllerSwiped(_ sender: UIViewController) {
        output?.childCoordinatorRemove(self)
    }
}
