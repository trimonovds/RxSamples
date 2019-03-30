//: [Previous](@previous)

import UIKit
import RxSwift
import RxCocoa

class StatusBarOrientationObserverWrapper {
    let on: (Event<UIInterfaceOrientation>) -> Void
    init(observer: AnyObserver<UIInterfaceOrientation>) {
        self.on = observer.on
    }
    @objc func handler(notifitation: Notification) {
        on(.next(UIApplication.shared.statusBarOrientation))
    }
}

extension UIApplication {
    public var customObservableStatusBarOrientation: Observable<UIInterfaceOrientation> {
        return Observable<UIInterfaceOrientation>.create { observer in
            let wrapper = StatusBarOrientationObserverWrapper(observer: observer)
            NotificationCenter.default.addObserver(
                wrapper,
                selector: #selector(StatusBarOrientationObserverWrapper.handler),
                name: UIApplication.didChangeStatusBarOrientationNotification,
                object: nil
            )
            return Disposables.create { NotificationCenter.default.removeObserver(wrapper) }
        }
    }

    public var observableStatusBarOrientation: Observable<UIInterfaceOrientation> {
        return NotificationCenter.default.rx
            .notification(UIApplication.didChangeStatusBarOrientationNotification)
            .map { _ in UIApplication.shared.statusBarOrientation }
    }
}

UIApplication.shared.customObservableStatusBarOrientation.subscribe(onNext: {
    print("Custom: \($0.isPortrait)")
})

UIApplication.shared.observableStatusBarOrientation.subscribe(onNext: {
    print("Cocoa: \($0.isPortrait)")
})

NotificationCenter.default.post(name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)

//: [Next](@next)
