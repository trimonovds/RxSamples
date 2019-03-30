//
//  SchedulerProvider.swift
//  RxSamples
//
//  Created by Dmitry Trimonov on 26/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol SchedulerProvider {
    var mainScheduler: SchedulerType { get }
    var backgroundScheduler: SchedulerType { get }
}

class DefaultSchedulerProvider: SchedulerProvider {
    var mainScheduler: SchedulerType { return MainScheduler.instance }
    var backgroundScheduler: SchedulerType { return serialBackgroundScheduler }

    static let shared = DefaultSchedulerProvider()

    private init() {
        
    }

    private let serialBackgroundScheduler = SerialDispatchQueueScheduler(qos: .background)
}
