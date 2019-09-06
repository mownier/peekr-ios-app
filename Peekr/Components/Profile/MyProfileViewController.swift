//
//  MyProfileViewController.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/6/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signOutButton.setTitle(ProfileStrings.signOut, for: .normal)
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }
    
    @IBAction func onTapCloseButton() {
        broadcastWith(name: MyProfileViewController.dismissNotification, info: self)
    }
    
    @IBAction func onTapSignOutButton() {
        
    }
    
    static let dismissNotification = Notification.Name(rawValue: ProfileStrings.dismissNotificationRawName)
}
