//
//  ChildViewController.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 23.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

protocol ChildViewControllerInput: class {
    weak var output: ChildViewControllerOutput? { get set }
    
    func update(using color: UIColor)
}

protocol ChildViewControllerOutput: class {
    func childViewControllerTapped( _ sender: UIViewController)
    func childViewControllerSwiped( _ sender: UIViewController)
}

class ChildViewController: UIViewController, ChildViewControllerInput {
    weak var output: ChildViewControllerOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: 100, height: 200)
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(gr)
        
        let swipeGR = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeGR.direction = .left
        view.addGestureRecognizer(swipeGR)
    }
    
    func update(using color: UIColor) {
        UIView.animate(withDuration: 1) {
            self.view.backgroundColor = color
        }
    }
    
    @objc func tapped() {
        output?.childViewControllerTapped(self)
    }
    
    @objc func swiped() {
        output?.childViewControllerSwiped(self)
    }
}
