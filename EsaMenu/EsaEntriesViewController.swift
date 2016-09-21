//
//  EsaEntriesViewController.swift
//  EsaMenu
//
//  Created by horimislime on 9/18/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Cocoa

class EsaEntriesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var tableView: NSTableView!
    
    private var entries = [Entry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(NSNib(nibNamed: "EsaEntryCell", bundle: nil), forIdentifier: "EsaEntryCellIdentifier")
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        
        
        Entry.list() { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .Success(let entries):
                print("success")
                strongSelf.entries = entries
                strongSelf.tableView.reloadData()
                
            case .Failure(let error):
                print("error")
            }
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        tableView.gridColor = (entries.count == 0) ? NSColor.clearColor() : NSColor(type: .lightGray)
        return entries.count
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 45
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("EsaEntryCellIdentifier", owner: self) as! EsaEntryCell
        cell.configure(entries[row])
        return cell
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        
        
        return "hoge"
    }
}
