//
//  OnboardingFlow.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/3/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

class OnboardingFlow: BaseFlowDefault {

    private var showSignInScreenObserver: NSObjectProtocol?
    private var showSignUpScreenObserver: NSObjectProtocol?
    
    override func registerObservers() -> Bool {
        showSignInScreenObserver = registerBroadcastObserverWith(
            name: LandingViewController.goToSignScreenNotification,
            action: {
                showSignInScreenUsing(
                    navigationController: self.window.rootViewController as? UINavigationController
                )
        })
        
        showSignUpScreenObserver = registerBroadcastObserverWith(
            name: LandingViewController.goToSignUpScreenNotification,
            action: {
                showSignUpScreenUsing(
                    navigationController: self.window.rootViewController as? UINavigationController
                )
        })
        
        return super.registerObservers()
    }
    
    override func unregisterObservers() -> Bool {
        let isOkay = unregisterBroadcastObserversWith(pairs:
            pairWith(first: LandingViewController.goToSignScreenNotification, second: showSignInScreenObserver),
            pairWith(first: LandingViewController.goToSignUpScreenNotification, second: showSignUpScreenObserver)
        )
        
        showSignInScreenObserver = nil
        showSignUpScreenObserver = nil
        
        return isOkay
    }
    
    override func allObservers() -> [NSObjectProtocol?] {
        return [
            showSignInScreenObserver,
            showSignUpScreenObserver
        ]
    }
}

@discardableResult
func makeLandingScreenAsRootOf(window: UIWindow, embedInNavigationController: Bool = true) -> LandingViewController {
    let screen = createLandingViewController()
    let rootScreen: UIViewController
    if embedInNavigationController {
        rootScreen = UINavigationController(rootViewController: screen)
        
    } else {
        rootScreen = screen
    }
    window.rootViewController = rootScreen
    return screen
}
