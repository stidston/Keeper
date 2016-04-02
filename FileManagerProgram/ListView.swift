import Cocoa
import AppKit

class ListViewController: NSViewController { //, NSDraggingDestination {
    
    @IBOutlet weak var itemsTitleView: NSTextField!
    @IBOutlet weak var itemsTableView: ItemsTableView!
    @IBOutlet weak var itemsScrollView: ItemsScrollView!
    @IBOutlet weak var navigationButton: NSButton!
    @IBOutlet weak var favouriteButton: NSButton!
    
    var items = [ItemDoc]()
    var numItems: Int = 0
    var rootPath: String = "/Users/fred/"
    var listPath: String = ""
    var listIsRoot: Bool = true
    var favouritesPaths: Array<String> = []
    var viewCreatedDate: NSTimeInterval = NSDate().timeIntervalSince1970
    var trackingArea: NSTrackingArea = NSTrackingArea()
    var popover: NSPopover = NSPopover()
    var sortType: String = "Date modified"
    
    let fs: NSFileManager = NSFileManager.defaultManager()
    let ws: NSWorkspace = NSWorkspace.sharedWorkspace()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemsTitleView.stringValue = getFolderNameFromPath(listPath)
        listItems(listPath)
        
        // Drag and drop
        let registeredTypes:[String] = [NSStringPboardType, NSFilenamesPboardType]
        itemsScrollView.registerForDraggedTypes(registeredTypes)
        itemsScrollView.listViewController = self
        
        popover.contentViewController = PopoverViewController(nibName: "PopoverViewController", bundle: nil)
        popover.contentViewController!.view.identifier = String(viewCreatedDate)
        setTrackingArea()
        
