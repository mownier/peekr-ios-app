//
//  Colors.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/7/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

enum Colors {
    
    static var gray1: UIColor? {
        return colorWith(name: "Gray1", default: UIColor(argb: 0xFFA4A9C2))
    }
    
    static var gray2: UIColor? {
        return colorWith(name: "Gray2", default: UIColor(argb: 0xFFF3F6FB))
    }
    
    static func colorWith(name: String, default: UIColor? = nil) -> UIColor? {
        if #available(iOS 11.0, *) {
            return UIColor(named: name)
        }
        
        return `default`
    }
}

extension UIColor {
    
    fileprivate convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
    
    // let's suppose alpha is the first component (ARGB)
    fileprivate  convenience init(argb: Int) {
        self.init(
            red: (argb >> 16) & 0xFF,
            green: (argb >> 8) & 0xFF,
            blue: argb & 0xFF,
            a: (argb >> 24) & 0xFF
        )
    }
}
