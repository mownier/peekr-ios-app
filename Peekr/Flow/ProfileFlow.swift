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
    
    override func registerObservers() -> Bool {
        dismissMyProfileScreenObserver = registerBroadcastObserverWith(
            name: MyProfileViewController.dismissNotification,
            action: dismissMyProfileScreenAction
        )
        
        return super.registerObservers()
    }
    
    override func unregisterObservers() -> Bool {
        let isOkay = unregisterBroadcastObserversWith(pairs:
            pairWith(first: MyProfileViewController.dismissNotification, second: dismissMyProfileScreenObserver)
        )
        
        dismissMyProfileScreenObserver = nil
        
        return isOkay
    }
    
    override func allObservers() -> [NSObjectProtocol?] {
        return [
            dismissMyProfileScreenObserver
        ]
    }
    
    private func dismissMyProfileScreenAction(screen: MyProfileViewController) -> Bool {
        return hideMyProfileScreen(screen)
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
