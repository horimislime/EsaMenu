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
    @IBOutlet weak var settingsButton: NSButton!
    
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
    
    @IBAction func settingsButtonTapped(sender: NSButton) {
        let menu = NSMenu(title: "settings")
        menu.insertItemWithTitle("Sign out", action: #selector(signOutMenuTapped(_:)), keyEquivalent: "", atIndex: 0)
        menu.insertItemWithTitle("Quit", action: #selector(quitMenuTapped(_:)), keyEquivalent: "q", atIndex: 1)
        NSMenu.popUpContextMenu(menu, withEvent: NSApplication.sharedApplication().currentEvent!, forView: settingsButton)
    }
    
    func signOutMenuTapped(sender: NSMenu) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("esa-credential")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("esa-current-team-name")
        (NSApplication.sharedApplication().delegate as? AppDelegate)?.showSignInPopover()
    }
    
    func quitMenuTapped(sender: NSMenu) {
        NSApplication.sharedApplication().terminate(sender)
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
