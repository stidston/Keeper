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
        
        viewController = ViewController(nibName: "ViewController", bundle: nil)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        window.contentView!.addSubview(viewController.view)
        viewController.view.frame = (window.contentView! as NSView).bounds
        viewController.view.leadingAnchor.constraintEqualToAnchor(viewController.view.superview!.leadingAnchor).active = true
        viewController.view.topAnchor.constraintEqualToAnchor(viewController.view.superview!.topAnchor).active = true
        viewController.view.bottomAnchor.constraintEqualToAnchor(viewController.view.superview!.bottomAnchor).active = true
        viewController.view.trailingAnchor.constraintEqualToAnchor(viewController.view.superview!.trailingAnchor).active = true
    }
    
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
        for i in logFileInteractions {
            Swift.print(i)
        }
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
                let name = getFolderNameFromPath(path)
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
    
    @IBAction func closeListView(sender: NSButton) {
        if let listIndex = viewController.getListViewIndexByIdentifier(sender.superview!.identifier!) {
            viewController.removeListViewAtIndex(listIndex)
        }
    }
    
    @IBAction func sortListView(sender: NSButton) {
        if let listIndex = viewController.getListViewIndexByIdentifier(sender.superview!.identifier!) {
            viewController.sortListViewAtIndex(sender, index: listIndex)
        }
    }
    
    @IBAction func reset(sender: NSToolbarItem) {
        viewController.resetToFavourites()

    }
    
    @IBAction func closeAll(sender: NSToolbarItem) {
        viewController.closeAll()
    }
    
}