        itemsScrollView.focusRingType = NSFocusRingType.Default
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        super.mouseEntered(theEvent)
        favouriteButton.hidden = false
//        navigationButton.hidden = false
    }
    
    override func mouseExited(theEvent: NSEvent) {
        super.mouseExited(theEvent)
        if !popover.shown {
            favouriteButton.hidden = true
        }
//        navigationButton.hidden = true
    }

    override func loadView() {
        super.loadView()
        view.identifier = String(viewCreatedDate)
    }
    
    func setTrackingArea() {
        view.removeTrackingArea(trackingArea)
        trackingArea = NSTrackingArea(rect: CGRect(x: 0,y: view.bounds.height-30,width: 230,height: 30), options: [NSTrackingAreaOptions.MouseEnteredAndExited, NSTrackingAreaOptions.ActiveAlways], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
    }
    
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
        
    func listItems(path: String?) {
        if path != nil {
            listPath = getPathWithTrailingSlash(path!)
        }
        items.removeAll()
        
        itemsTitleView.stringValue = getFolderNameFromPath(listPath)
        
        var contents: Array<String>
        
        //Load contents
        do {
            contents = try fs.contentsOfDirectoryAtPath(listPath)
            numItems = contents.count

            for var i = 0; i < numItems; i++ {
                var itemPath = listPath
                itemPath += contents[i]
                items.append(ItemDoc(fullName: contents[i], icon: ws.iconForFile(itemPath), path: itemPath))
            }

        } catch {
            print("listItems error")
        }
        
        //Remove invisible items
        for var i = numItems-1; i >= 0; i-- {
            let fullName: String = items[i].data.fullName
            if fullName.substringToIndex(fullName.startIndex.advancedBy(1)) == "." {
                items.removeAtIndex(i)
            }
        }
        
        //Sort by date modified descending
        switch itemsTitleView.stringValue {
            case "Downloads":
                numItems = items.count
                for var i = 0; i < numItems; i++ {
                    let itemPath = listPath + items[i].data.fullName
                    do {
                        let creDate = try fs.attributesOfItemAtPath(itemPath) ["NSFileCreationDate"]
                        items[i].setDate(creDate as? NSDate)
                    } catch { print("handled") }
                }
                items = items.sort({ $0.creDate!.compare($1.creDate!) == .OrderedDescending })
            default:
                numItems = items.count
                for var i = 0; i < numItems; i++ {
                    let itemPath = listPath + items[i].data.fullName
                    do {
                        let modDate = try fs.attributesOfItemAtPath(itemPath) ["NSFileModificationDate"]
                        items[i].setDate(modDate as? NSDate)
                    } catch { print("handled") }
                }
                items = items.sort({ $0.modDate!.compare($1.modDate!) == .OrderedDescending })
        }

        
        updateNavigationButton()
        updateFavouritesButton()
        
        itemsTableView.reloadData()
    }
    
    func selectedItemDoc() -> ItemDoc? {
        let selectedRow = self.itemsTableView.selectedRow;
        if selectedRow >= 0 && selectedRow < self.items.count {
            return items[selectedRow]
        }
        return nil
    }
    
    func updateNavigationButton() {
        if getPathWithTrailingSlash(listPath) == getPathWithTrailingSlash(rootPath) {
            navigationButton.image = NSImage(named: "NSStopProgressTemplate")
            navigationButton.hidden = true
            listIsRoot = true
        } else {
            navigationButton.hidden = false
            navigationButton.image = NSImage(named: "NSGoLeftTemplate")
            listIsRoot = false
        }
    }

    func openItem(doc: ItemDoc?) {
        var fileType: String = ""
        do { try fileType = ws.typeOfFile(listPath + doc!.data.fullName)
        } catch { print("error") }
        
        if fileType != "public.folder" {
            ws.openFile(listPath + doc!.data.fullName)
        } else {
            listItems(listPath + doc!.data.fullName)
        }
    }
    
    func showPopover(sender: AnyObject?) {
        updateLog(listPath, type: CountType.Popover)
        popover.showRelativeToRect(favouriteButton.bounds, ofView: favouriteButton, preferredEdge: NSRectEdge.MaxY)
    }
    
    @IBAction func togglePopover(sender: NSButton) {
        if popover.shown {
            hidePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func hidePopover(sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    func updateFavouritesButton() {
        favouriteButton.action = Selector("togglePopover:")
    }
    
    func navigateToParent() {

        let currentFolderNameLength = getFolderNameFromPath(listPath).characters.count
        listPath = listPath.substringToIndex(listPath.endIndex.advancedBy(-currentFolderNameLength-1))
        listItems(listPath)
        
        var fileType: String = ""
        do {
            try fileType = ws.typeOfFile(listPath)
        } catch {
            print("navigateToParent error")
        }
        print("fileType \(fileType)")

        itemsTitleView.stringValue = getFolderNameFromPath(listPath)

        itemsTableView.reloadData()
        updateNavigationButton()
    }
    
}

extension ListViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
 
        let cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        
        if tableColumn!.identifier == "ItemColumn" {
            
            let itemDoc = items[row]
            cellView.imageView!.image = itemDoc.icon
            cellView.textField!.stringValue = itemDoc.data.fullName
            return cellView
        }
        
        return cellView
    }

    //     Copy rows to pasteboard
    func tableView(aTableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard
        pboard: NSPasteboard) -> Bool {
        let path = items[rowIndexes.firstIndex].data.path
        pboard.declareTypes([NSStringPboardType], owner: self)
        pboard.setString(path, forType: NSStringPboardType)
        return true
    }
}

extension ListViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(notification: NSNotification) {
        let selectedDoc = selectedItemDoc()

        if selectedDoc != nil {
            openItem(selectedDoc)
        }
        
    }
}

extension ListViewController: ScrollViewDelegate {
    func moveItemToTable(aViewController: ItemsScrollView, path: String) -> Bool {
        do {
            try fs.moveItemAtPath(path, toPath: listPath + getFolderNameFromPath(path))
        } catch {
            Swift.print("fs.moveItemAtPath error")
            return false
        }
        listItems(listPath)
        return true
    }
    func copyItemToTable(aViewController: ItemsScrollView, path: String) -> Bool {
        do {
            try fs.copyItemAtPath(path, toPath: listPath + getFolderNameFromPath(path))
        } catch {
            Swift.print("fs.copyItemToTable error")
            return false
        }
        listItems(listPath)
        return true
    }
}

extension ListViewController: TableViewDelegate {
//    func removeItemFromTable(aTableView: ItemsTableView, path: String) -> Bool {
//        Swift.print("removeItemFromTable \(path)")
//        return true
//    }
}