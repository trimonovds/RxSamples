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

class HotViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = Observable.just("Hello hot!")
            .delay(4.0, scheduler: MainScheduler.instance)
            .subscribe(PrintObserver<String>())
        logRxResources()
    }
    deinit { log("HotViewController deallocated") }
}
delay(2.0) { PlaygroundPage.current.liveView = UIView(frame: .zero) }
delay(6.0) { logRxResources() }
PlaygroundPage.current.liveView = HotViewController()


