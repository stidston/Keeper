//
//  ScrollViewDelegate.swift
//  FileManagerProgram
//
//  Created by Fred Stidston on 24/03/2016.
//  Copyright © 2016 Fred Stidston. All rights reserved.
//

import Cocoa

protocol ScrollViewDelegate {
    func moveItemToTable(aViewController: ItemsScrollView, path: String) -> Bool
    func copyItemToTable(aViewController: ItemsScrollView, path: String) -> Bool
}
