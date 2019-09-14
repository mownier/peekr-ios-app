//
//  PostComposerViewController.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/7/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit
import Photos

class PostComposerViewController: UIViewController {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var asset: PHAsset!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextView.layer.cornerRadius = 3.0
        
        shareButton.setTitle(ComposerStrings.share, for: .normal)
        titleButton.setTitle(ComposerStrings.shareTo, for: .normal)
        
        thumbnailImageView.setImageFor(asset: asset)
    }
    
    @IBAction func onTapCloseButton() {
        broadcastWith(name: PostComposerViewController.cancelComposingNotification, info: self)
    }
    
    @IBAction func onTapShareButton() {
        
    }
    
    static let shareNotification = Notification.Name(rawValue: ComposerStrings.shareNotificationRawName)
    static let cancelComposingNotification = Notification.Name(rawValue: ComposerStrings.cancelComposingNotificationRawName)
}
