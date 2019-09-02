//
//  LandingViewController.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/2/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.setTitle(OnboardingStrings.signIn, for: .normal)
        signUpButton.setTitle(OnboardingStrings.signUp, for: .normal)
    }
    
    @IBAction func onTapSignInButton() {
        broadcastWith(name: LandingViewController.goToSignScreenNotification)
    }
    
    @IBAction func onTapSignUpButton() {
        broadcastWith(name: LandingViewController.goToSignUpScreenNotification)
    }
    
    static let goToSignScreenNotification = Notification.Name(rawValue: OnboardingStrings.goToSignInScreenNotificationRawName)
    static let goToSignUpScreenNotification = Notification.Name(rawValue: OnboardingStrings.goToSignUpScreenNotificationRawname)
}
