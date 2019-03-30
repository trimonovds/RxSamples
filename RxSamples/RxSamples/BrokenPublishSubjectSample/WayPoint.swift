//
//  WayPoint.swift
//  RxSamples
//
//  Created by Dmitry Trimonov on 22/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation
import CoreLocation

enum WayPointState {
    case empty
    case filled(WayPoint)
}

struct WayPoint {
    let name: String
}
