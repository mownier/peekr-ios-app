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
    private var cancelComposingObserver: NSObjectProtocol?
    
    override func registerObservers() -> Bool {
        dismissGalleryScreenObserver = registerBroadcastObserverWith(
            name: GalleryViewController.dismissNotification,
            action: dismissGalleryScreenAction
        )
        
        doneGalleryScreenObserver = registerBroadcastObserverWith(
            name: GalleryViewController.doneNotification,
            action: doneGalleryScreenAction
        )
        
        cancelComposingObserver = registerBroadcastObserverWith(
            name: PostComposerViewController.cancelComposingNotification,
            action: cancelComposingAction
        )
        
        return super.registerObservers()
    }
    
    override func unregisterObservers() -> Bool {
        let isOkay = unregisterBroadcastObserversWith(pairs:
            pairWith(first: GalleryViewController.dismissNotification, second: dismissGalleryScreenObserver),
            pairWith(first: GalleryViewController.doneNotification, second: doneGalleryScreenObserver),
            pairWith(first: PostComposerViewController.cancelComposingNotification, second: cancelComposingObserver)
        )
        
        dismissGalleryScreenObserver = nil
        doneGalleryScreenObserver = nil
        cancelComposingObserver = nil
        
        return isOkay
    }
    
    override func allObservers() -> [NSObjectProtocol?] {
        return [
            dismissGalleryScreenObserver,
            doneGalleryScreenObserver,
            cancelComposingObserver,
        ]
    }
    
    private func dismissGalleryScreenAction(_ screen: GalleryViewController) -> Bool {
        return hideGalleryScreen(screen)
    }
    
    private func doneGalleryScreenAction(_ pair: Pair<GalleryViewController, PHAsset>) -> Bool {
        return showPostComposerScreen(with: pair) != nil
    }
    
    private func cancelComposingAction(_ screen: PostComposerViewController) -> Bool {
        return hidePostComposerScreen(screen)
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

@discardableResult
func showPostComposerScreen(with pair: Pair<GalleryViewController, PHAsset>?) -> PostComposerViewController? {
    guard let pair = pair else {
        return nil
    }
    let parent = pair.first
    let screen = createPostComposerViewController(asset: pair.second)
    let transition = TranslationTransitioning()
    transition.presentationDirection = .left
    transition.dismissalDirection = .right
    screen.transitioningDelegate = transition
    parent.present(screen, animated: true, completion: nil)
    return screen
}

@discardableResult
func hidePostComposerScreen(_ screen: PostComposerViewController) -> Bool {
    let transition = TranslationTransitioning()
    transition.presentationDirection = .left
    transition.dismissalDirection = .right
    screen.transitioningDelegate = transition
    screen.dismiss(animated: true, completion: nil)
    return true
}
