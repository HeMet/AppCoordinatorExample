//
//  Helpers.swift
//  CoordinatorExample
//
//  Created by Evgeniy Gubin on 14.07.17.
//  Copyright © 2017 Eugene Gubin. All rights reserved.
//

import Foundation
import RxSwift

extension Reactive where Base: UIViewController {
    func present(_ viewController: UIViewController, animated: Bool) -> Observable<Void> {
        return .create { observer in
            self.base.present(viewController, animated: animated) {
                observer.onNext(Void())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func dismiss(animated: Bool) -> Observable<Void> {
        return .create { observer in
            self.base.dismiss(animated: animated) {
                observer.onNext(Void())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}

extension Observable {
    static func perform<R>(_ action: @escaping () -> R) -> Observable<R> {
        return .create { observer in
            observer.onNext(action())
            observer.onCompleted()
            return Disposables.create()
        }
    }
}
