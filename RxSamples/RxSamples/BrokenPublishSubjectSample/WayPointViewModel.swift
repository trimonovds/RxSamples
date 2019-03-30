//
//  WayPointViewModel.swift
//  RxSamples
//
//  Created by Dmitry Trimonov on 22/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class WayPointViewModel {
    var boundTimes: Int = 0
    var state = BehaviorRelay<WayPointState>(value: .empty)
    var taps = PublishSubject<Void>()
    var bag = DisposeBag()
}
