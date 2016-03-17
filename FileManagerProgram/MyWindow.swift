//
//  MyWindow.swift
//  FileManagerProgram
//
//  Created by Fred Stidston on 17/03/2016.
//  Copyright © 2016 Fred Stidston. All rights reserved.
//

import Cocoa

class MyWindow: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func windowDidResize() {
        print("resize")
    }
    
}
