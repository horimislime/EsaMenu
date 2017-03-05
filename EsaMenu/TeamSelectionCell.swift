//
//  TeamSelectionCell.swift
//  EsaMenu
//
//  Created by horimislime on 12/5/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Cocoa

class TeamSelectionCell: NSTableCellView {
    
    @IBOutlet weak var teamImageView: NSImageView!
    @IBOutlet weak var teamNameLabel: NSTextField!
    
    func configure(team: Team) {
        teamImageView.image = NSImage(contentsOf: URL(string: team.iconURLString)!)
        teamNameLabel.stringValue = team.name
    }
}
