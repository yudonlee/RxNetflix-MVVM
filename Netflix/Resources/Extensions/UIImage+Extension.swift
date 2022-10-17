//
//  UIImage+Extension.swift
//  Netflix
//
//  Created by yudonlee on 2022/07/09.
//

import Foundation
import UIKit

extension UIImage {
//    https://stackoverflow.com/questions/64918566/navigation-bar-items-not-left-aligned
//    해당 함수의 문제는 image size를 원하는대로 rescale할수 있지만, 
    func resizeTo(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            self.draw(in: CGRect.init(origin: CGPoint.zero, size: size))
        }
        
        return image.withRenderingMode(self.renderingMode)
    }
}
