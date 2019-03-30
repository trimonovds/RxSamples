//
//  UIKit+Extensions.swift
//  Utils
//
//  Created by Dmitry Trimonov on 18/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import UIKit


extension UIColor {

    public convenience init(rgb value: UInt) {
        self.init(byteRed: UInt8((value >> 16) & 0xff),
                  green: UInt8((value >> 8) & 0xff),
                  blue: UInt8(value & 0xff),
                  alpha: 0xff)
    }

    public convenience init(rgba value: UInt) {
        self.init(byteRed: UInt8((value >> 24) & 0xff),
                  green: UInt8((value >> 16) & 0xff),
                  blue: UInt8((value >> 8) & 0xff),
                  alpha: UInt8(value & 0xff))
    }

    public convenience init(byteRed red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 0xff) {
        self.init(red: CGFloat(red) / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue: CGFloat(blue) / 255.0,
                  alpha: CGFloat(alpha) / 255.0)
    }

    public static var random: UIColor {
        return UIColor(red: randComponent(), green: randComponent(), blue: randComponent(), alpha: 1.0)
    }

    public static func randComponent() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}


extension UIEdgeInsets {

    public static func from(edge: UIRectEdge, inset: CGFloat) -> UIEdgeInsets {
        let top: CGFloat = edge.contains(.top) ? inset : 0.0
        let left: CGFloat = edge.contains(.left) ? inset : 0.0
        let bottom: CGFloat = edge.contains(.bottom) ? inset : 0.0
        let right: CGFloat = edge.contains(.right) ? inset : 0.0
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    public  static func except(edge: UIRectEdge, inset: CGFloat) -> UIEdgeInsets {
        let top: CGFloat = edge.contains(.top) ? 0.0 : inset
        let left: CGFloat = edge.contains(.left) ? 0.0 : inset
        let bottom: CGFloat = edge.contains(.bottom) ? 0.0 : inset
        let right: CGFloat = edge.contains(.right) ? 0.0 : inset
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    public  static func left(_ inset: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: inset, bottom: 0.0, right: 0.0)
    }

    public  static func right(_ inset: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: inset)
    }

    public  static func top(_ inset: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: 0.0, bottom: 0.0, right: 0.0)
    }

    public  static func bottom(_ inset: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: inset, right: 0.0)
    }

    public  static func all(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }

    public  static func horizontal(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: value, bottom: 0.0, right: value)
    }

    public  static func vertical(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: value, left: 0.0, bottom: value, right: 0.0)
    }

}

extension UIEdgeInsets {

    public func withTop(_ top: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: top, left: self.left, bottom: self.bottom, right: self.right)
    }

    public func withLeft(_ left: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.top, left: left, bottom: self.bottom, right: self.right)
    }

    public func withBottom(_ bottom: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.top, left: self.left, bottom: bottom, right: self.right)
    }

    public func withRight(_ right: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.top, left: self.left, bottom: self.bottom, right: right)
    }

    public func withHorizontal(_ horizontal: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.top, left: horizontal, bottom: self.bottom, right: horizontal)
    }

    public func withVertical(_ vertical: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: vertical, left: self.left, bottom: vertical, right: self.right)
    }

    public func addMargins(margin: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: top + margin,
            left: left + margin,
            bottom: bottom + margin,
            right: right + margin
        )
    }

    public func adding(insets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: top + insets.top,
            left: left + insets.left,
            bottom: bottom + insets.bottom,
            right: right + insets.right
        )
    }

}
