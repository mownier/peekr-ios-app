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
        let manager = PHCachingImageManager()
        manager.requestAVAsset(forVideo: asset, options: nil) { videoAsset, _, _ in
            guard let sourceAsset = videoAsset as? AVURLAsset else {
                return
            }
            
            let duration: Double
            if sourceAsset.duration.seconds >= durationLimit {
                duration = durationLimit
                
            } else {
                duration = sourceAsset.duration.seconds
            }
            
            guard duration > 0 else {
                return
            }
            
            let thumbnailURL = saveImageToCacheDirectory(frameGrab(for: sourceAsset, startTime: duration / 2.0))
            uploadImage(with: thumbnailURL, track: { progress in
                print("uploading image with progress:", String(describing: progress))
            
            }).then({ imageFile -> Promise<URL> in
                print("imageFile:", imageFile)
                print("cropping video...")
                let videoURL = outputURLOfCroppedVideo()
                return cropVideo(with: sourceAsset, outputURL: videoURL, end: duration)
            
            }).then({ videoURL -> Promise<VideoFile> in
                return uploadVideo(with: videoURL, track: { progress in
                    print("uploading video with progress:", String(describing: progress))
                })
                
            }).then({ videoFile -> Void in
                print("videoFile:", videoFile)
                
            }).catch({ error -> Void in
                print(error)
            })
        }
    }
    
    static let shareNotification = Notification.Name(rawValue: ComposerStrings.shareNotificationRawName)
    static let cancelComposingNotification = Notification.Name(rawValue: ComposerStrings.cancelComposingNotificationRawName)
}

private func frameGrab(for asset: AVAsset, startTime: Float64 = 3, location: Int32 = 1) -> UIImage? {
    let generator = AVAssetImageGenerator(asset: asset)
    let time = CMTimeMakeWithSeconds(startTime, preferredTimescale: location)
    do {
        let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
        return UIImage(cgImage: cgImage)
        
    } catch {
        return nil
    }
}

private func saveImage(_ image: UIImage?, to directory: URL?, with name: String = "\(Date().timeIntervalSince1970).jpg") -> URL? {
    guard image != nil, directory != nil else {
        return nil
    }
    
    let fileManager = FileManager.default
    
    if !fileManager.fileExists(atPath: directory!.path) {
        do {
            try fileManager.createDirectory(at: directory!, withIntermediateDirectories: true, attributes: nil)
            
        } catch {
            return nil
        }
    }
    
    let fileURL = directory!.appendingPathComponent(name)
    
    if fileManager.createFile(
        atPath: fileURL.path,
        contents: UIImage.jpegData(image!)(compressionQuality: 0.9),
        attributes: nil) {
        return fileURL
    }
    
    return nil
}

private func saveImageToCacheDirectory(_ image: UIImage?) -> URL? {
    let fileManager = FileManager.default
    let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
    return saveImage(image, to: cacheDirectory)
}

private func cropVideo(with asset: AVAsset?, outputURL: URL?, start: Double = 0.0, end: Double = durationLimit) -> Promise<URL> {
    return Promise(queue: uploadQueue) { resolve, reject in
        guard asset != nil, let outputURL = outputURL,
            let exportSession = AVAssetExportSession(
                asset: asset!,
                presetName: AVAssetExportPresetHighestQuality) else {
                    reject(coreError(message: "Can not create an export session"))
                    return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        
        let startTime = CMTime(seconds: start, preferredTimescale: 1000)
        let endTime = CMTime(seconds: end, preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously{
            switch exportSession.status {
            case .completed:
                resolve(outputURL)
                
            case .failed, .cancelled:
                reject(coreError(message: "Exporting failed or cancelled"))
                
            default:
                break
            }
        }
    }
}

private func outputURLOfCroppedVideo(with name: String = "\(Date().timeIntervalSince1970).mp4", in directory: URL? = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first) -> URL? {
    guard directory != nil, !name.isEmpty else {
        return nil
    }
    
    let fileManager = FileManager.default
    
    if !fileManager.fileExists(atPath: directory!.path) {
        do {
            try fileManager.createDirectory(at: directory!, withIntermediateDirectories: true, attributes: nil)
            
        } catch {
            return nil
        }
    }
    
    return directory!.appendingPathComponent(name)
}

private func uploadImage(with url: URL?, track: @escaping (Progress?) -> Void) -> Promise<ImageFile> {
    return Promise(queue: uploadQueue) { resolve, reject in
        uploadJPEGImage(with: url, track: track, completion: { result in
            switch result {
            case let .notOkay(error):
                reject(error)
            
            case let .okay(file):
                resolve(file)
            }
        })
    }
}

private func uploadVideo(with url: URL?, track: @escaping (Progress?) -> Void) -> Promise<VideoFile> {
    return Promise(queue: uploadQueue) { resolve, reject in
        uploadMP4Video(with: url, track: track, completion: { result in
            switch result {
            case let .notOkay(error):
                reject(error)
                
            case let .okay(file):
                resolve(file)
            }
        })
    }
}

private let durationLimit: Double = 20 // 20 seconds
private var uploadQueue: DispatchQueue = {
    return DispatchQueue(label: "com.nir.Peekr.uploadQueue")
}()
