//
//  Log.swift
//  FileManagerProgram
//
//  Created by Fred Stidston on 02/04/2016.
//  Copyright © 2016 Fred Stidston. All rights reserved.
//

import Foundation

func getPathWithTrailingSlash(path: String) -> String {
    if (path.substringFromIndex(path.endIndex.advancedBy(-1)) != "/") {
        return path + "/"
    } else {
        return path
    }
}

func getFolderNameFromPath(var path: String) -> String {
    // Remove trailing slash if it's there
    if (path.substringFromIndex(path.endIndex.advancedBy(-1)) == "/") {
        path = path.substringToIndex(path.endIndex.advancedBy(-1))
    }
    // Remove path up to the preceding slash
    var i = 0
    while path.substringFromIndex(path.startIndex.advancedBy(i)).containsString("/") {
        i++
    }
    return path.substringFromIndex(path.startIndex.advancedBy(i))
}

var logFileInteractions = [String: LogFileItem]()

func updateLog(var ID: String, type: CountType) {
    ID = getPathWithTrailingSlash(ID)
    if logFileInteractions[ID] == nil {
        logFileInteractions[ID] = LogFileItem()
        Swift.print("Evaluate logFileInteractions[\(ID)] \(logFileInteractions[ID])")
        Swift.print("Create new LogFileItem for \(ID)")
    }
    switch type {
        case CountType.Open: Swift.print("\(ID) open \(++logFileInteractions[ID]!.open)")
        case CountType.Close: Swift.print("\(ID) open \(++logFileInteractions[ID]!.close)")
        case CountType.Trash: Swift.print("\(ID) open \(++logFileInteractions[ID]!.trash)")
        case CountType.Rename: Swift.print("\(ID) open \(++logFileInteractions[ID]!.rename)")
        case CountType.Popover: Swift.print("\(ID) popover \(++logFileInteractions[ID]!.popover)")
        case CountType.Add: Swift.print("\(ID) add \(++logFileInteractions[ID]!.add)")
        case CountType.Remove: Swift.print("\(ID) remove \(++logFileInteractions[ID]!.remove)")
        case CountType.Drag: Swift.print("\(ID) drag \(++logFileInteractions[ID]!.drag)")
    }
}

enum CountType {
    case Open   
    case Close  
    case Trash  
    case Rename 
    case Popover
    case Add    
    case Remove 
    case Drag   
}

struct LogFileItem {
    var open: Int = 0
    var close: Int = 0
    var trash: Int = 0
    var rename: Int = 0
    var popover: Int = 0
    var add: Int = 0
    var remove: Int = 0
    var drag: Int = 0
}