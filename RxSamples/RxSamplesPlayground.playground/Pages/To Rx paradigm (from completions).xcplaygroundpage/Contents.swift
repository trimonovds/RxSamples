//: [Previous](@previous)

import UIKit
import RxSwift
import RxCocoa

func log<T>(_ element: T) {
    print(element)
}

extension Observable {
    public static func fromAsync(_ asyncRequest: @escaping (@escaping (Element) -> Void) -> Void) -> Observable<Element> {
        return Observable.create({ (o) -> Disposable in
            asyncRequest({ (result) in
                o.onNext(result)
                o.onCompleted()
            })

            return Disposables.create()
        })
    }
}

struct Country: CustomStringConvertible {
    let name: String

    var description: String {
        return name
    }
}

class FakeCountriesRepository {
    func fetchCountries(comlpetion: @escaping ([Country]) -> Void) {
        Thread.sleep(forTimeInterval: 1.5)
        let fakeCountries = [
            Country(name: "Russia"),
            Country(name: "USA"),
            Country(name: "Austria"),
            Country(name: "France")
        ]
        comlpetion(fakeCountries)
    }
}

Observable<Int>
    .interval(0.1, scheduler: MainScheduler.instance)
    .subscribe(onNext: log)

let repo = FakeCountriesRepository()
Observable<[Country]>
    .fromAsync(repo.fetchCountries)
    .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
    .subscribe(onNext: { (countries) -> Void in
        // ...
    })
