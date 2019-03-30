//
//  GenericBindableView.swift
//  RxSamples
//
//  Created by Dmitry Trimonov on 22/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation
import Utils
import RxSwift

open class GenericBindableView<ViewModelType: AnyObject>: BindableView {
    public typealias Model = ViewModelType

    open func bind(to model: ViewModelType) {
        viewModel = model
    }

    private(set) var viewModel: ViewModelType? {
        didSet {
            binding = DisposeBag()
        }
    }

    private(set) var binding = DisposeBag()
}
