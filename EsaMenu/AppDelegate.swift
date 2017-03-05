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
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private var monitor: EventMonitor? = nil

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        guard let button = statusItem.button else { return }
        
        button.image = NSImage(named: "StatusBarButtonImage")
        button.action = #selector(statusBarButtonTapped(_:))
        
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        if let _ = UserDefaults.standard.object(forKey: "esa-credential"), let _ = UserDefaults.standard.object(forKey: "esa-current-team-name") {
            showEntriesPopover()
            
        } else {
            showSignInPopover()
        }
        
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
        
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }
    
    
    func handle(event: NSAppleEventDescriptor, reply: NSAppleEventDescriptor) {
        
        let urlString = event.paramDescriptor(forKeyword: UInt32(keyDirectObject))?.stringValue
        guard let s = urlString, let url = NSURL(string: s) else { return }
        
        if url.scheme == "esamenuapp" && url.host == "oauth-callback" {
            OAuth2Swift.handleOpenURL(url)
        }
    }

    func statusBarButtonTapped(sender: AnyObject) {
        
        if let button = statusItem.button, !popover.isShown {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            
        } else {
            popover.performClose(sender)
        }
    }
    
    func showSignInPopover() {
        
        let controller = SignInViewController(nibName: "SignInViewController", bundle: nil)
        controller?.delegate = self
        popover.contentViewController = controller
        
        if let button = statusItem.button, !popover.isShown {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    func showTeamSelectionPopover() {
        
        let controller = TeamSelectionViewController(nibName: "TeamSelectionViewController", bundle: nil)
        controller?.delegate = self
        popover.contentViewController = controller
        
        if let button = statusItem.button, !popover.isShown {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    func showEntriesPopover() {
        popover.contentViewController = EsaEntriesViewController(nibName: "EsaEntriesViewController", bundle: nil)
        if let button = statusItem.button, !popover.isShown {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}

// MARK: SignInViewControllerDelegate

extension AppDelegate: SignInViewControllerDelegate {
    func signInFinished(controller: SignInViewController) {
        showTeamSelectionPopover()
    }
    
    func signInFailed(controller: SignInViewController, error: NSError) {
        
    }
}

// MARK: TeamSelectionViewControllerDelegate

extension AppDelegate: TeamSelectionViewControllerDelegate {
    func viewController(controller: TeamSelectionViewController, selectedTeam: Team) {
        UserDefaults.standard.set(selectedTeam.name, forKey: "esa-current-team-name")
        showEntriesPopover()
    }
}









