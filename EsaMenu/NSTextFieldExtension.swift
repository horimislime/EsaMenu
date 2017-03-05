//
//  NSTextFieldExtension.swift
//  EsaMenu
//
//  Created by horimislime on 2016/09/28.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Cocoa

extension NSTextField {
    func setText(text: String, link: NSURL) {
        allowsEditingTextAttributes = true
//        selectable = true
        attributedStringValue = NSAttributedString.hyperlink(text: text, link: link)
    }
}
