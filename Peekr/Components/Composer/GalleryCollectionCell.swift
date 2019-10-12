//
//  GalleryCollectionCell.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/7/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

class GalleryCollectionCell: UICollectionViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var selectedOverlayView: UIView!
    
    @discardableResult
    func configure(isSelected: Bool) -> Bool {
        selectedOverlayView.isHidden = !isSelected
        return true
    }
}
