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
    private var periodicTimeObserver: Any?
    
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var videoGravity: AVLayerVideoGravity = .resizeAspect
    private var isCachingEnabled: Bool = false
    private var cacheFileVideoKey: String = ""
    private var cacheFileName: String = ""
    private var cacheFileVideoType: AVFileType?
    
    var isLoopEnabled: Bool = false
    var onStart: ((VideoView) -> Void)?
    var onReadyToPlay: ((VideoView) -> Void)?
    var onRemainingTimeInSeconds: ((VideoView?, Double) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer?.frame = bounds
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard let videoPlayer = player,
            object as AnyObject? === videoPlayer else {
                return
        }
        if keyPath == "status" {
            if videoPlayer.status == .readyToPlay {
                onReadyToPlay?(self)
                addPeriodicTimeObserver()
                play()
            }
            return
        }
        if keyPath == "rate" {
            if videoPlayer.rate > 0 {
                onStart?(self)
            }
        }
    }
    
    @discardableResult
    func configure(url videoURL: URL) -> Bool {
        let videoPlayer = AVPlayer(url: videoURL)
        let videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        videoPlayerLayer.frame = bounds
        videoPlayerLayer.videoGravity = videoGravity
        videoPlayer.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
        videoPlayer.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
        videoPlayer.isMuted = true
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
            self.tryToCacheVideo()
                .tryToLoopBack()
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
        if let observer = periodicTimeObserver {
            player?.removeTimeObserver(observer)
            periodicTimeObserver = nil
        }
        player?.removeObserver(self, forKeyPath: "rate")
        player?.removeObserver(self, forKeyPath: "status")
        playerLayer?.removeFromSuperlayer()
        onRemainingTimeInSeconds = nil
        onReadyToPlay = nil
        onStart = nil
        player = nil
        playerLayer = nil
        unregisterBroadcastObserversWith(pairs:
            pairWith(first: NSNotification.Name.AVPlayerItemDidPlayToEndTime, second: didPlayToEndTimeObserver)
        )
        didPlayToEndTimeObserver = nil
        return true
    }
    
    @discardableResult
    func changeVideoGravity(to gravity: AVLayerVideoGravity) -> VideoView {
        videoGravity = gravity
        return self
    }
    
    @discardableResult
    func enableCaching() -> VideoView {
        isCachingEnabled = true
        return self
    }
    
    @discardableResult
    func disableCaching() -> VideoView {
        isCachingEnabled = false
        return self
    }
    
    @discardableResult
    func cacheFileName(_ fileName: String) -> VideoView {
        cacheFileName = fileName
        return self
    }
    
    @discardableResult
    func cacheVideoFileType(_ type: AVFileType) -> VideoView {
        cacheFileVideoType = type
        return self
    }
    
    @discardableResult
    func cacheVideoFileKey(_ key: String) -> VideoView {
        cacheFileVideoKey = key
        return self
    }
    
    @discardableResult
    func tryToCacheVideo() -> VideoView {
        guard isCachingEnabled,
            !cacheFileName.isEmpty,
            !cacheFileVideoKey.isEmpty,
            let item = player?.currentItem,
            item.asset.isExportable,
            let fileType = cacheFileVideoType else {
                return self
        }
        let composition = AVMutableComposition()
        let compositionVideoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid)
        )
        let compositionAudioTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid)
        )
        let sourceVideoTrack = item.asset.tracks(withMediaType: .video).first!
        let sourceAudioTrack = item.asset.tracks(withMediaType: .audio).first!
        do {
            try compositionVideoTrack?.insertTimeRange(
                CMTimeRangeMake(start: CMTime.zero, duration: item.duration),
                of: sourceVideoTrack,
                at: CMTime.zero
            )
            try compositionAudioTrack?.insertTimeRange(
                CMTimeRangeMake(start: CMTime.zero, duration: item.duration),
                of: sourceAudioTrack,
                at: CMTime.zero
            )
        } catch(_) {
            return self
        }
        let fileManager = FileManager.default
        guard
            let exporter = AVAssetExportSession(
                asset: composition,
                presetName: AVAssetExportPresetHighestQuality
            ),
            let cacheDirectory = fileManager.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            ).first else {
                return self
        }
        let cacheKey = cacheFileVideoKey
        let outputURL = cacheDirectory.appendingPathComponent(cacheFileName)
        if fileManager.isDeletableFile(atPath: outputURL.path) {
            try? fileManager.removeItem(at: outputURL)
        }
        exporter.outputURL = outputURL
        exporter.outputFileType = fileType
        exporter.exportAsynchronously {
            guard exporter.status == .completed,
                exporter.error == nil else {
                return
            }
            addCachedVideo(with: cacheKey, url: outputURL)
        }
        return self
    }
    
    @discardableResult
    func addPeriodicTimeObserver() -> VideoView {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        periodicTimeObserver = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: mainQueue
        ) { [weak self] time in
            let currentSeconds = CMTimeGetSeconds(time)
            guard let duration = self?.player?.currentItem?.duration else {
                return
            }
            let totalSeconds = CMTimeGetSeconds(duration)
            self?.onRemainingTimeInSeconds?(self, totalSeconds - currentSeconds)
        }
        return self
    }
    
    @discardableResult
    func mute() -> VideoView {
        player?.isMuted = true
        return self
    }
    
    @discardableResult
    func unmute() -> VideoView {
        player?.isMuted = false
        return self
    }
    
    func isMuted() -> Bool {
        return player?.isMuted ?? false
    }
}

private var videoCacheURLs: [String: URL] = [:]

@discardableResult
func removeAllCachedVideos() -> Bool {
    let fileManager = FileManager.default
    videoCacheURLs.forEach({
        try? fileManager.removeItem(at: $0.value)
    })
    return true
}

@discardableResult
private func addCachedVideo(with key: String, url: URL) -> Bool {
    videoCacheURLs[key] = url
    return true
}

@discardableResult
func urlOfCachedVideo(for key: String) -> URL? {
    return videoCacheURLs[key]
}
