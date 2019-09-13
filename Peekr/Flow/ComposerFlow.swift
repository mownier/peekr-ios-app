//
//  ComposerFlow.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/7/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit
import Photos

class ComposerFlow: BaseFlowDefault {

    private var dismissGalleryScreenObserver: NSObjectProtocol?
    private var doneGalleryScreenObserver: NSObjectProtocol?
    
    override func registerObservers() -> Bool {
        dismissGalleryScreenObserver = registerBroadcastObserverWith(
            name: GalleryViewController.dismissNotification,
            action: dismissGalleryScreenAction
        )
        
        doneGalleryScreenObserver = registerBroadcastObserverWith(
            name: GalleryViewController.doneNotification,
            action: doneGalleryScreenAction
        )
        
        return super.registerObservers()
    }
    
    override func unregisterObservers() -> Bool {
        let isOkay = unregisterBroadcastObserversWith(pairs:
            pairWith(first: GalleryViewController.dismissNotification, second: dismissGalleryScreenObserver),
            pairWith(first: GalleryViewController.doneNotification, second: doneGalleryScreenObserver)
        )
        
        dismissGalleryScreenObserver = nil
        doneGalleryScreenObserver = nil
        
        return isOkay
    }
    
    override func allObservers() -> [NSObjectProtocol?] {
        return [
            dismissGalleryScreenObserver,
            doneGalleryScreenObserver,
        ]
    }
    
    private func dismissGalleryScreenAction(_ screen: GalleryViewController) -> Bool {
        return hideGalleryScreen(screen)
    }
    
    private func doneGalleryScreenAction(_ pair: Pair<GalleryViewController, PHAsset>) -> Bool {
        // TODO: Show post composer screen
        return true
    }
}

@discardableResult
func hideGalleryScreen(_ screen: GalleryViewController) -> Bool {
    screen.dismiss(animated: true, completion: nil)
    return true
}

@discardableResult
func showGallertyScreenFrom(parent: UIViewController?) -> GalleryViewController? {
    guard let parentScreen = parent else {
        return nil
    }
    let screen = createGalleryViewController()
    parentScreen.present(screen, animated: true, completion: nil)
    return screen
}
