//
//  SimplifiedDrawerHidingBehaviorTests.swift
//  RxSamplesTests
//
//  Created by Dmitry Trimonov on 21/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxTest
import RxCocoa
@testable import RxSamples

class SimpleDrawerHidingStrategyTests: XCTestCase {

    var testScheduler: TestScheduler!

    override func setUp() {
        super.setUp()
        testScheduler = TestScheduler(initialClock: 0)
    }

    func makeSut(didChangeAutoRotationModeEvents: [Recorded<Event<Bool>>],
                 didUpdateSpeedEvents: [Recorded<Event<Double>>],
                 onScheduler testScheduler: TestScheduler) -> Observable<Void>
    {
        let didChangeAutoRotationMode = testScheduler.createHotObservable(didChangeAutoRotationModeEvents)
        let didUpdateSpeed = testScheduler.createHotObservable(didUpdateSpeedEvents)
        return SimpleDrawerHidingStrategy().hideEvents(
            didChangeAutoRotationMode: didChangeAutoRotationMode.asObservable(),
            didUpdateSpeed: didUpdateSpeed.asObservable()
        )
    }

    // Observable sequence will be:
    // * created at virtual time `Defaults.created`           -> 100
    // * subscribed to at virtual time `Defaults.subscribed`  -> 200
    // * subscription will be disposed at `Defaults.disposed` -> 1000
    func testWhenSpeedExceedsThresholdAndAutoRotationIsOnThenDrawerHides() {
        let didChangeAutoRotationModeEvents: [Recorded<Event<Bool>>] = [
            .next(300, false),
            .next(600, true)
        ]

        let didUpdateSpeedEvents: [Recorded<Event<Double>>] = [
            .next(400, 1.5),
            .next(700, 2.0),
            .next(800, 2.51), // Exceeds
        ]

        let hidesObserver = testScheduler.start { () -> Observable<Void> in
            return self.makeSut(
                didChangeAutoRotationModeEvents: didChangeAutoRotationModeEvents,
                didUpdateSpeedEvents: didUpdateSpeedEvents,
                onScheduler: self.testScheduler
            )
        }

        XCTAssert(hidesObserver.events.count == 1)
        XCTAssert(hidesObserver.events[0].time == 800)
    }

    func testWhenAutoRotationTurnsOnWhileSpeedIsAboveThresholdThenDrawerHides() {
        let didChangeAutoRotationModeEvents: [Recorded<Event<Bool>>] = [
            .next(300, false),
            .next(900, true)
        ]

        let didUpdateSpeedEvents: [Recorded<Event<Double>>] = [
            .next(400, 1.5),
            .next(700, 2.0),
            .next(800, 2.51), // Exceeds
        ]

        let hidesObserver = testScheduler.start { () -> Observable<Void> in
            return self.makeSut(
                didChangeAutoRotationModeEvents: didChangeAutoRotationModeEvents,
                didUpdateSpeedEvents: didUpdateSpeedEvents,
                onScheduler: self.testScheduler
            )
        }

        XCTAssert(hidesObserver.events.count == 1)
        XCTAssert(hidesObserver.events[0].time == 900)
    }

    func testWhenSubscribeOnStrategyEventsWhileSpeedIsMoreThanThresholdAndAutoRotationIsOnThenDrawerRemainsUntouched() {
        let didChangeAutoRotationModeEvents: [Recorded<Event<Bool>>] = [
            .next(300, false),
            .next(500, true)
        ]

        let didUpdateSpeedEvents: [Recorded<Event<Double>>] = [
            .next(400, 1.5),
            .next(600, 2.9)
        ]

        let hidesObserver = testScheduler.start(created: 100, subscribed: 700, disposed: 1000000) {
            return self.makeSut(
                didChangeAutoRotationModeEvents: didChangeAutoRotationModeEvents,
                didUpdateSpeedEvents: didUpdateSpeedEvents,
                onScheduler: self.testScheduler
            )
        }

        XCTAssert(hidesObserver.events.isEmpty)
    }

    func testManualSchedulerManagement() {
        let didChangeAutoRotationMode = BehaviorRelay<Bool>(value: false)
        let didUpdateSpeed = BehaviorRelay<Double>(value: 1.0)

        let hidesObserver = testScheduler.createObserver(Void.self)
        let sut = SimpleDrawerHidingStrategy().hideEvents(
            didChangeAutoRotationMode: didChangeAutoRotationMode.asObservable(),
            didUpdateSpeed: didUpdateSpeed.asObservable()
        )

        testScheduler.scheduleAt(300, action: {
            _ = sut.subscribe(hidesObserver)
        })

        testScheduler.scheduleAt(500, action: {
            didChangeAutoRotationMode.accept(true)
        })

        testScheduler.scheduleAt(700, action: {
            didUpdateSpeed.accept(3.2)
        })

        testScheduler.advanceTo(499) // Before autoRotation turns on
        XCTAssert(hidesObserver.events.isEmpty)

        testScheduler.advanceTo(501) // After autoRotation turns on
        XCTAssert(hidesObserver.events.isEmpty)

        testScheduler.advanceTo(699) // Before speed exceeds threshold
        XCTAssert(hidesObserver.events.isEmpty)

        testScheduler.start() // Resumes all remain scheduled items (speed exceeds threshold at 700)
        XCTAssert(hidesObserver.events[0].time == 700)
    }
}
