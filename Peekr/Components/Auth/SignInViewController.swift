//
//  SignInViewController.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/2/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = AuthStrings.signIn
        
        emailTextField.placeholder = AuthStrings.email
        passwordTextField.placeholder = AuthStrings.password
        
        actionButton.setTitle(AuthStrings.signIn, for: .normal)
    }
    
    @IBAction func onTapActionButton() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        signInWith(email: email, password: password) { result in
            broadcastWith(name: SignInViewController.signInResultNotification, info: result)
        }
    }
    
    static let signInResultNotification = Notification.Name(rawValue: AuthStrings.signInResultNotificationRawName)
}
