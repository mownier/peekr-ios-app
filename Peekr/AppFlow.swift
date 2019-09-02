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
    private var landingToSignInScreenObserver: NSObjectProtocol?
    private var landingToSignUpScreenObserver: NSObjectProtocol?
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        let navigationController = UINavigationController(rootViewController: createLandingViewController())
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
        
        landingToSignInScreenObserver = registerBroadcastObserverWith(
            name: LandingViewController.goToSignScreenNotification,
            action: {
                showSignInScreenUsing(
                    navigationController: self.window.rootViewController as? UINavigationController
                )
        })
        
        landingToSignUpScreenObserver = registerBroadcastObserverWith(
            name: LandingViewController.goToSignUpScreenNotification,
            action: {
                showSignUpScreenUsing(
                    navigationController: self.window.rootViewController as? UINavigationController
                )
        })
        
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
            pairWith(first: SignInViewController.signInResultNotification, second: signInResultObserver),
            pairWith(first: LandingViewController.goToSignScreenNotification, second: landingToSignInScreenObserver),
            pairWith(first: LandingViewController.goToSignUpScreenNotification, second: landingToSignUpScreenObserver)
        )
        
        signUpResultObserver = nil
        signInResultObserver = nil
        landingToSignInScreenObserver = nil
        landingToSignUpScreenObserver = nil
        
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

@discardableResult
private func showSignInScreenUsing(navigationController: UINavigationController?) -> SignInViewController? {
    guard let nav = navigationController else {
        return nil
    }
    
    let screen = createSignInViewController()
    nav.pushViewController(screen, animated: true)
    return screen
}

private func showSignUpScreenUsing(navigationController: UINavigationController?) -> SignUpViewController? {
    guard let nav = navigationController else {
        return nil
    }
    
    let screen = createSignUpViewController()
    nav.pushViewController(screen, animated: true)
    return screen
}
