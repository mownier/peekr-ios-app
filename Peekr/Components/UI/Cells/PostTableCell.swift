//
//  PostTableCell.swift
//  Peekr
//
//  Created by Mounir Ybanez on 11/9/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

public class PostTableCell: UITableViewCell {
    
    @IBOutlet weak var cardBackgroundView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cardBackgroundViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewImageView: UIImageView!
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height / 2
    }
}
