//
//  Foundation+Extensions.swift
//  Utils
//
//  Created by Dmitry Trimonov on 22/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import Foundation

extension String {
    public var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }

    public var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }

    public func uppercaseFirstLetterString() -> String {
        if self.isEmpty {
            return self
        } else {
            return String(self.characters.prefix(1)).uppercased(with: Locale.current) + String(self.characters.suffix(count - 1))
        }
    }
}

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    public subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
