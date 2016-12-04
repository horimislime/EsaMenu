//
//  EsaEntriesViewController.swift
//  EsaMenu
//
//  Created by horimislime on 9/18/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Cocoa

class EsaEntriesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var settingsButton: NSButton!
    
    @IBAction func settingsButtonTapped(sender: AnyObject) {
        let menu = NSMenu(title: "settings")
        menu.insertItemWithTitle("Quit", action: #selector(quitMenuTapped(_:)), keyEquivalent: "q", atIndex: 0)
        NSMenu.popUpContextMenu(menu, withEvent: NSApplication.sharedApplication().currentEvent!, forView: settingsButton)
    }
    
    func quitMenuTapped(sender: NSMenu) {
        Swift.debugPrint("quitMenuTapped")
        NSApplication.sharedApplication().terminate(sender)
    }
    
    private var entries = FetchedEntries()
    private weak var timer: NSTimer?
    
    private var updating = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.cornerRadius = 4
        tableView.registerNib(NSNib(nibNamed: "EsaEntryCell", bundle: nil), forIdentifier: "EsaEntryCellIdentifier")
        tableView.registerNib(NSNib(nibNamed: "EsaEntryLoadCell", bundle: nil), forIdentifier: "EsaEntryLoadCellIdentifier")
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        tableView.selectionHighlightStyle = .None
        tableView.focusRingType = .None
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(scrollViewDidScroll(_:)), name: NSViewBoundsDidChangeNotification, object: scrollView.contentView)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(updatePosts(_:)), userInfo: nil, repeats: true)
        
        
        timer?.fire()
    }
    
    func scrollViewDidScroll(notification: NSNotification) {
        
        guard let contentView = scrollView.documentView else  { return }
        
        if contentView.visibleRect.origin.y > (contentView.frame.height - 300) && !updating {
            fetchMorePosts()
        }
    }
    
    deinit {
        timer?.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updatePosts(timer: NSTimer) {
        Swift.debugPrint("timer fired")
        progress.hidden = false
        progress.startAnimation(self)
        tableView.reloadData()
        
        if entries.count == 0 {
            FetchedEntries.fetch() { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .Success(let entries):
                    Swift.debugPrint("success")
                    strongSelf.entries = entries
                    strongSelf.tableView.reloadData()
                    
                case .Failure(_):
                    Swift.debugPrint("error")
                }
                strongSelf.progress.hidden = true
            }
            
        } else {
            entries.fetchLatest { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.tableView.reloadData()
                strongSelf.progress.hidden = true
            }
        }
    }
    
    func fetchMorePosts() {
        
        updating = true
        progress.startAnimation(self)
        
        entries.fetchMore { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.updating = false
            strongSelf.tableView.reloadData()
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        if entries.count == 0 {
            return 0
        }
        
        tableView.gridColor = (entries.count == 0) ? NSColor.clearColor() : NSColor(type: .lightGray)
        return entries.count + 1
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == (self.numberOfRowsInTableView(tableView) - 1) {
            return 30
        }
        let cell = tableView.makeViewWithIdentifier("EsaEntryCellIdentifier", owner: self) as! EsaEntryCell
        cell.configure(entries.sorted()[row])
        cell.layoutSubtreeIfNeeded()
        return cell.frame.height
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if row == (self.numberOfRowsInTableView(tableView) - 1) {
            let cell = tableView.makeViewWithIdentifier("EsaEntryLoadCellIdentifier", owner: self) as! EsaEntryLoadCell
            cell.progress.startAnimation(self)
            return cell
        }
        
        let cell = tableView.makeViewWithIdentifier("EsaEntryCellIdentifier", owner: self) as! EsaEntryCell
        cell.configure(entries.sorted()[row])
        return cell
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        
        
        return nil
    }
    
    func selectionShouldChangeInTableView(tableView: NSTableView) -> Bool {
        
        if tableView.selectedRow == -1 { return true }
        
        let cell = tableView.viewAtColumn(0, row: tableView.selectedRow, makeIfNecessary: true)
        cell!.layer!.backgroundColor = NSColor.clearColor().CGColor
        return true
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: entries.sorted()[row].url)!)
        
        let cell = tableView.viewAtColumn(0, row: row, makeIfNecessary: true)
        cell!.layer!.backgroundColor = NSColor(type: .lightGray).CGColor
        return true
    }
}
