//
//  TestSchedulerUsageWithoutRxTests.swift
//  RxSamplesTests
//
//  Created by Dmitry Trimonov on 21/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation
import XCTest
import RxTest
import RxSwift
import Utils
@testable import RxSamples

class URLSessionTaskMock: URLSessionTaskProtocol {
    var onResume: (() -> Void)?
    var onCancel: (() -> Void)?

    init(onResume: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        self.onResume = onResume
        self.onCancel = onCancel
    }
    func resume() {
        onResume?()
    }
    func cancel() {
        onCancel?()
    }
}

class URLSessionMock: URLSessionProtocol {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    typealias RequestBlock = (URL, @escaping CompletionHandler) -> URLSessionTaskProtocol

    let implementation: RequestBlock!

    init(implementation: @escaping RequestBlock) {
        self.implementation = implementation
    }

    func request(with url: URL, completion: @escaping CompletionHandler) -> URLSessionTaskProtocol {
        return implementation(url, completion)
    }
}

class KudaGoSearchAPITests: XCTestCase {
    func testWhenCancelTaskThenSearchIsCanceled() {
        var dispatchWorkItem: DispatchWorkItem!
        let networkServiceMock = URLSessionMock { url, completion in
            return URLSessionTaskMock(onResume: {
                let response = KudaGoEventsPageResponse(count: 1, next: nil, previos: nil, results: [
                    KudaGoEvent(title: "Codefest X", description: "Лучшая конференция за Уралом")
                ])
                let data = try! JSONEncoder().encode(response)
                dispatchWorkItem = DispatchWorkItem(block: {
                    completion(data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: dispatchWorkItem)
            }, onCancel: {
                dispatchWorkItem.cancel()
            })
        }
        let sut = KudaGoSearchAPI(session: networkServiceMock)
        let expectation = XCTestExpectation(description: "Search canceled")
        expectation.isInverted = true
        let searchTask = sut.searchEvents(withText: "Конференция") { (result) in
            expectation.fulfill()
        }
        searchTask.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.48) {
            searchTask.cancel()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testSearchWhenNetworkServiceRequestSucceedThenReturnsCorrectResutsInCompletion() {
        // Arrange
        let testScheduler = TestScheduler(initialClock: 0)
        let networkServiceMock = URLSessionMock { url, completion in
            var schedulingDisposable: Disposable?
            return URLSessionTaskMock(onResume: {
                schedulingDisposable = testScheduler.scheduleRelativeVirtual((), dueTime: 500, action: { _ -> Disposable in
                    let reponse = KudaGoEventsPageResponse(count: 1, next: nil, previos: nil, results: [
                        KudaGoEvent(title: "Codefest X", description: "Лучшая конференция за Уралом")
                    ])

                    let data = try! JSONEncoder().encode(reponse)
                    completion(data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
                    return Disposables.create()
                })
            }, onCancel: {
                schedulingDisposable!.dispose()
            })
        }

        let sut = KudaGoSearchAPI(session: networkServiceMock)
        var actualResult: [KudaGoEvent]?

        // Act
        testScheduler.scheduleAt(100) {
            let searchTask = sut.searchEvents(withText: "Конференция") { (result) in
                actualResult = result.value
            }
            searchTask.resume()
        }

        // Assert
        testScheduler.advanceTo(599)
        XCTAssert(actualResult == nil)

        testScheduler.advanceTo(601)
        XCTAssert(actualResult?.count == 1)
    }

    func testSearchWhenCancelTaskThenSearchIsCanceled() {
        // Arrange
        let testScheduler = TestScheduler(initialClock: 0)
        let networkServiceMock = URLSessionMock { url, completion in
            var schedulingDisposable: Disposable?
            return URLSessionTaskMock(onResume: {
                schedulingDisposable = testScheduler.scheduleRelativeVirtual((), dueTime: 500, action: { _ -> Disposable in
                    let reponse = KudaGoEventsPageResponse(count: 1, next: nil, previos: nil, results: [
                        KudaGoEvent(title: "Codefest X", description: "Лучшая конференция за Уралом")
                        ])

                    let data = try! JSONEncoder().encode(reponse)
                    completion(data, HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil), nil)
                    return Disposables.create()
                })
            }, onCancel: {
                schedulingDisposable!.dispose()
            })
        }

        let sut = KudaGoSearchAPI(session: networkServiceMock)
        var completed: Bool = false

        // Act
        var searchTask: URLSessionTaskProtocol?
        testScheduler.scheduleAt(100) {
            searchTask = sut.searchEvents(withText: "Конференция") { _ in
                completed = true
            }
            searchTask!.resume()
        }

        testScheduler.scheduleAt(300) {
            searchTask!.cancel()
        }

        // Assert
        testScheduler.advanceTo(599)
        XCTAssert(!completed)

        testScheduler.advanceTo(601) // or testScheduler.start()
        XCTAssert(!completed)
    }
}
