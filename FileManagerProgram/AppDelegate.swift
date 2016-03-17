//
//  AppDelegate.swift
//  SidebarProgram
//
//  Created by Fred Stidston on 01/03/2016.
//  Copyright © 2016 Fred Stidston. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var viewController: ViewController!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        window.windowDidResize
        viewController = ViewController(nibName: "ViewController", bundle: nil)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        window.contentView!.addSubview(viewController.view)
        viewController.view.frame = (window.contentView! as NSView).bounds
        viewController.view.leadingAnchor.constraintEqualToAnchor(viewController.view.superview!.leadingAnchor).active = true
        viewController.view.topAnchor.constraintEqualToAnchor(viewController.view.superview!.topAnchor).active = true
        viewController.view.bottomAnchor.constraintEqualToAnchor(viewController.view.superview!.bottomAnchor).active = true
        viewController.view.trailingAnchor.constraintEqualToAnchor(viewController.view.superview!.trailingAnchor).active = true
        
        let _ = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("refresh"), userInfo: nil, repeats: true)

    }
    
    func refresh() {
        viewController.refresh()
    }
    
    func window
    
    func applicationShouldHandleReopen(theApplication: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if (flag) {
            return false;
        }
        else {
            window.makeKeyAndOrderFront(self)
            return true;
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        viewController.saveDefaultsColumns()
    }
    
    @IBAction func addColumn(sender: NSToolbarItem) {
        
        let myOpen = NSOpenPanel()
        myOpen.canChooseFiles = false
        myOpen.canChooseDirectories = true
        myOpen.allowsMultipleSelection = false
        
        myOpen.beginSheetModalForWindow(window, completionHandler: { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                let fullPath = myOpen.URLs[0].absoluteString
                let index = fullPath.startIndex.advancedBy(7)
                let path = fullPath.substringFromIndex(index)
                let name = self.viewController.getFolderNameFromPath(path)
                let icon = self.viewController.ws.iconForFile(path)
                let item = SidebarItemDoc(fullName: name, icon: icon, path: path)
                
                item.opened = true
                self.viewController.columnItems.items.append(item)
                self.viewController.outlineView.reloadData()
                self.viewController.openListView(path)
                self.viewController.showListView()
            }
        })

    }
    
    @IBAction func navigateListView(sender: NSButton) {
        if let listIndex = viewController.getListViewIndexByIdentifier(sender.superview!.identifier!) {
            viewController.navigateListViewAtIndex(listIndex)
        }
    }
    
    @IBAction func favouriteListView(sender: NSButton) {
        if let listIndex = viewController.getListViewIndexByIdentifier(sender.superview!.identifier!) {
            viewController.favouriteListViewAtIndex(listIndex)
        }
    }
    
    @IBAction func reset(sender: NSToolbarItem) {
        viewController.resetDefaults()
//        viewController.putAway()
        viewController.outlineView.reloadData()
        viewController.outlineView?.expandItem(nil, expandChildren: true)

        // use function to remove columnItems with pinType to respective source lists
        // mark them as closed
        // remove all listViews
    }
    
}