//
//  AuthFlow.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/3/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

class AuthFlow: BaseFlowDefault {
    
    private var signUpResultObserver: NSObjectProtocol?
    private var signInResultObserver: NSObjectProtocol?
    
    override func registerObservers() -> Bool {
        signUpResultObserver = registerBroadcastObserverWith(
            name: SignUpViewController.signUpResultNotification,
            action: signUpResultObserverAction
        )
        
        signInResultObserver = registerBroadcastObserverWith(
            name: SignInViewController.signInResultNotification,
            action: signInResultObserverAction
        )
        
        return super.registerObservers()
    }
    
    override  func unregisterObservers() -> Bool {
        let isOkay = unregisterBroadcastObserversWith(pairs:
            pairWith(first: SignUpViewController.signUpResultNotification, second: signUpResultObserver),
            pairWith(first: SignInViewController.signInResultNotification, second: signInResultObserver)
        )
        
        signUpResultObserver = nil
        signInResultObserver = nil
        
        return isOkay
    }
    
    override func allObservers() -> [NSObjectProtocol?] {
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
            makeHomeScreenAsRootOf(window: window)
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
            makeHomeScreenAsRootOf(window: window)
        }
        
        return true
    }
}

@discardableResult
func showSignInScreenUsing(navigationController: UINavigationController?) -> SignInViewController? {
    guard let nav = navigationController else {
        return nil
    }
    
    let screen = createSignInViewController()
    nav.pushViewController(screen, animated: true)
    return screen
}

@discardableResult
func showSignUpScreenUsing(navigationController: UINavigationController?) -> SignUpViewController? {
    guard let nav = navigationController else {
        return nil
    }
    
    let screen = createSignUpViewController()
    nav.pushViewController(screen, animated: true)
    return screen
}
