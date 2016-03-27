//
//  ViewController.swift
//  SidebarProgram
//
//  Created by Fred Stidston on 01/03/2016.
//  Copyright © 2016 Fred Stidston. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var documentView: NSView!

    let ws: NSWorkspace = NSWorkspace.sharedWorkspace()

    
    var favouriteItems = SourceType (name:"Favourites")
    var deviceItems = SourceType (name:"Devices")
    var columnItems = SourceType (name:"Columns")
    var recentItems = SourceType (name:"Recent")
    
    var listViews = [ListViewController]()
    var numListViews: Int = 0
    var listViewWidth: Int = 230
    var gutterWidth: Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = NSUserDefaults.standardUserDefaults()
        
        loadSidebar()
        
        // open DefaultsColumnsRoot
        if let columnsRootPaths = defaults.stringForKey(defaultsKeys.columnsRootPaths) {
            let columnsListPaths = defaults.stringForKey(defaultsKeys.columnsListPaths)

            var columnsRootPathsArray = columnsRootPaths.componentsSeparatedByString(":::")
            var columnsListPathsArray = columnsListPaths!.componentsSeparatedByString(":::")

            var iMax = columnsRootPathsArray.count
            for var i = 0; i < iMax; i++ {
                if (columnsRootPathsArray[i] == "") {
                    columnsRootPathsArray.removeAtIndex(i)
                    columnsListPathsArray.removeAtIndex(i)
                    i--
                    iMax--
                } else {
                    openListView(columnsRootPathsArray[i].stringByRemovingPercentEncoding!)
                    listViews[numListViews-1].listItems(columnsListPathsArray[i].stringByRemovingPercentEncoding!)
                }
            }
        }
        
        outlineView?.expandItem(nil, expandChildren: true)
        
    
    func loadSidebar() {
        let defaults = NSUserDefaults.standardUserDefaults()
        var contents: Array<String> = []
        var numItems: Int = 0
        let fs: NSFileManager = NSFileManager.defaultManager()
        
        //load Devices
        do {
            try contents = fs.contentsOfDirectoryAtPath(volumesPath)
            numItems = contents.count
            deviceItems.items.removeAll()
            
            for var i = 0; i < numItems; i++ {
                let deviceItem = createSidebarItemDocFromPath(volumesPath + contents[i])
                deviceItem.pinType = "device"
                deviceItems.items.append(deviceItem)
            }
            
        } catch {
            print("error - possibly no contents")
        }
        
        for var i = numItems-1; i >= 0; i-- {
            let mobileBackups = "MobileBackups"
            if deviceItems.items[i].data.fullName == mobileBackups {
                deviceItems.items.removeAtIndex(i)
            }
        }
        
        
        // load DefaultsFavourites
        if let favouritesPaths = defaults.stringForKey(defaultsKeys.favouritesPaths) {
            var favouritesPathsArray = favouritesPaths.componentsSeparatedByString(":::")
            var iMax = favouritesPathsArray.count
            favouriteItems.items.removeAll()

            for var i = 0; i < iMax; i++ {
                if (favouritesPathsArray[i] == "") {
                    favouritesPathsArray.removeAtIndex(i)
                    i--
                    iMax--
                } else {
                    let favouriteItem = createSidebarItemDocFromPath(favouritesPathsArray[i])
                    favouriteItem.pinType = "favourite"
                    favouriteItems.items.append(favouriteItem)
                }
            }
        }
    }
    
    func saveDefaultsFavourites() {
        var favouritesPaths = ""
        let iMax = favouriteItems.items.count
        for var i = 0; i < iMax; i++ {
            favouritesPaths += "\(favouriteItems.items[i].data.path):::"
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(favouritesPaths, forKey: defaultsKeys.favouritesPaths)
    }
    
    func saveDefaultsColumns() {
        var columnsRootPaths = ""
        for var i = 0; i < numListViews; i++ {
            columnsRootPaths += "\(listViews[i].rootPath):::"
        }
        
        var columnsListPaths = ""
        for var i = 0; i < numListViews; i++ {
            columnsListPaths += "\(listViews[i].listPath):::"
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(columnsRootPaths, forKey: defaultsKeys.columnsRootPaths)
        defaults.setObject(columnsListPaths, forKey: defaultsKeys.columnsListPaths)
    }
    
    func resetDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("", forKey: defaultsKeys.columnsRootPaths)
        defaults.setObject("", forKey: defaultsKeys.columnsListPaths)
        defaults.setObject("", forKey: defaultsKeys.favouritesPaths)
    }
    
    func createSidebarItemDocFromPath(path: String) -> SidebarItemDoc {
        let name = getFolderNameFromPath(path)
        let path = getPathWithTrailingSlash(path)
        var image: NSImage
        switch name {
            case "Downloads": image = NSImage(named: "downloads")!
            case "Documents": image = NSImage(named: "documents")!
            case "Desktop": image = NSImage(named:"desktop")!
            case "Internal HD": image = NSImage(named:"internal_disk")!
            case userName: image = NSImage(named:"home")!
            default: image = NSImage(named: "folder")!
        }
        return SidebarItemDoc(fullName: name, icon: image, path: path)
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
    
    func showListView() {
        let _ = NSTimer.scheduledTimerWithTimeInterval(0.1, target:self, selector: Selector("scrollToRight"), userInfo: nil, repeats: false)
    }
    
    func refresh() {
        for var i = 0; i < numListViews; i++ {
            listViews[i].listItems(listViews[i].listPath)
            listViews[i].setTrackingArea()
        }
        loadSidebar()
        outlineView.reloadData()
    }
    
    func openListView() {
        openListView(defaultPath)
    }
    
    func openListView(listPath: String) {
        addListViewRight(listPath)
        
        listViews.last!.updateFavouritesButton()
        
        // Horizontal Scrolling: Assign scrollView delegate
        listViews.last!.itemsTableView.mainScrollView = scrollView
        
    }
    
    func getPathWithTrailingSlash(path: String) -> String {
        if (path.substringFromIndex(path.endIndex.advancedBy(-1)) != "/") {
            return path + "/"
        } else {
            return path
        }
    }
        
    func getListViewIndexByIdentifier(createdDate: String) -> Int? {
        for var i = 0 ; i < numListViews; i++ {
            if listViews[i].view.identifier == createdDate {
                return i
            }
        }
        return nil
    }
    
    func addListViewRight(listPath: String) {
        let listView = ListViewController(nibName: "ListView", bundle: nil)
        listView!.listPath = listPath
        listView!.rootPath = listPath
        
        listView!.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentView.addSubview(listView!.view)
        listViews.append(listView!)
        listView!.view.drawFocusRingMask()
        numListViews++
        
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[listView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["listView" : listView!.view])
        
        var horizontalConstraints = [NSLayoutConstraint]()
        if numListViews > 1 {
            let visualFormat: String = "H:|-\(gutterWidth+((numListViews-1)*(listViewWidth+gutterWidth)))-[listView]"
            horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(visualFormat,
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["listView" : listView!.view])
        } else {
            horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(gutterWidth)-[listView]",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["listView" : listView!.view])
        }
        
        NSLayoutConstraint.activateConstraints(verticalConstraints+horizontalConstraints)
        
        // Update documentView width
        let documentViewWidth: CGFloat = CGFloat(numListViews)*CGFloat(listViewWidth+gutterWidth)
        let documentViewConstraints = documentView.constraints
        documentViewConstraints[documentViewConstraints.count-1].active = false;
        let widthConstraint = NSLayoutConstraint(item: documentView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: documentViewWidth)
        NSLayoutConstraint.activateConstraints([widthConstraint])
        
        saveDefaultsColumns()
    }
    
    func navigateListViewAtIndex(index: Int) {
        if !listViews[index].listIsRoot {
            listViews[index].navigateToParent()
        } else {
            removeListViewAtIndex(index)
        }
    }
    
    func removeListViewAtIndex(index: Int) {
        //update listViews array
        if numListViews > 0 {
            listViews[index].view.removeFromSuperview()
            listViews.removeAtIndex(index)
            numListViews--
        }
        
        //update constraints
        let countStart = index
        for var i = countStart; i < numListViews; i++ {
            var horizontalConstraints = [NSLayoutConstraint]()
            
            NSLayoutConstraint.deactivateConstraints(horizontalConstraints)
            
            if numListViews > 1 {
                let visualFormat: String = "H:|-\(gutterWidth+((i)*(listViewWidth+gutterWidth)))-[listView]"
                horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(visualFormat,
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["listView" : listViews[i].view])
            } else {
                horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(gutterWidth)-[listView]",
                    options: NSLayoutFormatOptions(rawValue: 0),
                    metrics: nil,
                    views: ["listView" : listViews[i].view])
            }
            NSLayoutConstraint.activateConstraints(horizontalConstraints)
        }
        
        //update documentView width
        let documentViewWidth: CGFloat = CGFloat(numListViews)*CGFloat(listViewWidth+gutterWidth)
        let documentViewConstraints = documentView.constraints
        documentViewConstraints[documentViewConstraints.count-1].active = false;
        let widthConstraint = NSLayoutConstraint(item: documentView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: documentViewWidth)
        NSLayoutConstraint.activateConstraints([widthConstraint])
        
        saveDefaultsColumns()
    }
    
    func closeAll() {
        let iMax = numListViews
        for var i = 0; i < iMax; i++ {
            removeListViewAtIndex(0)
        }
    }
    
    func resetToFavourites() {
        closeAll()
        
        let iMax = favouriteItems.items.count
        for var i = 0; i < iMax; i++ {
            openListView(favouriteItems.items[i].data.path)
        }
    }
    
    func favouriteListViewAtIndex(index: Int) {
        let listPath = getPathWithTrailingSlash(listViews[index].listPath)
        
        // remove the matching favourite if one is found
        var i = 0
        let iMax = favouriteItems.items.count
        while i < iMax {
            if favouriteItems.items[i].data.path == listPath {
                favouriteItems.items.removeAtIndex(i)
                break
            }
            i++
        }
        
        // add the new favourite if none is found
        if iMax == favouriteItems.items.count {
            let favouriteItem = createSidebarItemDocFromPath(listPath)
            favouriteItem.pinType = "favourite"
            favouriteItems.items.append(favouriteItem)
        }
        
        let jMax = favouriteItems.items.count
        for var i = 0; i < numListViews; i++ {
            listViews[i].favouritesPaths.removeAll()
            for var j = 0; j < jMax; j++ {
                listViews[i].favouritesPaths.append(getPathWithTrailingSlash(favouriteItems.items[j].data.path))
            }
            listViews[i].updateFavouritesButton()
        }
        
        saveDefaultsFavourites()
        
        outlineView.reloadData()
        outlineView?.expandItem(nil, expandChildren: true)

    }
    
    func scrollToRight() {
        var newScrollOrigin: NSPoint
        newScrollOrigin = NSMakePoint(documentView.frame.size.width,0.0)
        documentView.scrollPoint(newScrollOrigin)
    }
}

