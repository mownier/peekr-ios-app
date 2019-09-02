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
    private var signInResultObserver: NSObjectProtocol?
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        let navigationController = UINavigationController(rootViewController: createSignInViewController())
        self.window.rootViewController = navigationController
    }
    
    @discardableResult
    func registerObservers() -> Bool {
        signUpResultObserver = registerBroadcastObserverWith(
            name: SignUpViewController.signUpResultNotification,
            action: signUpResultObserverAction
        )
        
        signInResultObserver = registerBroadcastObserverWith(
            name: SignInViewController.signInResultNotification,
            action: signInResultObserverAction
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
            pairWith(first: SignUpViewController.signUpResultNotification, second: signUpResultObserver),
            pairWith(first: SignInViewController.signInResultNotification, second: signInResultObserver)
        )
        
        signUpResultObserver = nil
        signInResultObserver = nil
        
        return isOkay
    }
    
    func allObservers() -> [NSObjectProtocol?] {
        return [
            signUpResultObserver,
            signInResultObserver
        ]
    }
    
    private func signUpResultObserverAction(_ result: Result<String>) -> Bool {
        guard let rootScreen = window.rootViewController else {
            return false
        }

        switch result {
        case let .notOkay(error):
            showSimpleAlertFrom(parent: rootScreen, message: error.localizedDescription, title: UIStrings.error)
        
        case .okay:
            // TODO: Set rootViewController to Home
            break
        }
        
        return true
    }
    
    private func signInResultObserverAction(_ result: Result<String>) -> Bool {
        guard let rootScreen = window.rootViewController else {
            return false
        }
        
        switch result {
        case let .notOkay(error):
            showSimpleAlertFrom(parent: rootScreen, message: error.localizedDescription, title: UIStrings.error)
            
        case .okay:
            // TODO: Set rootViewController to Home
            break
        }
        
        return true
    }
}

func appFlowWith(window: UIWindow?) -> AppFlow? {
    guard window != nil else {
        return nil
    }
    return AppFlow(window: window!)
}
