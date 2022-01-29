//
//  UIImage-Extension.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/15.
//

import UIKit

extension UIImage{
    func resize(size _size: CGSize) -> UIImage? {
           let widthRatio = _size.width / size.width
           let heightRatio = _size.height / size.height
           let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
           
           let resizeSize = CGSize(width: size.width * ratio, height: size.height * ratio)
           
           UIGraphicsBeginImageContextWithOptions(resizeSize, false, 0.0)
           draw(in: CGRect(origin: .zero, size: resizeSize))
           let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           
           return resizedImage
       }
}
