//
//  ItemsScrollView.swift
//  FileManagerProgram
//
//  Created by Fred Stidston on 24/03/2016.
//  Copyright © 2016 Fred Stidston. All rights reserved.
//

import Cocoa

class ItemsScrollView: NSScrollView {
    var listViewController: ScrollViewDelegate?

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        let sourceDragMask = sender.draggingSourceOperationMask()
        let pboard = sender.draggingPasteboard()
        
        if pboard.availableTypeFromArray([NSStringPboardType]) == NSStringPboardType ||
            pboard.availableTypeFromArray([NSFilenamesPboardType]) == NSFilenamesPboardType {
            if sourceDragMask.rawValue == NSDragOperation.Copy.rawValue {
                return NSDragOperation.Copy
            } else if sourceDragMask.rawValue != 0 {
                return NSDragOperation.Move
            }
        }
        return NSDragOperation.None
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        let sourceDragMask = sender.draggingSourceOperationMask()
        let pboard = sender.draggingPasteboard()
        let parentController = listViewController!

        var path: Array<String> = []
        if pboard.availableTypeFromArray([NSStringPboardType]) == NSStringPboardType {
            path.append(pboard.stringForType(NSStringPboardType)!)
        } else if pboard.availableTypeFromArray([NSFilenamesPboardType]) == NSFilenamesPboardType {
            path = path + (pboard.propertyListForType(NSFilenamesPboardType)! as! Array<String>)
        }
        
        let pathCount = path.count
        if pathCount > 0 {
            if sourceDragMask.rawValue == NSDragOperation.Copy.rawValue {
                for var i = 0; i < pathCount; i++ {
                    parentController.copyItemToTable(self, path: path[i])
                }
            } else {
                for var i = 0; i < pathCount; i++ {
                    parentController.moveItemToTable(self, path: path[i])
                }
            }
            return true
        }

        return false
    }
}
