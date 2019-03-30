import UIKit
import RxSwift
import PlaygroundSupport
import Utils

func logRxResources() {
    log("Resources.total: \(Resources.total)")
}

class HotRetainSelfInSubscriptionViewController: UIViewController {
    let lifecycleBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        Observable.just("Hello hot retain self in subscription. Subscription disposed in deinit!")
            .delay(4.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: { self.printMessage($0) })
            .disposed(by: lifecycleBag)
        logRxResources()
    }
    func printMessage(_ message: String) { log(message) }
    deinit { log("HotViewController deallocated") }
}
delay(2.0) { PlaygroundPage.current.liveView = UIView(frame: .zero) }
delay(6.0) { logRxResources() }
PlaygroundPage.current.liveView = HotRetainSelfInSubscriptionViewController()
