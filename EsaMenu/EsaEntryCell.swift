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
        layer?.backgroundColor = NSColor.white.cgColor
        entryCategoryField.backgroundColor = NSColor.clear
        entryCategoryField.textColor = NSColor(type: .darkGray)
        entryTitleField.backgroundColor = NSColor.clear
        userImageView.layer?.cornerRadius = userImageView.frame.width / 2
    }
    
    func configure(entry: Entry) {
        
        userImageView.image = NSImage(contentsOf: entry.updatedBy.iconURL as URL)
        
        if entry.wip {
            self.alphaValue = 0.5
        } else {
            wipLabelWidthConstraint.constant = 0
            wipLabelRightMarginConstraint.constant = 0
        }
        
        entryTitleField.stringValue = entry.name
        entryTitleField.isEditable = false
        
        if let category = entry.category {
            entryCategoryField.stringValue = category
        } else {
            entryCategoryField.stringValue = ""
            categoryTopMarginConstraint.constant = 0
        }
        
        
        let days = entry.updatedAt.mt_days(until: NSDate() as Date!)
        if days > 3 {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            lastUpdateLabel.stringValue = "By \(entry.updatedBy.screenName) \(formatter.string(from: entry.updatedAt as Date))"
        } else if days > 0 {
            lastUpdateLabel.stringValue = "By \(entry.updatedBy.screenName) \(days)d"
        } else if entry.updatedAt.mt_hours(until: NSDate() as Date!) > 0 {
            lastUpdateLabel.stringValue = "By \(entry.updatedBy.screenName) \(NSDate().mt_hours(since: entry.updatedAt as Date!))h"
        } else if entry.updatedAt.mt_minutes(until: NSDate() as Date!) > 0 {
            lastUpdateLabel.stringValue = "By \(entry.updatedBy.screenName) \(NSDate().mt_minutes(since: entry.updatedAt as Date!))m"
        } else {
            lastUpdateLabel.stringValue = "By \(entry.updatedBy.screenName) \(NSDate().mt_seconds(since: entry.updatedAt as Date!))s"
        }
    }
}
