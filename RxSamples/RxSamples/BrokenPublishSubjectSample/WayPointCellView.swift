//
//  WayPointCellView.swift
//  RxSamples
//
//  Created by Dmitry Trimonov on 22/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation
import Utils
import RxSwift
import RxCocoa

class WayPointCellView: GenericBindableView<WayPointViewModel> {
    override init(frame: CGRect) {
        super.init(frame: frame)

        clearButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(clearButton)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)

        boundTimesLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(boundTimesLabel)

        clearButton.setImage(UIImage.init(named: "close_icon")!, for: .normal)
        clearButton.tintColor = .black

        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        boundTimesLabel.font = UIFont.preferredFont(forTextStyle: .caption1)

        nameLabel.textColor = .black
        boundTimesLabel.textColor = .blue

        NSLayoutConstraint.activate(
            nameLabel.pinToParent(withEdges: [.left, .top]) +
                boundTimesLabel.pinToParent(withEdges: [.left, .bottom]) +
                [
                    boundTimesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8.0),
                    clearButton.heightAnchor.constraint(equalToConstant: 20),
                    clearButton.widthAnchor.constraint(equalToConstant: 20)
                ] +
                clearButton.pinToParent(withEdges: [.right]) +
                clearButton.centerInParent(.vertically)
        )

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func bind(to viewModel: WayPointViewModel) {
        super.bind(to: viewModel)
        viewModel.boundTimes += 1

        self.boundTimesLabel.text = "Bound \(viewModel.boundTimes) times"

        viewModel.state.bind(onNext: { [weak self] state in
            guard let slf = self else { return }

            switch state {
            case .empty:
                slf.nameLabel.textColor = UIColor.black.withAlphaComponent(0.6)
                slf.nameLabel.text = "Неизвестно"
                slf.clearButton.alpha = 0.0
            case .filled(let wp):
                slf.nameLabel.textColor = UIColor.black
                slf.nameLabel.text = wp.name
                slf.clearButton.alpha = 1.0
            }
        }).disposed(by: binding)

        clearButton.rx.tap.bind(to: viewModel.taps).disposed(by: binding)

    }

    private let nameLabel = UILabel()
    private let boundTimesLabel = UILabel()
    private let clearButton = UIButton(type: .system)
}
