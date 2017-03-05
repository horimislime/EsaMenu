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
        tableView.register(NSNib(nibNamed: "TeamSelectionCell", bundle: nil), forIdentifier: "TeamSelectionCellIdentifier")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.focusRingType = .none
        
        Team.list { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let teams):
                strongSelf.teams = teams
                strongSelf.tableView.reloadData()
            case .failure(_):()
            }
        }
    }
    
    @IBAction func settingsButtonTapped(sender: NSButton) {
        let menu = NSMenu(title: "settings")
        menu.insertItem(withTitle: "Sign out", action: #selector(signOutMenuTapped(sender:)), keyEquivalent: "", at: 0)
        menu.insertItem(withTitle: "Quit", action: #selector(quitMenuTapped(sender:)), keyEquivalent: "q", at: 1)
        NSMenu.popUpContextMenu(menu, with: NSApplication.shared().currentEvent!, for: settingsButton)
    }
    
    func signOutMenuTapped(sender: NSMenu) {
        UserDefaults.standard.removeObject(forKey: "esa-credential")
        UserDefaults.standard.removeObject(forKey: "esa-current-team-name")
        (NSApplication.shared().delegate as? AppDelegate)?.showSignInPopover()
    }
    
    func quitMenuTapped(sender: NSMenu) {
        NSApplication.shared().terminate(sender)
    }
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return teams.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.make(withIdentifier: "TeamSelectionCellIdentifier", owner: self) as! TeamSelectionCell
        cell.configure(team: teams[row])
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        delegate?.viewController(controller: self, selectedTeam: teams[tableView.selectedRow])
    }
}