extension ViewController {
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let item: AnyObject = item {
            switch item {
            case let sourceType as SourceType:
                return sourceType.items[index]
            default:
                return self
            }
        } else {
            switch index {
            case 0:
                return favouriteItems
            case 1:
                return deviceItems
            default:
                return recentItems
            }
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        switch item {
        case let sourceType as SourceType:
            return (sourceType.items.count > 0) ? true : false
        default:
            return false
        }
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let item: AnyObject = item {
            switch item {
            case let sourceType as SourceType:
                return sourceType.items.count
            default:
                return 0
            }
        } else {
            return 3 //Favourites and Devices
        }
    }
    
    
    // NSOutlineViewDelegate
    func outlineView(outlineView: NSOutlineView, viewForTableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        switch item {
        case let sourceType as SourceType:
            let view = outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as! NSTableCellView
            if let textField = view.textField {
                textField.stringValue = sourceType.name
            }
            return view
        case let itemDoc as SidebarItemDoc:
            let view = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
            if let textField = view.textField {
                textField.stringValue = itemDoc.data.fullName
            }
            if let image = itemDoc.icon {
                view.imageView!.image = image
            }
            return view
        default:
            return nil
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        switch item {
        case _ as SourceType:
            return true
        default:
            return false
        }
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification){
        print(notification)
        let selectedIndex = notification.object?.selectedRow
        let object:AnyObject? = notification.object?.itemAtRow(selectedIndex!)
        print(object)
        outlineView.deselectRow(selectedIndex!)
        
        if (object is SidebarItemDoc){
            openListView(object!.data.path)
            showListView()

//            let sid = object as! SidebarItemDoc
//            if !sid.opened {
//                openListView(object!.data.path)
//                if sid.pinType != nil {
//                    columnItems.items.append(sid)
//                    let index = selectedIndex! - columnItems.items.count - 1
//                    favouriteItems.items.removeAtIndex(index)
//                }
//                outlineView.reloadData()
//                sid.opened = true
//            }
        }
    }
    
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item:AnyObject) -> Bool {
        switch item {
        case _ as SourceType:
            return false
        default:
            return true
        }
    }

}
