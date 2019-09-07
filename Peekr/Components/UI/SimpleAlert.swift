//
//  SimpleAlert.swift
//  Peekr
//
//  Created by Mounir Ybanez on 8/28/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

@discardableResult
public func showSimpleAlertFrom(parent: UIViewController, message: String, title: String, actionHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okayAction = UIAlertAction(title: CoreStrings.ok, style: .default, handler: actionHandler)
    alert.addAction(okayAction)
    parent.present(alert, animated: true, completion: nil)
    return alert
}

@discardableResult
public func showConfirmationAlertFrom(parent: UIViewController, message: String, title: String, positiveAction: (() -> Void)? = nil, negativeAction: (() -> Void)? = nil) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let positiveAlertAction = UIAlertAction(
        title: CoreStrings.ok,
        style: .default,
        handler: { _ in positiveAction?() }
    )
    let negativeAlertAction = UIAlertAction(
        title: UIStrings.cancel,
        style: .cancel,
        handler: { _ in negativeAction?() }
    )
    alert.addAction(negativeAlertAction)
    alert.addAction(positiveAlertAction)
    parent.present(alert, animated: true, completion: nil)
    return alert
}
