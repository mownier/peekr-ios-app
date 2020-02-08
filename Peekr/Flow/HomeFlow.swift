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
    private var showComposeScreenObserver: NSObjectProtocol?
    
    override func registerObservers() -> Bool {
        showMyProfileScreenObserver = registerBroadcastObserverWith(
            name: HomeViewController.showMyProfileScreenNotification,
            action: showMyProfileScreenAction
        )
        
        showComposeScreenObserver = registerBroadcastObserverWith(
            name: HomeViewController.showComposeScreenNotification,
            action: showComposeScreenAction
        )
        
        return super.registerObservers()
    }
    
    override func unregisterObservers() -> Bool {
        let isOkay = unregisterBroadcastObserversWith(pairs:
            pairWith(first: HomeViewController.showMyProfileScreenNotification, second: showMyProfileScreenObserver),
            pairWith(first: HomeViewController.showComposeScreenNotification, second: showComposeScreenObserver)
        )
        
        showMyProfileScreenObserver = nil
        showComposeScreenObserver = nil
        
        return isOkay
    }
    
    override func allObservers() -> [NSObjectProtocol?] {
        return [
            showMyProfileScreenObserver,
            showComposeScreenObserver,
        ]
    }
    
    private func showMyProfileScreenAction(parent: UIViewController) -> Bool {
        return showMyProfileScreenFrom(parent: parent) != nil
    }
    
    private func showComposeScreenAction(parent: UIViewController) -> Bool {
        return showGallertyScreenFrom(parent: parent) != nil
    }
}

@discardableResult
func makeHomeScreenAsRootOf(window: UIWindow) -> HomeViewController {
    let screen = createHomeViewControllerWith(tabBarItems: [
        HomeViewController.TabBarItem(
            selectedImageName: "icon-home",
            defaultImageName: "icon-home-deselected",
            screen: { _ in
                let screen = createNewsFeedViewController()
                return screen
        }),
        HomeViewController.TabBarItem(
            selectedImageName: "icon-search",
            defaultImageName: "icon-search-deselected",
            screen: { _ in
                let screen = createOverallSearchScreen()
                    .setContentView({ screen in
                        let usersSearchResultScreen = createUsersSearchResultScreen()
                        screen.addChild(usersSearchResultScreen)
                        usersSearchResultScreen.didMove(toParent: screen)
                        return usersSearchResultScreen.view
                    })
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
