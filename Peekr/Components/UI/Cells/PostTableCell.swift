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
    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var soundButton: UIButton!
    
    private var ratioConstraint: NSLayoutConstraint?
    weak var delegate: PostTableCellDelegate?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        videoView.isLoopEnabled = true
        videoView.changeVideoGravity(to: .resize).enableCaching()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapToToggleMute))
        tap.numberOfTapsRequired = 1
        videoView.addGestureRecognizer(tap)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        updateTextOfSoundButton("Unmute")
        elapsedTimeLabel.text = "0:00"
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height / 2
        videoView.layoutIfNeeded()
        videoView.setNeedsLayout()
    }
    
    @discardableResult
    public func adjustVideoContainerSizeRelative(to videoSize: CGSize) -> PostTableCell {
        if let constraint = ratioConstraint {
            ratioConstraint?.isActive = false
            videoContainer.removeConstraint(constraint)
        }
        let ratio = videoSize.height / videoSize.width
        let width = videoContainer.bounds.width
        let height = width * ratio
        let aspectRatioConstraint = NSLayoutConstraint(
            item: videoContainer,
            attribute: .height,
            relatedBy: .equal,
            toItem: videoContainer,
            attribute: .width,
            multiplier: (height / width),
            constant: 0
        )
        videoContainer.addConstraint(aspectRatioConstraint)
        ratioConstraint = aspectRatioConstraint
        return self
    }
    
    @discardableResult
    public func delegate(_ value: PostTableCellDelegate) -> PostTableCell {
        delegate = value
        return self
    }
    
    @discardableResult
    public func updateTextOfSoundButton(_ text: String) -> PostTableCell {
        soundButton.setTitle(text, for: .normal)
        return self
    }
    
    @objc
    func onTapToToggleMute() {
        if videoView.isMuted() {
            videoView.unmute()
            delegate?.postTableCellOnUnmuted(self)
            return
        }
        videoView.mute()
        delegate?.postTableCellOnMuted(self)
    }
}

public protocol PostTableCellDelegate: class {
    
    func postTableCellOnMuted(_ cell: PostTableCell)
    func postTableCellOnUnmuted(_ cell: PostTableCell)
}
