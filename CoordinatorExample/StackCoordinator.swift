//
//  StackCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 22.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit
import RxSwift

class StackCoordinator: PresentingCoordinator {
    weak var parent: Component?
    var children: ChildrenTracker { return _children }
    fileprivate let _children = ChildrenArrayOf<ChildCoordinator>()
    
    var sceneViewController: UIViewController { return stackViewController }
    let stackViewController = StackViewController()
    
    func start(context: Any) -> Observable<Void> {
        return presentByParent(context: context)
            .map {
                if let target = context as? ExampleTarget, target.example == .stackExample {
                    return max(1, target.stackItems)
                } else {
                    return 1
                }
            }
            .flatMap { count -> Observable<Void> in
                self.addElement().repeat(count)
            }
    }
    
    func stop(context: Any) -> Observable<Void> {
        return dismissByParent(context: context)
    }
    
    func addElement() -> Observable<Void> {
        guard _children.items.count < 3 else {
            return .perform { [unowned self] in
                let target = ExampleTarget(example: .modalExample, stackItems: 1, showModalScreen: true)
                self.transit(to: target)
            }
        }
        
        return Observable<Void>
            .perform { self.makeChildCoordinator() }
            .flatMap { child in
                self.startChild(child, context: none)
            }
    }
    
    func makeChildCoordinator() -> ChildCoordinator {
        let child = ChildCoordinator(colorSeed: _children.items.count)
        child.output = self
        return child
    }
    
    func presentChild(_ coordinator: Coordinator, context: Any) -> Observable<Void> {
        return .perform {
            let childScene = coordinator.sceneViewController
            
            self.stackViewController.addChildViewController(childScene)
            self.stackViewController.stackView.addArrangedSubview(childScene.view)
            
            childScene.didMove(toParentViewController: self.stackViewController)
        }
    }
    
    func dismissChild(_ coordinator: Coordinator, context: Any) -> Observable<Void> {
        return .perform {
            coordinator.sceneViewController.willMove(toParentViewController: nil)
            self.stackViewController.stackView.removeArrangedSubview(coordinator.sceneViewController.view)
            coordinator.sceneViewController.removeFromParentViewController()
        }
    }
}

extension StackCoordinator: ChildCoordinatorOutput {
    func childCoordinatorAdd(_ sender: ChildCoordinator) {
        addElement()
    }
    
    func childCoordinatorRemove(_ sender: ChildCoordinator) {
        stopChild(sender, context: none).subscribe()
    }
}

extension StackCoordinator: Transitable {
    func performTransition(to target: Any) {
        if let target = target as? ExampleTarget, target.example == .stackExample {
            loop: while true {
                switch _children.items.count.compare(target.stackItems) {
                case .orderedSame:
                    break loop
                case .orderedAscending:
                    let child = _children.items.first!
                    stopChild(child, context: none).subscribe()
                case .orderedDescending:
                    addElement()
                }
            }
        }
    }
    
    static func canTransit(to target: Any) -> Bool {
        if let example = target as? ExampleTarget {
            return example.example == .stackExample
        }
        return false
    }
}

class StackViewController: UIViewController {
    var coordinator: StackCoordinator!
    
    var stackView: UIStackView {
        return view as! UIStackView
    }
    
    override func loadView() {
        let _view = UIStackView()
        _view.axis = .vertical
        _view.distribution = .fillEqually
        view = _view
    }
}

extension Int {
    func compare(_ value: Int) -> ComparisonResult {
        if self == value {
            return .orderedSame
        }
        if self > value {
            return .orderedDescending
        }
        return .orderedAscending
    }
}

extension ObservableType {
    func `repeat`(_ count: Int) -> Observable<E> {
        return Observable
            .from(0..<count)
            .debug("repeat")
            .flatMap { _ in self }
    }
}
