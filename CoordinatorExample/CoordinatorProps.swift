//
//  BaseCoordinator.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 23.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import UIKit

class CoordinatorProps {
    weak var parent: Component?
    var children: [String: Component] = [:]
}
