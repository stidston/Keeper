import Cocoa

enum defaultsKeys {
    static let favouritesPaths = "one"
    static let columnsRootPaths = "two"
    static let columnsListPaths = "three"
}

class ItemData: NSObject {
    var fullName: String;
    var path: String;
    
    override init() {
        self.fullName = String()
        self.path = String()
    }
    
    init(fullName: String, path: String) {
        self.fullName = fullName
        self.path = path
    }
}

class ItemDoc: NSObject {
    var data: ItemData
    var oneDate: NSDate?
    var icon: NSImage?
    
    override init() {
        self.data = ItemData()
    }
    
    init(fullName: String, icon: NSImage?, path: String) {
        self.data = ItemData(fullName: fullName, path: path)
        self.icon = icon
    }
    
    func setDate(date: NSDate?) {
        self.oneDate = date
    }
}

class SidebarItemDoc: ItemDoc {
    var pinType: String?
    var opened: Bool = false
    var index: Int = 0
}

class SourceType: NSObject {
    let name:String
    var items: [SidebarItemDoc] = []
    
    init (name:String){
        self.name = name
    }
}