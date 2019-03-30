//
//  SimplifiedDrawerHidingBehavior.swift
//  RxSamples
//
//  Created by Dmitry Trimonov on 21/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation
import RxSwift

// Режим автовращения - режим, в котором камера поворачивается так,
// чтобы направление движения пользователя всегда было "вверх" экрана

/// Нужно закрывать шторку при возникновении одного из 2-х событий
/// 1. Скорость пользователя стала выше 2.5 м/с при включенном режиме автовращения
/// 2. Был включен режим автовращения при скорости выше 2.5 м/с
class SimpleDrawerHidingStrategy: DrawerHidingStrategy {
    func hideEvents(didChangeAutoRotationMode: Observable<Bool>, didUpdateSpeed: Observable<Double>) -> Observable<Void> {
        let speedIsAboveThreshold = didUpdateSpeed.map { $0 > 2.5 }
            .distinctUntilChanged()
        let autoRotationIsOn = didChangeAutoRotationMode
            .distinctUntilChanged()
        return Observable.combineLatest(speedIsAboveThreshold, autoRotationIsOn)
            .filter { $0.0 && $0.1 }
            .mapTo(())
    }
}


/// Аналогичные требования, но нужно удостовериться, что превышение порога скорости - не случайное событие
/// - ошибка или секундное явление
/// 1. Скорость пользователя стала выше 2.5 м/с при включенном режиме автовращения и продержалась
///    на этом уровне (> 2.5 м/с) 5 секунд при этом режим автовращения не был выключен за эти 5 секунд
/// 2. Был включен режим автовращения при скорости выше 2.5 м/с
class SmartDrawerHidingStrategy: DrawerHidingStrategy {

    typealias TimerTickHandler = (_ timeRemains: Int) -> Void
    typealias TimerResetHandler = () -> Void

    var timerTickHandler: TimerTickHandler?
    var timerResetHandler: TimerResetHandler?

    init(timerScheduler: SchedulerType, timeInSeconds: Int) {
        self.timerScheduler = timerScheduler
        self.timeInSeconds = timeInSeconds
    }

    func hideEvents(didChangeAutoRotationMode: Observable<Bool>,
                    didUpdateSpeed: Observable<Double>) -> Observable<Void> {
        let autoRotationIsOn = didChangeAutoRotationMode.distinctUntilChanged()
        let autoRotationDidTurnOn = autoRotationIsOn.filter { $0 }.mapTo(())
        let autoRotationDidTurnOff = autoRotationIsOn.filter { !$0 }.mapTo(())

        let speedIsAboveThreshold = didUpdateSpeed.map { $0 > 2.5 }.distinctUntilChanged()
        let speedDidExceedThreshold = speedIsAboveThreshold.filter { $0 }.mapTo(())
        let speedDidFallBelowThreshold = speedIsAboveThreshold.filter { !$0 }.mapTo(())

        let speedDidExceedThresholdWhileAutoRotationIsOn = speedDidExceedThreshold
            .withLatestFrom(autoRotationIsOn)
            .filter { $0 }
            .mapTo(())

        let seconds = timeInSeconds

        // Implementation below is for presentation video recording purposes. In production just use
        // let timerFor5Sec = Observable<Int>.timer(5.0, period: nil, scheduler: timerScheduler).mapTo(())
        let timerFor5Sec = Observable<Int>.interval(1.0, scheduler: timerScheduler)
            .map { $0 + 1 }
            .startWith(0)
            .take(seconds + 1)
            .map { seconds - $0 }
            .do(onNext: timerTickHandler, onDispose: timerResetHandler)
            .mapTo(())
            .takeLast(1)

        let timeShouldStop = Observable<Void>.merge(autoRotationDidTurnOff, speedDidFallBelowThreshold)
        let speedConditionDidSucceed = speedDidExceedThresholdWhileAutoRotationIsOn
            .flatMapLatest { _ -> Observable<Void> in
                return timerFor5Sec.takeUntil(timeShouldStop)
            }

        let autoRotationConditionDidSucceed = autoRotationDidTurnOn
            .withLatestFrom(speedIsAboveThreshold)
            .filter { $0 }
            .mapTo(())

        return Observable.merge(autoRotationConditionDidSucceed, speedConditionDidSucceed)
    }

    private let timerScheduler: SchedulerType
    private let timeInSeconds: Int
}

extension ObservableType {
    func mapTo<T>(_ t: T) -> Observable<T> {
        return self.map { _ in t }
    }
}
