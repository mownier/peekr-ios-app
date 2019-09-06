//
//  HomeFlow.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/6/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

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
