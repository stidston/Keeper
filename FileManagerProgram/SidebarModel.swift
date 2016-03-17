import Cocoa

class SourceType: NSObject {
    let name:String
    var items: [ItemDoc] = []
    
    init (name:String){
        self.name = name
    }
}