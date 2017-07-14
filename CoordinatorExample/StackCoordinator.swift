//
//  StackCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 22.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit
import RxSwift

class StackCoordinator: CoordinatorProps, PresentingCoordinator {
    
    var sceneViewController: UIViewController { return stackViewController }
    let stackViewController = StackViewController()
    
    func start(context: Any) -> Observable<Component> {
        return presentByParent(context: context)
            .do(onNext: { this in
                if let target = context as? ExampleTarget, target.example == .stackExample {
                    for _ in 0..<max(1, target.stackItems) {
                        this.addElement()
                    }
                } else {
                    this.addElement()
                }
            })
            .map { $0 }
    }
    
    func stop(context: Any) -> Observable<Component> {
        return dismissByParent(context: context).map { $0 }
    }

    func addElement() {
        guard children.count < 3 else {
            let target = ExampleTarget(example: .modalExample, stackItems: 1, showModalScreen: true)
            transit(to: target)
            return
        }
        
        let child = makeChildCoordinator()
        startChild(child, context: none).subscribe()
    }
    
    func makeChildCoordinator() -> ChildCoordinator {
        let child = ChildCoordinator(colorSeed: children.count)
        child.output = self
        return child
    }
    
    func removeChild(coordinator: Coordinator) {
        stopChild(identifier: coordinator.identifier, context: none).subscribe()
    }
    
    func presentChild(_ coordinator: Coordinator, context: Any) -> Observable<Component> {
        return .create { observer in
            let childScene = coordinator.sceneViewController
            
            self.stackViewController.addChildViewController(childScene)
            self.stackViewController.stackView.addArrangedSubview(childScene.view)
            
            childScene.didMove(toParentViewController: self.stackViewController)
            
            observer.onNext(coordinator)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func dismissChild(_ coordinator: Coordinator, context: Any) -> Observable<Component> {
        return .create { observer in
            coordinator.sceneViewController.willMove(toParentViewController: nil)
            self.stackViewController.stackView.removeArrangedSubview(coordinator.sceneViewController.view)
            coordinator.sceneViewController.removeFromParentViewController()
            
            observer.onNext(coordinator)
            observer.onCompleted()
            return Disposables.create()
        }
    }
}

extension StackCoordinator: ChildCoordinatorOutput {
    func childCoordinatorAdd(_ sender: ChildCoordinator) {
        addElement()
    }
    
    func childCoordinatorRemove(_ sender: ChildCoordinator) {
        removeChild(coordinator: sender)
    }
}

extension StackCoordinator: Transitable {
    func performTransition(to target: Any) {
        if let target = target as? ExampleTarget, target.example == .stackExample {
            loop: while true {
                switch children.count.compare(target.stackItems) {
                case .orderedSame:
                    break loop
                case .orderedAscending:
                    let id = children.values.first!.identifier
                    stopChild(identifier: id, context: none).subscribe()
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
