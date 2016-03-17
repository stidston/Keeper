import Cocoa
import AppKit

class ListViewController: NSViewController, NSDraggingDestination {
    
    @IBOutlet weak var itemsTitleView: NSTextField!
    @IBOutlet weak var itemsTableView: NSTableView! //MyTableView!
    @IBOutlet weak var navigationButton: NSButton!
    @IBOutlet weak var favouriteButton: NSButton!
    
    var items = [ItemDoc]()
    var numItems: Int = 0
    var rootPath: String = "/Users/fred/"
    var listPath: String = ""
    var listIsRoot: Bool = true
    var favouritesPaths: Array<String> = []
    var viewCreatedDate: NSTimeInterval = NSDate().timeIntervalSince1970
    let rowType = "RowType"
    
    // Drag and drop knowstack.com
    var itemsDataArray:[String] = []

    let fs: NSFileManager = NSFileManager.defaultManager()
    let ws: NSWorkspace = NSWorkspace.sharedWorkspace()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemsTitleView.stringValue = getFolderNameFromPath(listPath)
        listItems(listPath)
        
        print("view.bounds.size.height \(view.bounds.size.height)")
        print("view.bounds.origin.y \(view.bounds.origin.y)")


        
        // Drag and drop knowstack.com
        view.registerForDraggedTypes([rowType, NSFilenamesPboardType])
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        super.mouseEntered(theEvent)
        favouriteButton.hidden = false
    }
    
    override func mouseExited(theEvent: NSEvent) {
        super.mouseExited(theEvent)
        favouriteButton.hidden = true
    }
    
    func recieveMovedItem(item: ItemDoc, fromViewController: ListViewController) {
        
    }
    
    override func loadView() {
        super.loadView()
        view.identifier = String(viewCreatedDate)
    }
    
    func getPathWithTrailingSlash(path: String) -> String {

        if (path.substringFromIndex(path.endIndex.advancedBy(-1)) != "/") {
            return path + "/"
        } else {
            return path
        }

    }
    
    func getFolderNameFromPath(var path: String) -> String {
//        print("getFolderNameFromPath"+path)
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
            print("error - possibly no contents")
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
            navigationButton.image = NSImage(named: "NSStatusUnavailable")
            listIsRoot = true
        } else {
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
    
    func updateFavouritesButton() {
        if favouritesPaths.contains(listPath) {
            favouriteButton.image = NSImage(named: "heart")
        } else {
            favouriteButton.image = NSImage(named: "heart_outline")
        }
    }
    
    func navigateToParent() {
        // navigateToParent
        let currentFolderNameLength = getFolderNameFromPath(listPath).characters.count
        listPath = listPath.substringToIndex(listPath.endIndex.advancedBy(-currentFolderNameLength-1))
        listItems(listPath)
        itemsTitleView.stringValue = getFolderNameFromPath(listPath)
        itemsTableView.reloadData()
        updateNavigationButton()
    }
}

// MARK: - NSTableViewDataSource
extension ListViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return items.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // 1
        let cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        
        // 2
        if tableColumn!.identifier == "ItemColumn" {
            // 3
            let itemDoc = items[row]
            cellView.imageView!.image = itemDoc.icon
            cellView.textField!.stringValue = itemDoc.data.fullName
            return cellView
        }
        
        return cellView
    }
    
    // Copy rows to pastboard
    func tableView(aTableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        
        let data = NSKeyedArchiver.archivedDataWithRootObject([rowIndexes])
        pboard.declareTypes([rowType], owner:self)
        pboard.setData(data, forType: rowType)
        
        return true
    }
    
    // Validate the drop
//    func tableView(aTableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation operation:NSTableViewDropOperation) -> NSDragOperation {
//        aTableView.setDropRow(row, dropOperation: NSTableViewDropOperation.Above)
//        return NSDragOperation.Move
//    }
    
    // Handling the drop
//    func tableView(tableView: NSTableView, acceptDrop info:NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
//
//        let pasteboard = info.draggingPasteboard()
//        let rowData = pasteboard.dataForType(rowType)
//        
//        if(rowData != nil) {
//            var dataArray = NSKeyedUnarchiver.unarchiveObjectWithData(rowData!) as! Array<NSIndexSet>,
//            indexSet = dataArray[0]
//            let movingFromIndex = indexSet.firstIndex
//            let item = items[movingFromIndex]
//            recieveMovedItem(item, )
//            return true
//        } else {
//            return false
//        }
//    }
}

// MARK: - NSTableViewDelegate
extension ListViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(notification: NSNotification) {
        let selectedDoc = selectedItemDoc()

        if selectedDoc != nil {
            openItem(selectedDoc)
        }
        
    }
}