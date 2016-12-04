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
    @IBOutlet weak var lastUpdateLabel: NSTextField!
    
    @IBOutlet weak var wipLabelRightMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var wipLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryTopMarginConstraint: NSLayoutConstraint!
    
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
            wipLabelWidthConstraint.constant = 0
            wipLabelRightMarginConstraint.constant = 0
        }
        
        entryTitleField.stringValue = entry.name
        entryTitleField.editable = false
        
        if let category = entry.category {
            entryCategoryField.stringValue = category
        } else {
            entryCategoryField.stringValue = ""
            categoryTopMarginConstraint.constant = 0
        }
        
        
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
