//
//  NSAttributedStringExtension.swift
//  EsaMenu
//
//  Created by horimislime on 2016/09/28.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Cocoa

extension NSAttributedString {
    class func hyperlink(text: String, link: NSURL) -> NSAttributedString {
        
        let attr = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: text.characters.count)
        
        attr.beginEditing()
        attr.addAttribute(NSLinkAttributeName, value: link.absoluteURL ?? "", range: range)
        attr.addAttribute(NSForegroundColorAttributeName,
                                value: NSColor.blue, range: range)
        attr.addAttribute(NSUnderlineStyleAttributeName,
                                value: NSUnderlineStyle.styleSingle.rawValue, range: range)
        attr.endEditing()
        
        return attr
    }
}
