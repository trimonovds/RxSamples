//
//  DrawerHideBehavior.swift
//  RxSamples
//
//  Created by Dmitry Trimonov on 21/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation
import RxSwift
import CoreLocation

protocol CameraManagerOutput: AnyObject {
    var didChangeAutoRotationMode: Observable<Bool> { get }
}

protocol LocationManagerOutput: AnyObject {
    var didUpdateSpeed: Observable<Double> { get }
}

protocol DrawerInput: AnyObject {
    func hideIfPossible()
}

protocol DrawerHidingStrategy {
    func hideEvents(didChangeAutoRotationMode: Observable<Bool>, didUpdateSpeed: Observable<Double>) -> Observable<Void>
}

class DrawerHidingBehavior {

    // MARK: - Public properties

    var isOn: Bool = false {
        didSet {
            guard oldValue != isOn else { return }
            // Выолняет подписку/отписку на strategy.hideEvents и закрывает шторку как side-effect
            if isOn {
                subscription.disposable = strategy
                    .hideEvents(
                        didChangeAutoRotationMode: cameraManagerOutput.didChangeAutoRotationMode,
                        didUpdateSpeed: locationManagerOutput.didUpdateSpeed
                    )
                    .bind(onNext: { [weak self] in
                        guard let slf = self else { return }
                        slf.drawerInput.hideIfPossible()
                    })
            } else {
                subscription.disposable = Disposables.create()
            }
        }
    }

    // MARK: - Constructors

    init(drawerInput: DrawerInput,
         cameraManagerOutput: CameraManagerOutput,
         locationManagerOutput: LocationManagerOutput,
         strategy: DrawerHidingStrategy)
    {
        self.drawerInput = drawerInput
        self.cameraManagerOutput = cameraManagerOutput
        self.locationManagerOutput = locationManagerOutput
        self.strategy = strategy
    }

    // MARK: - Private Properties

    private let drawerInput: DrawerInput
    private let cameraManagerOutput: CameraManagerOutput
    private let locationManagerOutput: LocationManagerOutput
    private let strategy: DrawerHidingStrategy
    private let subscription = SerialDisposable()
}
