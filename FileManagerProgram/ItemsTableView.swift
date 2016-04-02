//
//  ItemsTableView.swift
//  FileManagerProgram
//
//  Created by Fred Stidston on 16/03/2016.
//  Copyright © 2016 Fred Stidston. All rights reserved.
//

import Cocoa

class ItemsTableView: NSTableView {
    var mainScrollView: NSScrollView?
//    var listViewController: ListViewController?
    
    override func scrollWheel(theEvent: NSEvent) {
        if theEvent.scrollingDeltaY == 0 {
            // It's a horizontal scroll -> redirect it
            if let _ = enclosingScrollView, mainScrollView = mainScrollView {
                mainScrollView.scrollWheel(theEvent)
            }
        } else {
            // It's a vertical scroll -> behave normally
            super.scrollWheel(theEvent)
        }
    }
    
//    func doubleClick() {
//        Swift.print("doubleClick")
//        let selectedDoc = listViewController!.selectedItemDoc()
//        
//        if selectedDoc != nil {
//            listViewController!.openItem(selectedDoc)
//        }
//    }
}
