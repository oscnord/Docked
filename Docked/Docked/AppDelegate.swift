//
//  AppDelegate.swift
//  Docked
//
//  Created by Oscar Nord on 2019-05-06.
//  Copyright © 2019 Oscar Nord. All rights reserved.
//

import Foundation
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var appMenu: NSMenu!
    //status bar item object
    var statusItem: NSStatusItem?
    private var firstLaunch = true
    
    @objc func displayMenu() {
        guard let button = statusItem?.button else { return }
        let x = button.frame.origin.x
        let y = button.frame.origin.y - 5
        let location = button.superview!.convert(NSMakePoint(x, y), to: nil)
        let w = button.window!
        let event = NSEvent.mouseEvent(with: .leftMouseUp,
                                       location: location,
                                       modifierFlags: NSEvent.ModifierFlags(rawValue: 0),
                                       timestamp: 0,
                                       windowNumber: w.windowNumber,
                                       context: NSGraphicsContext.init(),
                                       eventNumber: 0,
                                       clickCount: 1,
                                       pressure: 0)!
        NSMenu.popUpContextMenu(appMenu, with: event, for: button)
    }
    
    func checkDisplay() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(screenDidChange),
                                               name: NSApplication.didChangeScreenParametersNotification,
                                               object: nil)
    }
    
    func showHideDock(mode: String) {
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: mode) {
            if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
                &error) {
            } else if (error != nil) {
                print("error: \(String(describing: error))")
            }
        }
    }
    
    // Show/hide Dock when external screen is connected/disconnected
    @objc final func screenDidChange(notification: NSNotification){
        let showDock = #"tell app "System Events" to tell dock preferences to set autohide to false"#
        let hideDock = #"tell app "System Events" to tell dock preferences to set autohide to true"#
        
        if(NSScreen.screens.count > 1) {
            showHideDock(mode: showDock)
            statusItem?.button?.image = NSImage(named: "docked-connected")
        } else {
            showHideDock(mode: hideDock)
            statusItem?.button?.image = NSImage(named: "docked-disconnected")
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
        // Check if statusbar is full
        guard let button = statusItem?.button else {
            print("Status Bar is full.")
            NSApp.terminate(nil)
            return
        }
        
        button.image = NSImage(named: "docked-disconnected")
        button.target = self
        
        // check if first launch and if external screen is connected
        if(firstLaunch == true) {
            firstLaunch = false
         
            if(NSScreen.screens.count > 1) {
                let showDock = #"tell app "System Events" to tell dock preferences to set autohide to false"#
                showHideDock(mode: showDock)
                statusItem?.button?.image = NSImage(named: "docked-connected")
            }
        }
        if let button = statusItem?.button {
            button.action = #selector(self.statusBarButtonClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            // check if external display is connected
            checkDisplay()
        }
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        if NSApp.currentEvent!.type == NSEvent.EventType.rightMouseUp {
            displayMenu()
        }
    }
}

