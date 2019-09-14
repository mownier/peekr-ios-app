//
//  ComposerBuilder.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/7/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import Photos

func createGalleryViewController() -> GalleryViewController {
    return viewControllerFromStoryboardWith(name: "Composer")
}

func createPostComposerViewController(asset: PHAsset) -> PostComposerViewController {
    let screen: PostComposerViewController = viewControllerFromStoryboardWith(name: "Composer")
    screen.asset = asset
    return screen
}
