//
//  EsaEntriesViewController.swift
//  EsaMenu
//
//  Created by horimislime on 9/18/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Cocoa
import DateTools

class EsaEntriesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var settingsButton: NSButton!
    @IBOutlet weak var footerView: NSView! {
        didSet {
            footerView.addBorder(color: NSColor.lightGray, width: 0.5, side: .bottom)
        }
    }
    
    @IBOutlet weak var lastUpdateLabel: NSTextField!
    
    @IBAction func settingsButtonTapped(sender: AnyObject) {
        let menu = NSMenu(title: "settings")
        menu.insertItem(withTitle: "Sign out", action: #selector(signOutMenuTapped(sender:)), keyEquivalent: "", at: 0)
        menu.insertItem(withTitle: "Quit", action: #selector(quitMenuTapped(sender:)), keyEquivalent: "q", at: 1)
        NSMenu.popUpContextMenu(menu, with: NSApplication.shared().currentEvent!, for: settingsButton)
    }
    
    func signOutMenuTapped(sender: NSMenu) {
        timer?.invalidate()
        UserDefaults.standard.removeObject(forKey: "esa-credential")
        UserDefaults.standard.removeObject(forKey: "esa-current-team-name")
        (NSApplication.shared().delegate as? AppDelegate)?.showSignInPopover()
    }
    
    func quitMenuTapped(sender: NSMenu) {
        Swift.debugPrint("quitMenuTapped")
        NSApplication.shared().terminate(sender)
    }
    
    private var entries = FetchedEntries()
    private weak var timer: Timer?
    private weak var lastUpdateTimer: Timer?
    
    private var updating = false
    private var lastUpdated: NSDate? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.cornerRadius = 4
        view.layer?.backgroundColor = NSColor.white.cgColor
        tableView.register(NSNib(nibNamed: "EsaEntryCell", bundle: nil), forIdentifier: "EsaEntryCellIdentifier")
        tableView.register(NSNib(nibNamed: "EsaEntryLoadCell", bundle: nil), forIdentifier: "EsaEntryLoadCellIdentifier")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.selectionHighlightStyle = .none
        tableView.focusRingType = .none
        tableView.gridColor = NSColor.clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(scrollViewDidScroll(notification:)), name: NSNotification.Name.NSViewBoundsDidChange, object: scrollView.contentView)
        
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updatePosts(timer:)), userInfo: nil, repeats: true)
        timer?.fire()
        lastUpdateTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(reloadLastUpdatedLabel), userInfo: nil, repeats: true)
        lastUpdateTimer?.fire()
    }
    
    func scrollViewDidScroll(notification: NSNotification) {
        
        guard let contentView = scrollView.documentView else  { return }
        if contentView.visibleRect.origin.y > (contentView.frame.height - 500) && !updating {
            fetchMorePosts()
        }
    }
    
    deinit {
        timer?.invalidate()
        lastUpdateTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    func updatePosts(timer: Timer) {
        Swift.debugPrint("timer fired")
        progress.isHidden = false
        progress.startAnimation(self)
        tableView.reloadData()
        
        if entries.count == 0 {
            FetchedEntries.fetch() { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let entries):
                    Swift.debugPrint("success")
                    strongSelf.entries = entries
                    strongSelf.tableView.reloadData()
                    strongSelf.lastUpdated = NSDate()
                    strongSelf.reloadLastUpdatedLabel()
                    
                case .failure(_):
                    Swift.debugPrint("error")
                }
                strongSelf.progress.isHidden = true
            }
            
        } else {
            entries.fetchLatest { [weak self] error in
                guard let strongSelf = self else { return }
                strongSelf.tableView.reloadData()
                strongSelf.progress.isHidden = true
                strongSelf.lastUpdated = NSDate()
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
    
    func reloadLastUpdatedLabel() {
        guard let date = lastUpdated else { return }
        lastUpdateLabel.stringValue = "Last Updated: \(date.timeAgoSinceNow())"
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        if entries.count == 0 {
            return 0
        }
        
        tableView.gridColor = (entries.count == 0) ? NSColor.clear : NSColor(type: .lightGray)
        return entries.count + 1
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if row == (self.numberOfRowsInTableView(tableView: tableView) - 1) {
            return 30
        }
        let cell = tableView.make(withIdentifier: "EsaEntryCellIdentifier", owner: self) as! EsaEntryCell
        cell.configure(entry: entries.sorted()[row])
        cell.layoutSubtreeIfNeeded()
        return cell.frame.height
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if row == (self.numberOfRowsInTableView(tableView: tableView) - 1) {
            let cell = tableView.make(withIdentifier: "EsaEntryLoadCellIdentifier", owner: self) as! EsaEntryLoadCell
            cell.progress.startAnimation(self)
            return cell
        }
        
        let cell = tableView.make(withIdentifier: "EsaEntryCellIdentifier", owner: self) as! EsaEntryCell
        cell.configure(entry: entries.sorted()[row])
        return cell
    }
    
    func selectionShouldChangeInTableView(tableView: NSTableView) -> Bool {
        
        if tableView.selectedRow == -1 { return true }
        
        let cell = tableView.view(atColumn: 0, row: tableView.selectedRow, makeIfNecessary: true)
        cell!.layer!.backgroundColor = NSColor.clear.cgColor
        return true
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        NSWorkspace.shared().open(NSURL(string: entries.sorted()[row].url)! as URL)
        
        let cell = tableView.view(atColumn: 0, row: row, makeIfNecessary: true)
        cell!.layer!.backgroundColor = NSColor(type: .lightGray).cgColor
        return true
    }
}
