//
//  EventCell.swift
//  RxSamples
//
//  Created by Dmitry Trimonov on 21/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation
import Utils

struct KudaGoEvent: Codable {
    var title: String
    var description: String
}

class KudaGoEventCell: BindableTableViewCell {
    typealias Model = KudaGoEvent

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(to model: KudaGoEvent) {
        self.textLabel?.text = model.title.uppercaseFirstLetterString()
        self.detailTextLabel?.attributedText = model.description.htmlToAttributedString
    }
}
