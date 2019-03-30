//
//  ImageBuilder.swift
//  Utils
//
//  Created by Dmitry Trimonov on 18/03/2019.
//  Copyright © 2019 Dmitry Trimonov. All rights reserved.
//

import UIKit

public final class ImageBuilder {
    public class func image(withSize size: CGSize, byRoundingCorners: UIRectCorner = UIRectCorner.allCorners,
                     cornerRadius: CGFloat = 0, color : UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        let path = UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: size), byRoundingCorners: byRoundingCorners, cornerRadii: CGSize(width:cornerRadius, height: cornerRadius))
        color.setFill();
        path.fill();
        let res = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        return res!;
    }
}
