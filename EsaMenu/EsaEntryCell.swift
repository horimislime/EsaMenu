//
//  EsaEntryCell.swift
//  EsaMenu
//
//  Created by horimislime on 9/18/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Cocoa
import MTDates

final class EsaEntryCell: NSTableCellView {
    
    @IBOutlet weak var userImageView: NSImageView!
    @IBOutlet weak var entryCategoryField: NSTextField!
    @IBOutlet weak var entryTitleField: NSTextField!
    
    @IBOutlet weak var wipView: NSView!
    @IBOutlet weak var wipLabel: NSTextField! {
        didSet { wipLabel.wantsLayer = true }
    }
    @IBOutlet weak var wipLabelRightMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var wipLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var lastUpdateLabel: NSTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wantsLayer = true
        layer?.backgroundColor = NSColor.whiteColor().CGColor
        entryCategoryField.backgroundColor = NSColor.clearColor()
        entryCategoryField.textColor = NSColor(type: .darkGray)
        entryTitleField.backgroundColor = NSColor.clearColor()
        entryTitleField.selectable = false
        userImageView.layer?.cornerRadius = userImageView.frame.width / 2
        
//        wipView.wantsLayer = true
//        wipView.layer?.masksToBounds = true
//        wipView.layer?.backgroundColor = NSColor(type: .lightGray).CGColor
        wipView.layer?.cornerRadius = 5
    }
    
    func configure(entry: Entry) {
        
        userImageView.image = NSImage(contentsOfURL: entry.updatedBy.iconURL)
        if entry.wip {
            self.alphaValue = 0.5
        } else {
//            wipLabel.hidden = true
//            wipLabelWidthConstraint.constant = 0
//            wipLabelRightMarginConstraint.constant = 0
        }
        
        entryTitleField.setText(entry.name, link: NSURL(string: entry.url)!)
        entryCategoryField.stringValue = entry.category ?? ""
        
        let days = entry.updatedAt.mt_daysUntilDate(NSDate())
        if days > 3 {
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            lastUpdateLabel.stringValue = "By \(entry.updatedBy.screenName) \(formatter.stringFromDate(entry.updatedAt))"
        } else if days > 0 {
            lastUpdateLabel.stringValue = "By \(entry.updatedBy.screenName) \(days)d"
        } else {
            lastUpdateLabel.stringValue = "By \(entry.updatedBy.screenName) \(NSDate().mt_hoursSinceDate(entry.updatedAt))h"
        }
    }
}
