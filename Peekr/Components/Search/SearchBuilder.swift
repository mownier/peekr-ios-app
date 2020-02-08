//
//  SearchBuilder.swift
//  Peekr
//
//  Created by Mounir Ybanez on 2/8/20.
//  Copyright © 2020 Nir. All rights reserved.
//

import UIKit

func createOverallSearchScreen() -> OverallSearchScreen {
    return viewControllerFromStoryboardWith(name: "Search")
}

func createUsersSearchResultScreen() -> UsersSearchResultScreen {
    return viewControllerFromStoryboardWith(name: "Search")
}
