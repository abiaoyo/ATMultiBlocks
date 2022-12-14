import Foundation
// from: https://github.com/ReactorKit/WeakMapTable

// MARK: - ATMBWeakMapTable

final internal class ATMBWeakMapTable<Key, Value> where Key: AnyObject {
    private var dictionary: [ATMBWeak<Key>: Value] = [:]
    private let lock = NSRecursiveLock()
    
    // MARK: Initializing
    
    internal init() {}
    
    // MARK: Getting and Setting Values
    
    internal func value(forKey key: Key) -> Value? {
        let weakKey = ATMBWeak(key)
        
        self.lock.lock()
        defer {
            self.lock.unlock()
            self.installDeallocHook(to: key)
        }
        
        return self.unsafeValue(forKey: weakKey)
    }
    
    internal func value(forKey key: Key, default: @autoclosure () -> Value) -> Value {
        let weakKey = ATMBWeak(key)
        
        self.lock.lock()
        defer {
            self.lock.unlock()
            self.installDeallocHook(to: key)
        }
        
        if let value = self.unsafeValue(forKey: weakKey) {
            return value
        }
        
        let defaultValue = `default`()
        self.unsafeSetValue(defaultValue, forKey: weakKey)
        return defaultValue
    }
    
    internal func forceCastedValue<T>(forKey key: Key, default: @autoclosure () -> T) -> T {
        return self.value(forKey: key, default: `default`() as! Value) as! T
    }
    
    internal func setValue(_ value: Value?, forKey key: Key) {
        let weakKey = ATMBWeak(key)
        
        self.lock.lock()
        defer {
            self.lock.unlock()
            if value != nil {
                self.installDeallocHook(to: key)
            }
        }
        
        if let value = value {
            self.dictionary[weakKey] = value
        } else {
            self.dictionary.removeValue(forKey: weakKey)
        }
    }
    
    internal func remove(forKey key: Key) {
        self.setValue(nil, forKey: key)
    }
    
    internal func removeAll() {
        self.lock.lock()
        defer {
            self.lock.unlock()
        }
        self.dictionary.removeAll()
    }
    
    // MARK: Getting and Setting Values without Locking
    
    private func unsafeValue(forKey key: ATMBWeak<Key>) -> Value? {
        return self.dictionary[key]
    }
    
    private func unsafeSetValue(_ value: Value?, forKey key: ATMBWeak<Key>) {
        if let value = value {
            self.dictionary[key] = value
        } else {
            self.dictionary.removeValue(forKey: key)
        }
    }
    
    // MARK: Dealloc Hook
    
    private var deallocHookKey: Void?
    
    private func installDeallocHook(to key: Key) {
        let isInstalled = (objc_getAssociatedObject(key, &deallocHookKey) != nil)
        guard !isInstalled else { return }
        
        let weakKey = ATMBWeak(key)
        let hook = ATMBWMTDeallocHook(handler: { [weak self] in
            self?.lock.lock()
            self?.dictionary.removeValue(forKey: weakKey)
            self?.lock.unlock()
        })
        objc_setAssociatedObject(key, &deallocHookKey, hook, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// MARK: - MBWeak

private final class ATMBWeak<T>: Hashable where T: AnyObject {
    private let objectHashValue: Int
    weak var object: T?
    
    init(_ object: T) {
        self.objectHashValue = ObjectIdentifier(object).hashValue
        self.object = object
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.objectHashValue)
    }
    
    static func == (lhs: ATMBWeak<T>, rhs: ATMBWeak<T>) -> Bool {
        return lhs.objectHashValue == rhs.objectHashValue
    }
}

// MARK: - ATMBWMTDeallocHook

private final class ATMBWMTDeallocHook {
    private let handler: () -> Void
    
    init(handler: @escaping () -> Void) {
        self.handler = handler
    }
    
    deinit {
        self.handler()
    }
}
