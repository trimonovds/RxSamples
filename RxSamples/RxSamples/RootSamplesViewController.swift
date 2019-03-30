//
//  RootSamplesViewController.swift
//  RxSamples
//
//  Created by Dmitry Trimonov on 22/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import UIKit
import Utils

enum Sample: CaseIterable {
    case search
    case cardCollapsingSimple
    case cardCollapsingSmart
    case brokenPublishSubject
    case mapSearch

    var name: String {
        switch self {
        case .search:
            return "Поиск KudaGo"
        case .cardCollapsingSimple:
            return "Скрывание карточки - простая логика"
        case .cardCollapsingSmart:
            return "Скрывание карточки - сложная логика"
        case .brokenPublishSubject:
            return "Сломанный PublishSubject"
        case .mapSearch:
            return "Поиск на карте"
        }
    }
}

class SampleCell: BindableTableViewCell {
    typealias Model = Sample

    func bind(to model: Sample) {
        self.textLabel?.text = model.name
    }
}

class RootSamplesViewController: UIViewController, UITableViewDelegate {
    typealias SampleCellConfigurator = CellConfigurator<SampleCell, Sample>

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "RxSamples"

        dataSource.sectionConfigurations = [
            SectionConfigurator(cellConfigurators:
                Sample.allCases.map { SampleCellConfigurator(model: $0) }
            )
        ]

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.dataSource = dataSource
        tableView.delegate = self

        tableView.pinToParentSafe().forEach { $0.isActive = true }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedSample = Sample.allCases[indexPath.row]
        let vc: UIViewController
        switch selectedSample {
        case .search:
            vc = KudaGoSearchViewController()
        case .cardCollapsingSimple:
            vc = CardViewController(kind: .simple)
        case .cardCollapsingSmart:
            vc = CardViewController(kind: .smart)
        case .brokenPublishSubject:
            vc = WayPointsViewController()
        case .mapSearch:
            vc = MapKudaGoSearchViewController()
        }
        vc.title = selectedSample.name
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private let dataSource = TableViewDataSource()
    private let tableView = UITableView()
}
