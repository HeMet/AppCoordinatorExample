//
//  SignUpCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 12.03.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

class SignUpCoordiantor {
    enum Step: Equatable {
        case basicProfile
        case type
        case subtype
        case extendedProfile(String)
        
        fileprivate var title: String {
            switch self {
            case .basicProfile:
                return "Basic Profile"
            case .type:
                return "Type"
            case .subtype:
                return "Sybtype"
            case .extendedProfile(let value):
                return value
            }
        }
        
        fileprivate static let orderedSteps: [Step] = [.basicProfile, .type, .subtype, .extendedProfile("")]
        
        static func ==(lhs: Step, rhs: Step) -> Bool {
            switch (lhs, rhs) {
            case (.basicProfile, .basicProfile), (.type, .type), (.subtype, .subtype), (.extendedProfile, .extendedProfile):
                return true
            default:
                return false
            }
        }
    }
    
    var childCoordinators: [Coordinator] = []
    
    var sceneViewController: UIViewController { return navigationController }
    var delegate: CoordinatorDelegate?
    
    let navigationController = UINavigationController()
    
    init() {
        
    }
    
    func start(step: Step) {
        var vcs: [UIViewController] = []
        for aStep in Step.orderedSteps {
            let stepToUse = aStep == step ? step : aStep
            let vc = UIViewController()
            vc.title = stepToUse.title
            vcs.append(vc)
            
            if aStep == step {
                break
            }
        }
        navigationController.setViewControllers(vcs, animated: true)
    }
}
