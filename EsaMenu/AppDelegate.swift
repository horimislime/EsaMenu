//
//  AppDelegate.swift
//  EsaMenu
//
//  Created by horimislime on 9/18/16.
//  Copyright © 2016 horimislime. All rights reserved.
//

import Cocoa
import OAuthSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, TeamSelectionViewControllerDelegate {

    @IBOutlet weak var window: NSWindow!
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private var monitor: EventMonitor? = nil

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        guard let button = statusItem.button else { return }
        
        button.image = NSImage(named: "StatusBarButtonImage")
        button.action = #selector(statusBarButtonTapped(_:))
        
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        let teamController = TeamSelectionViewController(nibName: "TeamSelectionViewController", bundle: nil)
        teamController?.delegate = self
        popover.contentViewController = teamController
        
        monitor = EventMonitor(mask: [.LeftMouseDownMask, .RightMouseDownMask]) { [weak self] event in
            
            guard let strongSelf = self else { return }
            if strongSelf.popover.shown {
                strongSelf.popover.performClose(event)
            }
        }
        monitor?.start()
        
        NSAppleEventManager
            .sharedAppleEventManager()
            .setEventHandler(
                self,
                andSelector: #selector(handle(_:reply:)),
                forEventClass: UInt32(kInternetEventClass),
                andEventID: UInt32(kAEGetURL))
        
//        NSUserDefaults.standardUserDefaults().removeObjectForKey("esa-credential")
        guard let credential = NSUserDefaults.standardUserDefaults().objectForKey("esa-credential") else {
            Esa.authorize { [weak self] result in
                switch result {
                case .Success(let credential):
                    debugPrint("auth success")
                    NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(credential), forKey: "esa-credential")
                    self?.popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: .MinY)
                    
                case .Failure(let error):
                    debugPrint("auth error: \(error.localizedDescription)")
                }
            }
            return
        }
        
        popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: .MinY)
    }
    
    
    func handle(event: NSAppleEventDescriptor, reply: NSAppleEventDescriptor) {
        
        let urlString = event.paramDescriptorForKeyword(UInt32(keyDirectObject))?.stringValue
        guard let s = urlString, url = NSURL(string: s) else { return }
        
        if url.scheme == "esamenuapp" && url.host == "oauth-callback" {
            OAuth2Swift.handleOpenURL(url)
        }
    }

    func statusBarButtonTapped(sender: AnyObject) {
        
        if let button = statusItem.button where !popover.shown {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: .MinY)
            
        } else {
            popover.performClose(sender)
        }
    }
    
    func viewController(controller: TeamSelectionViewController, selectedTeam: Team) {
        NSUserDefaults.standardUserDefaults().setObject(selectedTeam.name, forKey: "esa-current-team-name")
        debugPrint("will change viewcontroller")
        popover.contentViewController = EsaEntriesViewController(nibName: "EsaEntriesViewController", bundle: nil)
    }
}

