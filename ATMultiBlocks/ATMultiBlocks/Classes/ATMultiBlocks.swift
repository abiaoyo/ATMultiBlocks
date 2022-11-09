import Foundation

// MARK: - ATMultiBlocks

public final class ATMultiBlocks {
    
    public static var log: ((_ log: String) -> Void)?
    
    public typealias ATMultiBlocksHandler = (_ data: Any?) -> Void
    
    // <key,owners>
    private var ownerContainer = Dictionary<String, NSHashTable<AnyObject>>.init()
    // <owner,[<key,handler>]>
    private var handlerContainer = ATMBWeakMapTable<AnyObject, NSMapTable<NSString, AnyObject>>.init()
    
    public init(){
        
    }
    
    public func register(_ key: String, owner: AnyObject, handler: @escaping ATMultiBlocksHandler) {
        let oTable = ownerContainer[key] ?? NSHashTable<AnyObject>.weakObjects()
        oTable.add(owner)
        
        ownerContainer[key] = oTable
        
        let khMap = handlerContainer.value(forKey: owner) ?? NSMapTable<NSString, AnyObject>.strongToStrongObjects()
        khMap.setObject(handler as AnyObject, forKey: key as NSString)
        
        handlerContainer.setValue(khMap, forKey: owner)
        
        ATMBDeallocHook.shared.installDeallocHook(for: owner, propertyKey: "ATMultiBlocks", handlerKey: key) { [weak self] hkeys in
            for hkey in hkeys {
                if self?.ownerContainer[hkey]?.allObjects.count == 0 {
                    self?.ownerContainer.removeValue(forKey: hkey)
                }
            }
        }
    }
    
    public func call(_ key: String, data: Any? = nil) {
        guard let oTable = ownerContainer[key] else {
            return
        }
        oTable.allObjects.forEach { owner in
            (handlerContainer.value(forKey: owner)?.object(forKey: key as NSString) as? ATMultiBlocksHandler)?(data)
        }
    }
    
    public func remove(_ key: String, owner: AnyObject? = nil) {
        if let o = owner {
            ownerContainer[key]?.remove(o)
            handlerContainer.value(forKey: o)?.removeObject(forKey: key as NSString?)
        } else {
            guard let owners = ownerContainer[key] else {
                return
            }
            owners.allObjects.forEach { owner in
                handlerContainer.value(forKey: owner)?.removeObject(forKey: key as NSString?)
            }
            owners.removeAllObjects()
        }
    }
    
    public func remove(owner: AnyObject) {
        handlerContainer.remove(forKey: owner)
    }
    
    public func removeAll() {
        ownerContainer.removeAll()
        handlerContainer.removeAll()
    }
}
