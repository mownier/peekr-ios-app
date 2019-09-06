//
//  HomeBuilder.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/5/19.
//  Copyright © 2019 Nir. All rights reserved.
//

func createHomeViewControllerWith(tabBarItems: [HomeViewController.TabBarItem]) -> HomeViewController {
    let screen: HomeViewController = viewControllerFromStoryboardWith(name: "Home")
    screen.tabBarItems = Array(tabBarItems.prefix(4))
    return screen
}
