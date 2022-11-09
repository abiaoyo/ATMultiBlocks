//
//  StateCenter.swift
//  ATMultiBlocksDemo
//
//  Created by abiaoyo on 2022/11/9.
//

import Foundation
import ATMultiBlocks

class StateCenter: NSObject {

    public enum State {
        case idl
        case suc
        case fal
    }
    
    typealias StateBlock = (_ state:State) -> Void
    
    
    static let shared = StateCenter.init()
    
    var multiBlocks = ATMultiBlocks.init()
    
    var state:State = .idl {
        didSet {
            multiBlocks.call("stateBlock", data: state)
        }
    }
    
    func addStateBlock(for owner:AnyObject,block:@escaping StateBlock) {
        multiBlocks.register("stateBlock", owner: owner) { data in
            if let state:State = data as? State {
                block(state)
            }
        }
    }
    
    func removeStateBlock(for owner:AnyObject) {
        multiBlocks.remove("stateBlock", owner: owner)
    }
    
}
