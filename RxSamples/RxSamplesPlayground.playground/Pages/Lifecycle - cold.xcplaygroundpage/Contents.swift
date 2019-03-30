//: [Previous](@previous)

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

class ColdViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        logRxResources()
        _ = Observable.just("Hello cold!").subscribe(PrintObserver<String>())
        logRxResources()
    }
}

PlaygroundPage.current.liveView = ColdViewController()

//: [Next](@next)
