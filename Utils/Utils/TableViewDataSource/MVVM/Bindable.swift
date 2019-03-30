//
//  Bindable.swift
//  Utils
//
//  Created by Dmitry Trimonov on 22/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation

public protocol Bindable {
    associatedtype Model
    func bind(to model: Model)
}
