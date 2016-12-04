//
//  UIViewExtension.swift
//  EsaMenu
//
//  Created by horimislime on 12/4/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Cocoa

enum NSViewBorderSide: String {
    case top
    case bottom
    case left
    case right
}

extension NSView {
    
    func addBorder(color: NSColor, width borderWidth: CGFloat, side: NSViewBorderSide) {
        
        wantsLayer = true
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.name = side.rawValue
        
        layer?.sublayers?
            .filter({ $0.name == border.name })
            .forEach({ $0.removeFromSuperlayer() })
        
        switch side {
        case .top:
            border.frame = CGRect(
                origin: self.bounds.origin,
                size: CGSize(width: self.bounds.width, height: borderWidth))
        case .bottom:
            border.frame = CGRect(
                origin: CGPoint(x: self.bounds.origin.x, y: self.bounds.height - borderWidth),
                size: CGSize(width: self.bounds.width, height: borderWidth))
        case .left:
            border.frame = CGRect(
                origin: self.bounds.origin,
                size: CGSize(width: borderWidth, height: self.bounds.height))
        case .right:
            border.frame = CGRect(
                origin: CGPoint(x: self.bounds.width - borderWidth, y: self.bounds.origin.y),
                size: CGSize(width: borderWidth, height: self.bounds.height))
        }
        
        layer?.addSublayer(border)
    }
}