//
//  SmartDrawerHidingBehaviorTests.swift
//  RxSamplesTests
//
//  Created by Dmitry Trimonov on 23/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxTest
import RxCocoa
@testable import RxSamples

class SmartDrawerHidingStrategyTests: XCTestCase {

    var testScheduler: TestScheduler!

    override func setUp() {
        super.setUp()
        testScheduler = TestScheduler(initialClock: 0)
    }

    func testWhenSpeedExceedsThresholdWhileAutoRotationIsOnThenDrawerHidesIn5SecIfNoSpeedFallsAndAutorotationTurnOffs() {
        let autoRotationMode = testScheduler.createHotObservable(
            [.next(300, false), .next(600, true)]
        )
        let speed = testScheduler.createHotObservable(
            [.next(400, 1.5), .next(800, 2.51)]
        )
        let hideEventsObserver = testScheduler.start { () -> Observable<Void> in
            return SmartDrawerHidingStrategy(timerScheduler: self.testScheduler, timeInSeconds: 5).hideEvents(
                didChangeAutoRotationMode: autoRotationMode.asObservable(),
                didUpdateSpeed: speed.asObservable()
            )
        }
        XCTAssert(hideEventsObserver.events.count == 1)
        XCTAssert(hideEventsObserver.events[0].time == 805)
    }

    func testWhenSpeedExceedsThresholdWhileAutoRotationIsOnThenIfSpeedFallsBelowThresholdIn5SecIntervalThenDrawerDoesntHide() {
        let autoRotationMode = testScheduler.createHotObservable(
            [.next(300, false), .next(600, true)]
        )
        let speed = testScheduler.createHotObservable(
            [.next(400, 1.5), .next(800, 2.51), .next(804, 2.49)]
        )
        let hideEventsObserver = testScheduler.start { () -> Observable<Void> in
            return SmartDrawerHidingStrategy(timerScheduler: self.testScheduler, timeInSeconds: 5).hideEvents(
                didChangeAutoRotationMode: autoRotationMode.asObservable(),
                didUpdateSpeed: speed.asObservable()
            )
        }
        XCTAssert(hideEventsObserver.events.isEmpty)
    }

    func testWhenSpeedExceedsThresholdWhileAutoRotationIsOnThenIfAutorotationTurnsOffIn5SecIntervalThenDrawerDoesntHide() {
        let autoRotationMode = testScheduler.createHotObservable(
            [.next(300, false), .next(600, true), .next(804, false)]
        )
        let speed = testScheduler.createHotObservable(
            [.next(400, 1.5), .next(800, 2.51)]
        )
        let hideEventsObserver = testScheduler.start { () -> Observable<Void> in
            return SmartDrawerHidingStrategy(timerScheduler: self.testScheduler, timeInSeconds: 5).hideEvents(
                didChangeAutoRotationMode: autoRotationMode.asObservable(),
                didUpdateSpeed: speed.asObservable()
            )
        }
        XCTAssert(hideEventsObserver.events.isEmpty)
    }

    func testWhenAutoRotationTurnsOnWhileSpeedIsMoreThanThresholdThenDrawerHides() {
        let autoRotationMode = testScheduler.createHotObservable(
            [.next(300, false), .next(900, true)]
        )
        let speed = testScheduler.createHotObservable(
            [.next(400, 1.5), .next(800, 2.51)]
        )
        let hideEventsObserver = testScheduler.start { () -> Observable<Void> in
            return SmartDrawerHidingStrategy(timerScheduler: self.testScheduler, timeInSeconds: 5).hideEvents(
                didChangeAutoRotationMode: autoRotationMode.asObservable(),
                didUpdateSpeed: speed.asObservable()
            )
        }
        XCTAssert(hideEventsObserver.events.count == 1)
        XCTAssert(hideEventsObserver.events[0].time == 900)
    }

    func testWhenSubscribeOnBehaviorWhileSpeedIsMoreThanThresholdAndAutoRotationIsOnThenDrawerRemainsUntouched() {
        let autoRotationMode = testScheduler.createHotObservable(
            [.next(300, false), .next(500, true)]
        )
        let speed = testScheduler.createHotObservable(
            [.next(400, 1.5), .next(600, 2.9)]
        )

        let hidesObserver = testScheduler.start(created: 100, subscribed: 700, disposed: 1000000) {
            return SmartDrawerHidingStrategy(timerScheduler: self.testScheduler, timeInSeconds: 5).hideEvents(
                didChangeAutoRotationMode: autoRotationMode.asObservable(),
                didUpdateSpeed: speed.asObservable()
            )
        }

        XCTAssert(hidesObserver.events.isEmpty)
    }
}
