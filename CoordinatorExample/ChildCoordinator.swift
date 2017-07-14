//
//  ChildCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 23.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit
import RxSwift

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
    
    func start(context: Any) -> Observable<Component> {
        childViewController.output = self
        updateColor()
        
        timer = makeTimer()
        
        return presentByParent(context: context)
            .do(onNext: {
                $0.timer.star()
            })
            .map { $0 }
    }
    
    func stop(context: Any) -> Observable<Component> {
        return dismissByParent(context: context)
            .do(onNext: {
                $0.timer.stop()
            })
            .map { $0 }
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
