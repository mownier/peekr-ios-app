//
//  GalleryViewController.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/7/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit
import Photos

class GalleryViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    private var flowLayout: UICollectionViewFlowLayout!
    private var assetFetchResult: PHFetchResult<PHAsset>?
    
    private var assets: [PHAsset] = []
    private var selectedRow: Int = -1
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        videoView.sanitize()
    }
    
    override func loadView() {
        super.loadView()
        
        collectionView.collectionViewLayout.invalidateLayout()
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset.top = 2
        flowLayout.configureWith(width: view.bounds.width, columnCount: 4, columnSpacing: 0.5, rowSpacing: 2)
        collectionView.collectionViewLayout = flowLayout
        
        PHPhotoLibrary.shared().register(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoView.isLoopEnabled = true
        
        doneButton.setTitle(ComposerStrings.next, for: .normal)
        titleButton.setTitle(ComposerStrings.gallery, for: .normal)
        
        fetchVideosFromGallery { result in
            self.assets = result.toList()
            self.assetFetchResult = result
            self.collectionView.reloadData()
            self.selectAt(row: 0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        if (0..<assets.count).contains(selectedRow) {
            videoView.play()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        videoView.pause()
    }
    
    @IBAction func onTapCloseButton() {
        broadcastWith(name: GalleryViewController.dismissNotification, info: self)
    }
    
    @IBAction func onTapTitleButton() {
        
    }
    
    @IBAction func onTapDoneButton() {
        guard let asset = assetAt(selectedRow) else {
            return
        }
        
        broadcastWith(name: GalleryViewController.doneNotification, info: pairWith(first: self, second: asset))
    }
    
    @discardableResult
    private func selectAt(row: Int) -> Bool {
        guard !assets.isEmpty, (0..<assets.count).contains(row) else {
            return false
        }
        
        let asset = assets[row]
        videoView.playVideoFor(asset: asset)
        selectedRow = row
        collectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
        
        return true
    }
    
    private func assetAt(_ index: Int) -> PHAsset? {
        guard (0..<assets.count).contains(index) else {
            return nil
        }
        
        return assets[index]
    }
    
    static let doneNotification = Notification.Name(rawValue: ComposerStrings.doneNotificationRawName)
    static let dismissNotification = Notification.Name(rawValue: ComposerStrings.dismissNotificationRawName) 
}

extension GalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! GalleryCollectionCell
        let asset = assets[indexPath.row]
        cell.thumbnailImageView.setImageFor(asset: asset)
        cell.configure(isSelected: indexPath.row == selectedRow)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedRow != indexPath.row else {
            return
        }
        
        let asset = assets[indexPath.row]
        videoView.playVideoFor(asset: asset)
        
        var refreshingItems = [indexPath]
        if selectedRow > -1 {
            refreshingItems.append(IndexPath(row: selectedRow, section: 0))
        }
        selectedRow = indexPath.row
        collectionView.reloadItems(at: refreshingItems)
    }
}

extension GalleryViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            guard let result = assetFetchResult,
                let details = changeInstance.changeDetails(for: result) else {
                    return
            }
            
            assets = details.fetchResultAfterChanges.toList()
            assetFetchResult = details.fetchResultAfterChanges
            collectionView.reloadData()
        }
    }
}

extension UICollectionViewFlowLayout {
    
    fileprivate func configureWith(width: CGFloat, columnCount: Int, columnSpacing: CGFloat = 0.25, rowSpacing: CGFloat = 1.0) {
        let totalColumnSpacing = columnSpacing * CGFloat((columnCount - 1))
        let side = (width / CGFloat(columnCount)) - totalColumnSpacing
        itemSize = CGSize(width: side, height: side)
        minimumInteritemSpacing = columnSpacing
        minimumLineSpacing = rowSpacing
    }
}

extension PHFetchResult where ObjectType == PHAsset {
    
    fileprivate func toList() -> [PHAsset] {
        var assets = [PHAsset]()
        enumerateObjects { (asset, _, _) in
            assets.append(asset)
        }
        return assets
    }
}

extension UIImageView {
    
    @discardableResult
    fileprivate func setImageFor(asset: PHAsset?) -> Bool {
        guard asset != nil else {
            return false
        }
        
        fetchVideoThumbnailFor(asset: asset!, size: bounds.size) { image in
            self.image = image
        }
        
        return true
    }
}

extension VideoView {
    
    @discardableResult
    fileprivate func playVideoFor(asset: PHAsset?) -> Bool {
        guard asset != nil else {
            return false
        }
        
        let manager = PHCachingImageManager()
        manager.requestAVAsset(forVideo: asset!, options: nil) { videoAsset, _, _ in
            guard let url = (videoAsset as? AVURLAsset)?.url else {
                return
            }
            
            DispatchQueue.main.async {
                self.configure(url: url)
                self.play()
            }
        }
        
        return true
    }
}

private func fetchVideosFromGallery(completion: @escaping (PHFetchResult<PHAsset>) -> Void) {
    DispatchQueue.main.async {
        let result = PHAsset.fetchAssets(with: .video, options: nil)
        completion(result)
    }
}

private func fetchVideoThumbnailFor(
    asset: PHAsset,
    size: CGSize = .zero,
    mode: PHImageContentMode = .`default`,
    options: PHImageRequestOptions? = nil,
    completion: @escaping (UIImage?) -> Void
) {
    let manager = PHImageManager.default()
    manager.requestImage(
        for: asset,
        targetSize: size,
        contentMode: mode,
        options: options,
        resultHandler: { image, _ in
            completion(image)
    })
}
