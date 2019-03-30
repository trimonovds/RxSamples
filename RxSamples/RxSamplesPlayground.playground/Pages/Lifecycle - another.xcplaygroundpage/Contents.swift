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

class DeallocateOnErrorViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        logRxResources()
        let stream = Observable<Int>.interval(1.0, scheduler: MainScheduler.instance)
        _ = stream
            .map({ (i) -> Int in
                if i < 4 {
                    return i
                } else {
                    throw RxError.unknown
                }
            })
            .subscribe(PrintObserver<Int>())

        _ = stream.subscribe(onNext: {
            print("Another one: \($0)")
        })
        logRxResources()
    }
}

PlaygroundPage.current.liveView = DeallocateOnErrorViewController()
