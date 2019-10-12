//
//  VideoView.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/7/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoView: UIView {

    private var didPlayToEndTimeObserver: NSObjectProtocol?
    
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    
    var isLoopEnabled: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @discardableResult
    func configure(url videoURL: URL) -> Bool {
        let videoPlayer = AVPlayer(url: videoURL)
        let videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        videoPlayerLayer.frame = bounds
        videoPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layer.addSublayer(videoPlayerLayer)
        
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        
        player = videoPlayer
        playerLayer = videoPlayerLayer
        
        unregisterBroadcastObserversWith(pairs:
            pairWith(first: NSNotification.Name.AVPlayerItemDidPlayToEndTime, second: didPlayToEndTimeObserver)
        )
        didPlayToEndTimeObserver = registerBroadcastObserverWith(
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime
        ) {
            self.tryToLoopBack()
        }
        
        return true
    }
    
    @discardableResult
    func configure(url: String) -> Bool {
        guard let videoURL = URL(string: url) else {
            return false
        }
        
        return configure(url: videoURL)
    }
    
    @discardableResult
    func play() -> Bool {
        guard let videoPlayer = player,
            videoPlayer.timeControlStatus != AVPlayer.TimeControlStatus.playing else {
                return false
        }
    
        videoPlayer.play()
        return true
    }
    
    @discardableResult
    func pause() -> Bool {
        guard let videoPlayer = player else {
            return false
        }
        
        videoPlayer.pause()
        return true
    }
    
    @discardableResult
    func stop() -> Bool {
        guard let videoPlayer = player else {
            return false
        }
        
        videoPlayer.pause()
        videoPlayer.seek(to: CMTime.zero)
        return true
    }
    
    @discardableResult
    func tryToLoopBack() -> Bool {
        guard isLoopEnabled, let videoPlayer = player else {
            return false
        }
        
        videoPlayer.pause()
        videoPlayer.seek(to: CMTime.zero)
        videoPlayer.play()
        
        return true
    }
    
    @discardableResult
    func sanitize() -> Bool {
        stop()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        unregisterBroadcastObserversWith(pairs:
            pairWith(first: NSNotification.Name.AVPlayerItemDidPlayToEndTime, second: didPlayToEndTimeObserver)
        )
        didPlayToEndTimeObserver = nil
        return true
    }
}
