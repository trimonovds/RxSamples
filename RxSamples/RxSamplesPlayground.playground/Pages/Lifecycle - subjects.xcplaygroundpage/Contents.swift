import UIKit
import RxSwift
import PlaygroundSupport
import Utils

func logRxResources() {
    log("Resources.total: \(Resources.total)")
}

class PrintObserver<T>: ObserverType {
    typealias E = T
    func on(_ event: Event<T>) { log("PrintObserver<\(T.self)> did receive: \(event)") }
    deinit { log("PrintObserver<\(T.self)> deallocated") }
}

//let subject = BehaviorSubject<Bool>(value: false)
//subject.onCompleted()
//_ = subject.subscribe(PrintObserver<Bool>())
//subject.onNext(true)
//subject.onNext(false)

let subject = PublishSubject<Bool>()
subject.onCompleted()
_ = subject.subscribe(PrintObserver<Bool>())
subject.onNext(true)
subject.onNext(false)
