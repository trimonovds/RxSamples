//
//  MapKudaGoSearchViewModelTests.swift
//  RxSamplesTests
//
//  Created by Dmitry Trimonov on 26/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
import RxTest
import CoreLocation
import MapKit
import Utils
@testable import RxSamples

class TestSchedulerProvider: SchedulerProvider {
    var mainScheduler: SchedulerType { return testScheduler }
    var backgroundScheduler: SchedulerType { return testScheduler}

    init(testScheduler: TestScheduler) {
        self.testScheduler = testScheduler
    }

    private let testScheduler: TestScheduler
}

class MapMock: Map {
    let mapCameraEvents: Observable<MapCameraEventArgs>

    init(mapCameraEvents: Observable<MapCameraEventArgs>) {
        self.mapCameraEvents = mapCameraEvents
    }
}

class MapKudaGoSearchAPIMock: MapKudaGoSearchAPI {
    let searchResult: Observable<Result<[KudaGoEvent], APIError>>

    init(searchResult: Observable<Result<[KudaGoEvent], APIError>>) {
        self.searchResult = searchResult
    }

    func searchEvents(with text: String, locationArgs: LocationArgs) -> Observable<Result<[KudaGoEvent], APIError>> {
        return searchResult
    }
}

fileprivate func createMapCamera(location: CLLocationCoordinate2D? = nil) -> MKMapCamera {
    let center = location ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    return MKMapCamera(lookingAtCenter: center, fromDistance: 0, pitch: 0, heading: 0)
}

class MapKudaGoSearchViewModelTests: XCTestCase {
    var testScheduler: TestScheduler!
    var schedulerProvider: SchedulerProvider!

    override func setUp() {
        super.setUp()
        testScheduler = TestScheduler(initialClock: 0)
        schedulerProvider = TestSchedulerProvider(testScheduler: testScheduler)
    }

    func testWhenCameraAnimationStartsBeforeSearchCompletedThenSearchIsCanceled() {
        let mapCameraEvents = testScheduler.createHotObservable([
            .next(300, MapCameraEventArgs(mapCamera: createMapCamera(), state: .finished, radius: 5)),
            .next(400, MapCameraEventArgs(mapCamera: createMapCamera(), state: .started, radius: 10))
        ])

        let searchResult = testScheduler.createHotObservable([
            .next(500, Result<[KudaGoEvent], APIError>.success([]))
        ])

        let sut = MapKudaGoSearchViewModel(
            map: MapMock(mapCameraEvents: mapCameraEvents.asObservable()),
            searchApi: MapKudaGoSearchAPIMock(searchResult: searchResult.asObservable()),
            schedulerProvider: schedulerProvider
        )

        let stateObserver = testScheduler.start { () -> Observable<ScreenState> in
            return sut.didChangeScreenState
        }

        XCTAssert(stateObserver.events[0].time == 301)
        XCTAssert(stateObserver.events[0].value.element?.isLoading == true)

        XCTAssert(stateObserver.events[1].time == 400)
        XCTAssert(stateObserver.events[1].value.element?.isCanceled == true)
    }
}

extension ScreenState {
    var isCanceled: Bool {
        switch self {
        case .searchCanceled:
            return true
        default:
            return false
        }
    }
}
