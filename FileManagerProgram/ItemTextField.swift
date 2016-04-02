//
//  ItemTextField.swift
//  FileManagerProgram
//
//  Created by Fred Stidston on 30/03/2016.
//  Copyright © 2016 Fred Stidston. All rights reserved.
//

import Cocoa

class ItemTextField: NSTextField {
    var parentListViewController : ListViewController = ListViewController()
    var targetIndex: Int = -1

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func textDidEndEditing(notification: NSNotification) {
        parentListViewController.endRename(targetIndex)
    }
    
}
