//
//  PostComposerUpdateScreen.swift
//  Peekr
//
//  Created by Mounir Ybanez on 10/12/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

class PostComposerUpdateScreen: UIViewController {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var imageURL: URL!
    var videoURL: URL!
    var messageText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thumbnailImageView.image = UIImage(contentsOfFile: imageURL.path)
        messageLabel.text = messageText
        
        sharePost(
            with: messageText,
            imageURL: imageURL,
            videoURL: videoURL,
            track: { [weak self] progress in
                DispatchQueue.main.async {
                    self?.progressView?.progress = Float(progress)
                }
                
        }, completion: { result in
            DispatchQueue.main.async {
                broadcastWith(
                    name: PostComposerUpdateScreen.resultOfSharingPostNotification,
                    info: pairWith(first: self, second: result)
                )
            }
        })
    }
    
    func setMessageText(_ text: String) -> PostComposerUpdateScreen {
        messageText = text
        return self
    }
    
    func setImageURL(_ url: URL) -> PostComposerUpdateScreen {
        imageURL = url
        return self
    }
    
    func setVideoURL(_ url: URL) -> PostComposerUpdateScreen {
        videoURL = url
        return self
    }
    
    static let resultOfSharingPostNotification = Notification.Name(rawValue: ComposerStrings.resultOfSharingPostRawName)
}

func createPostComposerUpdateScreen() -> PostComposerUpdateScreen {
    let screen: PostComposerUpdateScreen = viewControllerFromStoryboardWith(name: "Composer")
    return screen
}
