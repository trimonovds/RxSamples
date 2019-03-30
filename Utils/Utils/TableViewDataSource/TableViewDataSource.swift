//
//  TableViewDataSource.swift
//  iOSUtils
//
//  Created by Dmitry Trimonov on 15/10/2018.
//  Copyright © 2018 Dmitry Trimonov. All rights reserved.
//

import UIKit

public protocol TableViewCellConfigurator {
    static var reuseId: String { get }
    static var cellType: UITableViewCell.Type { get }
    func configure(cell: UITableViewCell)
}

public struct CellConfigurator<TCell: BindableTableViewCell, TModel>: TableViewCellConfigurator where TCell.Model == TModel {
    public static var cellType: UITableViewCell.Type { return TCell.self }
    public static var reuseId: String { return String(describing: cellType) }

    public let model: TModel

    public init(model: TModel) {
        self.model = model
    }

    public func configure(cell: UITableViewCell) {
        guard let bindableCell = cell as? TCell else { assert(false); return }
        bindableCell.bind(to: model)
    }
}

public protocol TableViewSectionConfigurator {
    var cellConfigurators: [TableViewCellConfigurator] { get }
}

public struct SectionConfigurator: TableViewSectionConfigurator {
    public let cellConfigurators: [TableViewCellConfigurator]

    public init(cellConfigurators: [TableViewCellConfigurator]) {
        self.cellConfigurators = cellConfigurators
    }
}

public class TableViewDataSource: NSObject, UITableViewDataSource {

    public var sectionConfigurations: [TableViewSectionConfigurator] = []

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellConfigurator = sectionConfigurations[safe: indexPath.section]?.cellConfigurators[safe: indexPath.row] else {
            return UITableViewCell()
        }
        let cellConfiguratorType = type(of: cellConfigurator)
        tableView.register(cellConfiguratorType.cellType, forCellReuseIdentifier: cellConfiguratorType.reuseId)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellConfiguratorType.reuseId, for: indexPath)
        cellConfigurator.configure(cell: cell)
        return cell
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return sectionConfigurations.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionConfigurations[section].cellConfigurators.count
    }
}


