//
//  SignUpViewController.swift
//  Peekr
//
//  Created by Mounir Ybanez on 8/28/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.placeholder = AuthStrings.email
        passwordTextField.placeholder = AuthStrings.password
        
        actionButton.setTitle(AuthStrings.signUp, for: .normal)
    }
    
    @IBAction func onTapActionButton() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        signUpWith(email: email, password: password) { result in
            broadcastWith(name: SignUpViewController.signUpResultNotification, info: result)
        }
    }

    static let signUpResultNotification = Notification.Name(rawValue: AuthStrings.signUpResultNotificationRawName)
}
