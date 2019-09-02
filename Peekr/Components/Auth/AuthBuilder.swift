//
//  AuthBuilder.swift
//  Peekr
//
//  Created by Mounir Ybanez on 8/28/19.
//  Copyright © 2019 Nir. All rights reserved.
//

func createSignUpViewController() -> SignUpViewController {
    return viewControllerFromStoryboardWith(name: "Auth")
}
