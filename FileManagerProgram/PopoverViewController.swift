//
//  PopoverViewController.swift
//  FileManagerProgram
//
//  Created by Fred Stidston on 28/03/2016.
//  Copyright © 2016 Fred Stidston. All rights reserved.
//

import Cocoa

class PopoverViewController: NSViewController {

    @IBOutlet weak var sortMenu: NSPopUpButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func presetMenuItem(sortType: String) {
        sortMenu.selectItemWithTitle(sortType)
    }
    
    
}
