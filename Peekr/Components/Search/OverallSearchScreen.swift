//
//  OverallSearchScreen.swift
//  Peekr
//
//  Created by Mounir Ybanez on 2/8/20.
//  Copyright © 2020 Nir. All rights reserved.
//

import UIKit

class OverallSearchScreen: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contentContainerView: UIView!
    
    var contentView: ((OverallSearchScreen) -> UIView)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpContentView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentContainerView.subviews.forEach({
            $0.frame = contentContainerView.bounds
        })
    }
    
    @discardableResult
    func setContentView(_ block: @escaping (OverallSearchScreen) -> UIView) -> OverallSearchScreen {
        contentView = block
        guard isViewLoaded else {
            return self
        }
        setUpContentView()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        return self
    }
    
    @discardableResult
    private func setUpContentView() -> OverallSearchScreen {
        contentContainerView.subviews.forEach({ $0.removeFromSuperview() })
        if let subview = contentView?(self) {
            contentContainerView.addSubview(subview)
        }
        contentView = nil
        return self
    }
}
