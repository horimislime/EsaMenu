//
//  TeamSelectionViewController.swift
//  EsaMenu
//
//  Created by horimislime on 12/5/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Cocoa

protocol TeamSelectionViewControllerDelegate: class {
    func viewController(controller: TeamSelectionViewController, selectedTeam: Team)
}

final class TeamSelectionViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var teams = [Team]()
    weak var delegate: TeamSelectionViewControllerDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.registerNib(NSNib(nibNamed: "TeamSelectionCell", bundle: nil), forIdentifier: "TeamSelectionCellIdentifier")
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        tableView.focusRingType = .None
        
        Team.list { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .Success(let teams):
                strongSelf.teams = teams
                strongSelf.tableView.reloadData()
            case .Failure(_):()
            }
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return teams.count
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 62
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("TeamSelectionCellIdentifier", owner: self) as! TeamSelectionCell
        cell.configure(teams[row])
        return cell
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        delegate?.viewController(self, selectedTeam: teams[tableView.selectedRow])
    }
}
