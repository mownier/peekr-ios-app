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
    private var didStartPlayingTimeObserver: Any?
    
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var videoGravity: AVLayerVideoGravity = .resizeAspect
    private var isCachingEnabled: Bool = false
    private var cacheFileName: String = ""
    private var cacheFileVideoType: AVFileType?
    
    var isLoopEnabled: Bool = false
    var onStart: ((VideoView?) -> Void)?
    var onVideoCached: ((URL) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer?.frame = bounds
    }
    
    @discardableResult
    func configure(url videoURL: URL) -> Bool {
        let videoPlayer = AVPlayer(url: videoURL)
        let videoPlayerLayer = AVPlayerLayer(player: videoPlayer)
        videoPlayerLayer.frame = bounds
        videoPlayerLayer.videoGravity = videoGravity
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
        didStartPlayingTimeObserver = videoPlayer.addBoundaryTimeObserver(
            forTimes: [NSValue(time: CMTimeMake(value: 1, timescale: 1000))],
            queue: nil,
            using: { [weak self] in
                self?.onStart?(self)
                if let observer = self?.didStartPlayingTimeObserver {
                    self?.player?.removeTimeObserver(observer)
                }
                self?.didStartPlayingTimeObserver = nil
        })
        
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
        onStart = nil
        player = nil
        playerLayer = nil
        unregisterBroadcastObserversWith(pairs:
            pairWith(first: NSNotification.Name.AVPlayerItemDidPlayToEndTime, second: didPlayToEndTimeObserver)
        )
        onVideoCached = nil
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
    func onVideoCached(_ block: @escaping (URL) -> Void) -> VideoView {
        onVideoCached = block
        return self
    }
    
    @discardableResult
    func tryToCacheVideo() -> VideoView {
        guard isCachingEnabled,
            !cacheFileName.isEmpty,
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
        let outputURL = cacheDirectory.appendingPathComponent(cacheFileName)
        if fileManager.isDeletableFile(atPath: outputURL.path) {
            try? fileManager.removeItem(at: outputURL)
        }
        exporter.outputURL = outputURL
        exporter.outputFileType = fileType
        exporter.exportAsynchronously { [weak self] in
            guard exporter.status == .completed,
                exporter.error == nil else {
                return
            }
            self?.onVideoCached?(outputURL)
        }
        return self
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
func addCachedVideo(with key: String, url: URL) -> Bool {
    videoCacheURLs[key] = url
    return true
}

@discardableResult
func urlOfCachedVideo(for key: String) -> URL? {
    return videoCacheURLs[key]
}
