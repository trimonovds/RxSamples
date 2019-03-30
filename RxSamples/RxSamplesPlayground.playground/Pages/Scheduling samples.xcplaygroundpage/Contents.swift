import UIKit
import RxSwift
import PlaygroundSupport
import Utils

func fib(_ n: Int) -> Int {
    guard n > 1 else { return n }
    return fib(n-1) + fib(n-2)
}

func calculateFibonacci(n: Int) -> Observable<Int> {
    return Observable<Int>.create { observer -> Disposable in
        logWithQueueInfo("subscribe")
        observer.onNext(fib(n))
        observer.onCompleted()
        return Disposables.create()
    }
}

//example("no subscribeOn") {
//    calculateFibonacci(n: 25)
//        .map { i -> Int in logWithQueueInfo("map"); return i * 2 }
//        .subscribe(onNext: { (num) in
//            logWithQueueInfo("onNext: \(num)")
//        })
//}

//example("subscribeOn at the end") {
//    calculateFibonacci(n: 10)
//        .map { i -> Int in logWithQueueInfo("map"); return i * 2 }
//        .do(onNext: { i in logWithQueueInfo("doOnNext") },
//            onSubscribe: { logWithQueueInfo("doOnSubscribe") }, // Before DoSink subsribes
//            onSubscribed: { logWithQueueInfo("doOnSubscribed") }, // After DoSink subsribes
//            onDispose: { logWithQueueInfo("doOnDispose") })
//        .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
//        .subscribe(onNext: { (num) in
//            logWithQueueInfo("onNext: \(num)")
//        })
//}

//example("subscribeOn in the middle") {
//    calculateFibonacci(n: 10)
//        .map { i -> Int in logWithQueueInfo("map"); return i * 2 }
//        .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
//        .do(onNext: { i in logWithQueueInfo("doOnNext") },
//            onSubscribe: { logWithQueueInfo("doOnSubscribe") }, // Before DoSink subsribes
//            onSubscribed: { logWithQueueInfo("doOnSubscribed") }, // After DoSink subsribes
//            onDispose: { logWithQueueInfo("doOnDispose") })
//        .subscribe(onNext: { (num) in
//            logWithQueueInfo("onNext: \(num)")
//        })
//}

//example("observeOn") {
//    calculateFibonacci(n: 10)
//        .map { i -> Int in logWithQueueInfo("map"); return i * 2 }
//        .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
//        .observeOn(MainScheduler.instance)
//        .do(onNext: { i in logWithQueueInfo("doOnNext") },
//            onSubscribe: { logWithQueueInfo("doOnSubscribe") }, // Before DoSink subsribes
//            onSubscribed: { logWithQueueInfo("doOnSubscribed") }, // After DoSink subsribes
//            onDispose: { logWithQueueInfo("doOnDispose") })
//        .subscribe(onNext: { (num) in
//            logWithQueueInfo("onNext: \(num)")
//        })
//}

example("observeOn") {
    calculateFibonacci(n: 10)
        .do(onNext: { i in logWithQueueInfo("doOnNext") },
            onSubscribe: { logWithQueueInfo("doOnSubscribe") },
            onSubscribed: { logWithQueueInfo("doOnSubscribed") },
            onDispose: { logWithQueueInfo("doOnDispose") })
        .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { (num) in
            logWithQueueInfo("onNext: \(num)")
        })
}



//example("observeOn after observeOn") {
//    calculateFibonacci(n: 10)
//        .map { i -> Int in logWithQueueInfo("map"); return i * 2 }
//        .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
//        .observeOn(MainScheduler.instance)
//        .do(onNext: { i in logWithQueueInfo("doOnNext") },
//            onSubscribe: { logWithQueueInfo("doOnSubscribe") }, // Before DoSink subsribes
//            onSubscribed: { logWithQueueInfo("doOnSubscribed") }, // After DoSink subsribes
//            onDispose: { logWithQueueInfo("doOnDispose") })
//        .observeOn(SerialDispatchQueueScheduler(qos: .background))
//        .subscribe(onNext: { (num) in
//            logWithQueueInfo("onNext: \(num)")
//        })
//}
