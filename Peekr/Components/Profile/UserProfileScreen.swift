//
//  UserProfileScreen.swift
//  Peekr
//
//  Created by Mounir Ybanez on 12/14/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit
import Nuke

class UserProfileScreen: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followRequestLoadingView: UIActivityIndicatorView!
    @IBOutlet weak var needDataIfFollowingLoadingView: UIActivityIndicatorView!
    
    var onFollow: ((UserProfileScreen) -> Void)?
    var onUnfollow: ((UserProfileScreen) -> Void)?
    var onNeedDataIfFollowing: ((UserProfileScreen) -> Void)?
    var onClose: ((UserProfileScreen) -> Void)?
    var isFollowing: Bool?
    var followText: String?
    var followingText: String?
    var displayNameText: String = ""
    var avatarURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        needDataIfFollowingLoadingView.layer.masksToBounds = true
        needDataIfFollowingLoadingView.layer.borderColor = Colors.gray1?.cgColor
        needDataIfFollowingLoadingView.layer.borderWidth = 1
        avatarImageView.layer.masksToBounds = true
        avatarImageView.backgroundColor = Colors.gray1
        displayNameLabel.text = displayNameText
        toggleFollowAndFollowingButtons()
        if let text = followText {
            followButton.setTitle(text, for: .normal)
        }
        if let text = followingText {
            followingButton.setTitle(text, for: .normal)
        }
        if let url = avatarURL {
            loadImage(with: url, into: avatarImageView)
        }
        onNeedDataIfFollowing?(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }
    
    @IBAction func onTapFollowButton() {
        followButton.isUserInteractionEnabled = false
        followRequestLoadingView.startAnimating()
        onFollow?(self)
    }
    
    @IBAction func onTapFollowingButton() {
        followingButton.isUserInteractionEnabled = false
        followRequestLoadingView.startAnimating()
        onUnfollow?(self)
    }
    
    @IBAction func onTapCloseButton() {
        onClose?(self)
    }
    
    @discardableResult
    func onFollow(_ action: @escaping (UserProfileScreen) -> Void) -> UserProfileScreen {
        onFollow = action
        return self
    }
    
    @discardableResult
    func onUnfollow(_ action: @escaping (UserProfileScreen) -> Void) -> UserProfileScreen {
        onUnfollow = action
        return self
    }
    
    @discardableResult
    func onClose(_ action: @escaping (UserProfileScreen) -> Void) -> UserProfileScreen {
        onClose = action
        return self
    }
    
    @discardableResult
    func onNeedDataIfFollowing(_ action: @escaping (UserProfileScreen) -> Void) -> UserProfileScreen {
        onNeedDataIfFollowing = action
        return self
    }
    
    @discardableResult
    func isFollowing(_ value: Bool) -> UserProfileScreen {
        isFollowing = value
        return toggleFollowAndFollowingButtons()
    }
    
    @discardableResult
    func followText(_ text: String) -> UserProfileScreen {
        followText = text
        return self
    }
    
    @discardableResult
    func followingText(_ text: String) -> UserProfileScreen {
        followingText = text
        return self
    }
    
    @discardableResult
    func displayNameText(_ text: String) -> UserProfileScreen {
        displayNameText = text
        return self
    }
    
    @discardableResult
    func avatarURL(_ url: URL?) -> UserProfileScreen {
        avatarURL = url
        return self
    }
    
    @discardableResult
    private func toggleFollowAndFollowingButtons() -> UserProfileScreen {
        if let isFollowing = isFollowing {
            followButton?.isHidden = isFollowing
            followingButton?.isHidden = !isFollowing
            needDataIfFollowingLoadingView?.stopAnimating()
            followRequestLoadingView?.stopAnimating()
        
        } else {
            followButton?.isHidden = true
            followingButton?.isHidden = true
            needDataIfFollowingLoadingView?.startAnimating()
            followRequestLoadingView?.stopAnimating()
        }
        followButton?.isUserInteractionEnabled = true
        followingButton?.isUserInteractionEnabled = true
        return self
    }
}

func createUserProfileScreen() -> UserProfileScreen {
    let screen: UserProfileScreen = viewControllerFromStoryboardWith(name: "Profile")
    return screen
}
