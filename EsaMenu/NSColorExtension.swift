//
//  NSColorExtension.swift
//  EsaMenu
//
//  Created by horimislime on 9/19/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Cocoa

enum ColorType: Int {
    case darkGray = 0x9D9D9D
    case lightGray = 0xE7E9E9
    case esaGreen = 0x0a9b94
    case black = 0x000000
}

extension NSColor {
    convenience init(type: ColorType, alpha: CGFloat = 1.0) {
        let red = CGFloat((type.rawValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((type.rawValue & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((type.rawValue & 0xFF)) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
