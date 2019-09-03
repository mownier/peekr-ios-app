//
//  BaseFlow.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/3/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

protocol BaseFlow {
    
    var window: UIWindow { get }
    
    @discardableResult
    func registerObservers() -> Bool
    
    @discardableResult
    func unregisterObservers() -> Bool
    
    func allObservers() -> [NSObjectProtocol?]
}

extension BaseFlow {
    
    func isObserverRegistrationOkay() -> Bool {
        return allObservers()
            .map({ $0 != nil })
            .reduce(true, { result, item -> Bool in
                return result && item
            })
    }
}

class BaseFlowDefault : BaseFlow {
    
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    @discardableResult
    func registerObservers() -> Bool {
        return isObserverRegistrationOkay()
    }
    
    @discardableResult
    func unregisterObservers() -> Bool {
        return true
    }
    
    func allObservers() -> [NSObjectProtocol?] {
        return []
    }
}
