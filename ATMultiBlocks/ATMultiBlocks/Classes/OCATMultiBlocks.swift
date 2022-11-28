import Foundation

@objcMembers
public class OCATMultiBlocks: NSObject {
    
    private lazy var blocks = ATMultiBlocks.init()
    
    public func register(key: String, owner: AnyObject, handler: @escaping ATMultiBlocks.ATMultiBlocksHandler) {
        blocks.register(key, owner: owner, handler: handler)
    }
    public func call(key: String, data: Any? = nil) {
        blocks.call(key, data: data)
    }
    public func remove(key: String, owner: AnyObject? = nil) {
        blocks.remove(key, owner: owner)
    }
    public func remove(owner: AnyObject) {
        blocks.remove(owner: owner)
    }
    
    public func removeAll() {
        blocks.removeAll()
    }
    
}
