//
//  HomeFlow.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/6/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

class HomeFlow: BaseFlowDefault {
    
    private var showMyProfileScreenObserver: NSObjectProtocol?
    
    override func registerObservers() -> Bool {
        showMyProfileScreenObserver = registerBroadcastObserverWith(
            name: HomeViewController.showMyProfileScreenNotification,
            action: {
                // TODO: Show my profile screen
                print("TODO: Show my profile screen")
        })
        
        return super.registerObservers()
    }
    
    override func unregisterObservers() -> Bool {
        let isOkay = unregisterBroadcastObserversWith(pairs:
            pairWith(first: HomeViewController.showMyProfileScreenNotification, second: showMyProfileScreenObserver)
        )
        
        showMyProfileScreenObserver = nil
        
        return isOkay
    }
    
    override func allObservers() -> [NSObjectProtocol?] {
        return [
            showMyProfileScreenObserver
        ]
    }
}

@discardableResult
func makeHomeScreenAsRootOf(window: UIWindow) -> HomeViewController {
    let screen = createHomeViewControllerWith(tabBarItems: [
        HomeViewController.TabBarItem(
            selectedImageName: "icon-home",
            defaultImageName: "icon-home-deselected",
            screen: { _ in
                let screen = UIViewController()
                screen.view.backgroundColor = UIColor.red
                return screen
        }),
        HomeViewController.TabBarItem(
            selectedImageName: "icon-search",
            defaultImageName: "icon-search-deselected",
            screen: { _ in
                let screen = UIViewController()
                screen.view.backgroundColor = UIColor.blue
                return screen
        }),
        HomeViewController.TabBarItem(
            selectedImageName: "icon-inbox",
            defaultImageName: "icon-inbox-deselected",
            screen: { _ in
                let screen = UIViewController()
                screen.view.backgroundColor = UIColor.green
                return screen
        }),
        HomeViewController.TabBarItem(
            selectedImageName: "icon-envelope",
            defaultImageName: "icon-envelope-deselected",
            screen: { _ in
                let screen = UIViewController()
                screen.view.backgroundColor = UIColor.yellow
                return screen
        })
    ])
    window.rootViewController = screen
    return screen
}
