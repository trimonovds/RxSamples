import UIKit
import RxSwift
import PlaygroundSupport
import Utils

func logRxResources() {
    log("Resources.total: \(Resources.total)")
}

class HotRetainSelfInOperatorViewController: UIViewController {
    let lifecycleBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        Observable.just("Hello hot retain self in operator. Subscription disposed in deinit!")
            .delay(4.0, scheduler: MainScheduler.instance)
            .map { self.transformMessage($0) }
            .subscribe(onNext: { log($0) })
            .disposed(by: lifecycleBag)
        logRxResources()
    }
    func transformMessage(_ message: String) -> String { return message.uppercased() }
    deinit { log("HotViewController deallocated") }
}
delay(2.0) { PlaygroundPage.current.liveView = UIView(frame: .zero) }
delay(6.0) { logRxResources() }
PlaygroundPage.current.liveView = HotRetainSelfInOperatorViewController()
