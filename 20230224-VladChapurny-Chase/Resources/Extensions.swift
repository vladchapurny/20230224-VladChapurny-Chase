//
//  Extensions.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import UIKit

// TODO: Probably separate Extensions in different classes.

// MARK: - UIView Extensions
extension UIView {
    /// Applies a custom blue to system color gradient
    func customGradient() {
        
        /// Making sure to not overflow the sublayers array with the same gradient by removing the gradient if it is already there
        if layer.sublayers?.first is CAGradientLayer {
            layer.sublayers?.first?.removeFromSuperlayer()
        }
        
        /// Creating custom gradient
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [UIColor.systemBlue.cgColor, UIColor.systemBackground.cgColor]
        gradient.startPoint = CGPoint.zero
        layer.insertSublayer(gradient, at: 0)
    }
}

// MARK: - UIFont Extensions
extension UIFont {
    
    /// AF (Accessibility Friendly) scalable fonts for accessibility
    
    /// Accessibility Regular Font
    static func AFFontRegular(size: CGFloat) -> UIFont {
        return UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: size, weight: .regular))
    }
    
    /// Accessibility Bold Font
    static func AFFontBold(size: CGFloat) -> UIFont {
        return UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: size, weight: .bold))
    }
}
