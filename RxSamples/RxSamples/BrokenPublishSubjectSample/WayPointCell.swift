//
//  WayPointCell.swift
//  RxSamples
//
//  Created by Dmitry Trimonov on 22/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation
import Utils

class WayPointCell: BindableTableViewCell {
    typealias Model = WayPointViewModel

    func bind(to viewModel: WayPointViewModel) {
        view = WayPointCellView(frame: .zero)
        view?.bind(to: viewModel)
    }

    var view: WayPointCellView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let v = view {
                v.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(v)
                NSLayoutConstraint.activate(v.pinToParent(withInsets: UIEdgeInsets.all(8.0)))
            }
        }
    }
}
