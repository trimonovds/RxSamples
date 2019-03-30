//
//  WayPointsSample.swift
//  RxPrimitivesLifecycle
//
//  Created by Dmitry Trimonov on 18/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation
import Utils
import RxSwift
import RxCocoa
import CoreLocation

class WayPointsViewController: UIViewController, UITableViewDelegate {

    typealias WayPointCellConfigurator = CellConfigurator<WayPointCell, WayPointViewModel>

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.dataSource = dataSource
        tableView.delegate = self

        NSLayoutConstraint.activate(
            tableView.pinToParentSafe(withEdges: [.top, .bottom, .left, .right])
        )

        let cellViewModels: [WayPointViewModel] = (0...100).map { i -> WayPointViewModel in
            let state: WayPointState = .filled(WayPoint(name: "Точка \(i)"))
            let cellVm = WayPointViewModel()
            cellVm.taps.bind {
                cellVm.state.accept(.empty)
            }.disposed(by: cellVm.bag)
            cellVm.state.accept(state)
            return cellVm
        }
        updateDataSource(with: cellViewModels)
    }

    private let dataSource = TableViewDataSource()
    private let tableView: UITableView = UITableView()
}

fileprivate extension WayPointsViewController {
    private func updateDataSource(with cellViewModels: [WayPointViewModel]) {
        dataSource.sectionConfigurations = [
            SectionConfigurator(cellConfigurators: cellViewModels.map { WayPointCellConfigurator(model: $0) })
        ]
    }
}
