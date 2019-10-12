//
//  ProfileFlow.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/6/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

class ProfileFlow: BaseFlowDefault {
    
    private var dismissMyProfileScreenObserver: NSObjectProtocol?
    private var signOutConfirmationObserver: NSObjectProtocol?
    
    override func registerObservers() -> Bool {
        dismissMyProfileScreenObserver = registerBroadcastObserverWith(
            name: MyProfileViewController.dismissNotification,
            action: dismissMyProfileScreenAction
        )
        
        signOutConfirmationObserver = registerBroadcastObserverWith(
            name: MyProfileViewController.signOutConfirmationNotification,
            action: signOutConfirmationAction
        )
        
        return super.registerObservers()
    }
    
    override func unregisterObservers() -> Bool {
        let isOkay = unregisterBroadcastObserversWith(pairs:
            pairWith(first: MyProfileViewController.dismissNotification, second: dismissMyProfileScreenObserver),
            pairWith(first: MyProfileViewController.signOutConfirmationNotification, second: signOutConfirmationObserver)
        )
        
        dismissMyProfileScreenObserver = nil
        signOutConfirmationObserver = nil
        
        return isOkay
    }
    
    override func allObservers() -> [NSObjectProtocol?] {
        return [
            dismissMyProfileScreenObserver,
            signOutConfirmationObserver,
        ]
    }
    
    private func dismissMyProfileScreenAction(screen: MyProfileViewController) -> Bool {
        return hideMyProfileScreen(screen)
    }
    
    private func signOutConfirmationAction(screen: MyProfileViewController) -> Bool {
        showConfirmationAlertFrom(
            parent: screen,
            message: ProfileStrings.areYouSure,
            title: ProfileStrings.signOut,
            positiveAction: {
                signOut { _ in
                    hideMyProfileScreen(screen)
                    makeLandingScreenAsRootOf(window: self.window)
                }
            }
        )
        return true
    }
}

@discardableResult
func showMyProfileScreenFrom(parent: UIViewController?) -> MyProfileViewController? {
    guard let parentScreen = parent else {
        return nil
    }
    
    let screen = createMyProfileViewController()
    parentScreen.present(screen, animated: true, completion: nil)
    return screen
}

@discardableResult
func hideMyProfileScreen(_ screen: MyProfileViewController) -> Bool {
    screen.dismiss(animated: true, completion: nil)
    return true
}
