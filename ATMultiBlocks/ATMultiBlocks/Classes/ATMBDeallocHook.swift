import Foundation

internal typealias ATMBDeallocHandler = (_ handleKeys: Set<String>) -> Void

private class _ATMBDeallocHook {
    private var handlerKeys = Set<String>.init()
    
    var handler: ATMBDeallocHandler?
    var type: String?
    var propertyKey: String = ""
    
    func add(_ handlerKey: String) {
        handlerKeys.insert(handlerKey)
    }
    
    func remove(_ handlerKey: String) {
        handlerKeys.remove(handlerKey)
    }
    
    deinit {
        let log = "ATMBDeallocHook deinit: .type:\(type ?? "") \t .pKey:\(propertyKey) \t .hKey:\(handlerKeys)"
        ATMultiBlocks.log?(log)
        
        handler?(handlerKeys)
    }
}

internal final class ATMBDeallocHook {
    internal static let shared = ATMBDeallocHook()
    
    private init() {}
    
    internal func installDeallocHook(for object: AnyObject, propertyKey: String, handlerKey: String, handler: ATMBDeallocHandler?) {
        let keyPointer: UnsafeRawPointer! = UnsafeRawPointer(bitPattern: propertyKey.hashValue)
        
        guard let hook = objc_getAssociatedObject(object, keyPointer) as? _ATMBDeallocHook else {
            let _hook = _ATMBDeallocHook()
            _hook.propertyKey = propertyKey
            _hook.handler = handler
            _hook.type = "\(type(of: object))"
            _hook.add(handlerKey)
            objc_setAssociatedObject(object, keyPointer, _hook, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            let log = "ATMBDeallocHook install _new: .type:\(_hook.type ?? "") \t .pKey:\(_hook.propertyKey) \t .hKey:\(handlerKey)"
            ATMultiBlocks.log?(log)
            
            return
        }
        hook.add(handlerKey)
        
        let log = "ATMBDeallocHook install _add: .type:\(hook.type ?? "") \t .pKey:\(hook.propertyKey) \t .hKey:\(handlerKey)"
        ATMultiBlocks.log?(log)
    }
    
    internal func uninstallDeallocHook(for object: AnyObject, propertyKey: String, handlerKey: String) {
        let keyPointer: UnsafeRawPointer! = UnsafeRawPointer(bitPattern: propertyKey.hashValue)
        let hook = objc_getAssociatedObject(object, keyPointer) as? _ATMBDeallocHook
        hook?.remove(handlerKey)
        
        let log = "ATMBDeallocHook uninstall: .type:\(hook!.type ?? "") \t .pKey:\(hook!.propertyKey) \t .hKey:\(handlerKey)"
        ATMultiBlocks.log?(log)
    }
    
    internal func uninstallDeallocHook(for object: AnyObject, propertyKey: String) {
        let keyPointer: UnsafeRawPointer! = UnsafeRawPointer(bitPattern: propertyKey.hashValue)
        objc_setAssociatedObject(object, keyPointer, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        let log = "ATMBDeallocHook uninstall: .type:\(type(of: object)) \t .pKey:\(propertyKey)"
        ATMultiBlocks.log?(log)
    }
}
