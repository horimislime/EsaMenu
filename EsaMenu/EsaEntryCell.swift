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
    @IBOutlet weak var entryTitleContainerScrollView: NSScrollView!
    @IBOutlet var entryTitleField: NSTextField! {
        didSet {
            entryTitleField.backgroundColor = NSColor.clearColor()
        }
    }
    @IBOutlet weak var wipLabel: NSButton!
    @IBOutlet weak var wipLabelRightMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var wipLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var lastUpdateLabel: NSTextField! {
        didSet {
            lastUpdateLabel.backgroundColor = NSColor.clearColor()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wantsLayer = true
        layer?.backgroundColor = NSColor.whiteColor().CGColor
        entryCategoryField.backgroundColor = NSColor.clearColor()
        entryCategoryField.textColor = NSColor(type: .darkGray)
        entryTitleField.backgroundColor = NSColor.clearColor()
        userImageView.layer?.cornerRadius = userImageView.frame.width / 2
    }
    
    func configure(entry: Entry) {
        
        userImageView.image = NSImage(contentsOfURL: entry.updatedBy.iconURL)
        if entry.wip {
            self.alphaValue = 0.5
        } else {
            wipLabel.hidden = true
            wipLabelWidthConstraint.constant = 0
            wipLabelRightMarginConstraint.constant = 30
        }
        
        entryTitleField.stringValue = entry.name
        entryTitleField.editable = false
        
        entryCategoryField.stringValue = entry.category ?? ""
        
        let days = entry.updatedAt.mt_daysUntilDate(NSDate())
        if days > 3 {
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            lastUpdateLabel.stringValue = "By \(entry.updatedBy.screenName) \(formatter.stringFromDate(entry.updatedAt))"
        } else if days > 0 {
            lastUpdateLabel.stringValue = "By \(entry.updatedBy.screenName) \(days)d"
        } else if entry.updatedAt.mt_hoursUntilDate(NSDate()) > 0 {
            lastUpdateLabel.stringValue = "By \(entry.updatedBy.screenName) \(NSDate().mt_hoursSinceDate(entry.updatedAt))h"
        } else if entry.updatedAt.mt_minutesUntilDate(NSDate()) > 0 {
            lastUpdateLabel.stringValue = "By \(entry.updatedBy.screenName) \(NSDate().mt_minutesSinceDate(entry.updatedAt))m"
        } else {
            lastUpdateLabel.stringValue = "By \(entry.updatedBy.screenName) \(NSDate().mt_secondsSinceDate(entry.updatedAt))s"
        }
    }
}
