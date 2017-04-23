//
//  Timer.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 23.04.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import Foundation

class Timer {
    var timer: DispatchSourceTimer?
    let interval: TimeInterval
    let action: () -> Void
    
    init(interval: TimeInterval, action: @escaping () -> Void) {
        self.interval = interval
        self.action = action
    }
    
    func star() {
        let t = DispatchSource.makeTimerSource()
        t.scheduleRepeating(deadline: .now() + interval, interval: interval)
        t.setEventHandler(handler: action)
        timer = t
        t.resume()
    }
    
    func stop() {
        timer?.cancel()
    }
}
