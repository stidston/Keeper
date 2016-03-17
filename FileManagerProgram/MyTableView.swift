//
//  MyTableView.swift
//  FileManagerProgram
//
//  Created by Fred Stidston on 16/03/2016.
//  Copyright © 2016 Fred Stidston. All rights reserved.
//

import Cocoa

class MyTableView: NSTableView {

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    var mainScrollView: NSScrollView? {
        let app = NSApplication.sharedApplication()
        let delegate = app.delegate as! AppDelegate
        return delegate.viewController.scrollView
    }
    
    override func mouseDown(theEvent: NSEvent) {
        // do nothing
    }

    override func scrollWheel(theEvent: NSEvent) {
        if theEvent.scrollingDeltaY == 0 {
            // It's a horizontal scroll -> redirect it
            if let tableScrollView = enclosingScrollView, mainScrollView = mainScrollView {
                mainScrollView.scrollWheel(theEvent)
            }
        } else {
            // It's a vertical scroll -> behave normally
            super.scrollWheel(theEvent)
        }
    }
    
}
