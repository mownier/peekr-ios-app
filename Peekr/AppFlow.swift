//
//  AppFlow.swift
//  Peekr
//
//  Created by Mounir Ybanez on 8/28/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

class AppFlow {
    
    private var signUpResultObserver: NSObjectProtocol?
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        // TODO: Attach root
    }
    
    @discardableResult
    func registerObservers() -> Bool {
        signUpResultObserver = registerBroadcastObserverWith(
            name: SignUpViewController.signUpResultNotification,
            action: signUpResultObserverAction
        )
        return allObservers()
            .map({ $0 != nil })
            .reduce(true, { result, item -> Bool in
                return result && item
            })
    }
    
    @discardableResult
    func unregisterObservers() -> Bool {
        let isOkay = unregisterBroadcastObserversWith(pairs:
            pairWith(first: SignUpViewController.signUpResultNotification, second: signUpResultObserver)
        )
        
        signUpResultObserver = nil
        
        return isOkay
    }
    
    func allObservers() -> [NSObjectProtocol?] {
        return [
            signUpResultObserver
        ]
    }
    
    private func signUpResultObserverAction(_ result: Result<String>) {
        // TOOD: Go to home
    }
}

func appFlowWith(window: UIWindow?) -> AppFlow? {
    guard window != nil else {
        return nil
    }
    return AppFlow(window: window!)
}

