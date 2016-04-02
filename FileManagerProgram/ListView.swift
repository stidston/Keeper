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
    let userName = NSUserName()
    var rootPath: String = "/Users/"
    var listPath: String = ""
    var listIsRoot: Bool = true
    var favouritesPaths: Array<String> = []
    var viewCreatedDate: NSTimeInterval = NSDate().timeIntervalSince1970
    var trackingArea: NSTrackingArea = NSTrackingArea()
    var popover: NSPopover = NSPopover()
    var sortType: String = "Date modified"
    var refreshStopped:Bool = false
    
    let fs: NSFileManager = NSFileManager.defaultManager()
    let ws: NSWorkspace = NSWorkspace.sharedWorkspace()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootPath = "/Users/" + userName

        itemsTitleView.stringValue = getFolderNameFromPath(listPath)

        listItems(listPath)
        
        // Drag and drop
        let registeredTypes:[String] = [NSStringPboardType, NSFilenamesPboardType]
        itemsScrollView.registerForDraggedTypes(registeredTypes)
        itemsScrollView.listViewController = self
        
        view.identifier = String(viewCreatedDate)
        popover.contentViewController = PopoverViewController(nibName: "PopoverViewController", bundle: nil)
        popover.contentViewController!.view.identifier = String(viewCreatedDate)

        setTrackingArea()
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
    }
    
    func setTrackingArea() {
        view.removeTrackingArea(trackingArea)
        trackingArea = NSTrackingArea(rect: CGRect(x: 0,y: view.bounds.height-30,width: 230,height: 30), options: [NSTrackingAreaOptions.MouseEnteredAndExited, NSTrackingAreaOptions.ActiveAlways], owner: self, userInfo: nil)
        view.addTrackingArea(trackingArea)
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
        if !refreshStopped {
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
            
            sortList()
            
            updateNavigationButton()
            updateFavouritesButton()
        } else {
            Swift.print("refreshStopped")
        }
    }
    
    func sortList() {
        var sortAttribute: String = ""
        
        switch sortType {
            case "Date created": sortAttribute = "NSFileCreationDate"
            case "Date modified": sortAttribute = "NSFileModificationDate"
            default: break
        }
        
        if sortAttribute == "NSFileCreationDate" || sortAttribute == "NSFileModificationDate" {
            numItems = items.count
            for var i = 0; i < numItems; i++ {
                let itemPath = listPath + items[i].data.fullName
                do {
                    let date = try fs.attributesOfItemAtPath(itemPath) [sortAttribute]
                    items[i].setDate(date as? NSDate)
                } catch { print("handled") }
            }
            items = items.sort({ $0.oneDate!.compare($1.oneDate!) == .OrderedDescending })
        } else if sortType == "Alphabetical" {
            items = items.sort({ $0.data.fullName < $1.data.fullName })
        }
        
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
        updateLog(doc!.data.path, type: CountType.Open)
    
        var fileType: String = ""
        do { try fileType = ws.typeOfFile(listPath + doc!.data.fullName)
        } catch { print("workspace error") }
        
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
        updateLog(listPath, type: CountType.Close)
        
        listItems(listPath)
        itemsTitleView.stringValue = getFolderNameFromPath(listPath)
        itemsTableView.reloadData()
        updateNavigationButton()
    }
    
    @IBAction func moveItemToTrash(sender: NSMenuItem) {
        let targetIndex = itemsTableView.clickedRow
        let fullName = items[targetIndex].data.fullName
        let path = items[targetIndex].data.path
        let trashPath = rootPath + "/.Trash/" + fullName
        
        print("moveItemToTrash \(path) to \(trashPath)")
        
        do {
            updateLog(path, type: CountType.Trash)
            try fs.moveItemAtPath(path, toPath: trashPath)
        } catch {
            Swift.print("moveItemToTrash error")
        }
        listItems(listPath)
    }
    
    @IBAction func rename(sender: NSMenuItem) {
        let targetIndex = itemsTableView.clickedRow
        updateLog(items[targetIndex].data.path, type: CountType.Rename)
        
        let rowView = itemsTableView.rowViewAtRow(targetIndex, makeIfNecessary: false)
        let itemTitleView = rowView?.subviews[0].subviews[1] as! ItemTextField
        let itemEditField = rowView?.subviews[0].subviews[2] as! ItemTextField
        
        itemTitleView.hidden = true
        itemEditField.hidden = false
        itemEditField.stringValue = items[targetIndex].data.fullName
        itemEditField.selectText(self)
        
        itemEditField.parentListViewController = self
        itemEditField.targetIndex = targetIndex
    }
    
    func endRename(targetIndex: Int) {
        let rowView = itemsTableView.rowViewAtRow(targetIndex, makeIfNecessary: false)
        let itemTitleView = rowView?.subviews[0].subviews[1] as! ItemTextField
        let itemEditField = rowView?.subviews[0].subviews[2] as! ItemTextField
        
        do {
            try fs.moveItemAtPath(listPath+items[targetIndex].data.fullName, toPath: listPath+itemEditField.stringValue)
        } catch {
           Swift.print("endRename error")
        }
        
        itemTitleView.hidden = false
        itemEditField.hidden = true
        items[targetIndex].data.fullName = itemEditField.stringValue
        itemTitleView.stringValue = itemEditField.stringValue

        listItems(listPath)
    }
    
    @IBAction func showInFinder(sender:NSMenuItem) {
        let targetIndex = itemsTableView.clickedRow
        let pathToOpen = listPath+items[targetIndex].data.fullName
        
        ws.selectFile(pathToOpen, inFileViewerRootedAtPath: listPath)
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
        updateLog(path, type: CountType.Drag)
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