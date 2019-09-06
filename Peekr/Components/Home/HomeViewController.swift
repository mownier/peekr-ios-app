//
//  HomeViewController.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/4/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tabBarView: UIView!
    
    var tabBarItems: [TabBarItem] = []
    
    private var tabBarData: [Pair<UIButton, UIViewController>] = []
    private var currentPageIndex: Int = -1
    
    override func loadView() {
        super.loadView()
        
        tabBarData = tabBarItems.map { item in
            let button = UIButton(frame: .zero)
            button.setImage(UIImage(named: item.defaultImageName), for: .normal)
            button.setImage(UIImage(named: item.selectedImageName), for: .selected)
            button.addTarget(self, action: #selector(onTapTabBarButton(_:)), for: .touchUpInside)
            return pairWith(first: button, second: item.screen(self))
        }
        
        tabBarData.forEach {
            tabBarView.addSubview($0.first)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        
        pagingController?.view.backgroundColor = UIColor(named: "Gray2")
        pagingController?.dataSource = self
        pagingController?.delegate = self
        performButton(tabBarData.first?.first)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let tabBarButtonSize = CGSize(
            width: tabBarView.bounds.width / CGFloat(tabBarData.count) ,
            height: tabBarView.bounds.height
        )
        tabBarData.enumerated().forEach { item in
            let tabBarButtonOrigin = CGPoint(x: CGFloat(item.offset) * tabBarButtonSize.width, y: 0)
            item.element.first.frame = CGRect(origin: tabBarButtonOrigin, size: tabBarButtonSize)
        }
    }
    
    private var pagingController: HomePagingViewController? {
        return children.first(where: { $0 is HomePagingViewController }) as? HomePagingViewController
    }
    
    private func pagingNavigationDirectionWith(nextIndex: Int) -> UIPageViewController.NavigationDirection {
        if nextIndex > currentPageIndex {
            return .forward
        }
        return .reverse
    }
    
    @objc
    private func onTapTabBarButton(_ button: UIButton) {
        performButton(button)
    }
    
    @discardableResult
    private func makeButtonAsSelected(_ button: UIButton) -> Bool {
        tabBarData.forEach { item in
            item.first.isSelected = button == item.first
        }
        return true
    }
    
    @discardableResult
    private func performButton(_ target: UIButton?) -> Bool {
        guard let button = target else {
            return false
        }
        
        makeButtonAsSelected(button)
        
        guard let index = tabBarData.firstIndex(where: { $0.first == button }) else {
            return false
        }
        
        let direction = pagingNavigationDirectionWith(nextIndex: index)
        let screen = tabBarData[index].second
        pagingController?.setViewControllers([screen], direction: direction, animated: true, completion: nil)

        currentPageIndex = index
        
        return true
    }
    
    struct TabBarItem {
        
        let selectedImageName: String
        let defaultImageName: String
        let screen: (HomeViewController) -> UIViewController
    }
}

extension HomeViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let tabBarDataIndex = tabBarData.firstIndex(where: { $0.second == viewController }) else {
            return nil
        }
        
        let previousIndex = tabBarDataIndex - 1
        
        guard previousIndex >= 0, tabBarData.count > previousIndex else {
            return nil
        }
        
        return tabBarData[previousIndex].second
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let tabBarDataIndex = tabBarData.firstIndex(where: { $0.second == viewController }) else {
            return nil
        }
        
        let nextIndex = tabBarDataIndex + 1
        
        guard nextIndex < tabBarData.count, tabBarData.count > nextIndex else {
            return nil
        }
        
        return tabBarData[nextIndex].second
    }
}

extension HomeViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let index = tabBarData.firstIndex(where: { $0.second == pendingViewControllers.last }) else {
            return
        }
        
        currentPageIndex = index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let index = tabBarData.firstIndex(where: { $0.second == previousViewControllers.last }) else {
            return
        }
        
        if !completed {
            currentPageIndex = index
        }
        
        makeButtonAsSelected(tabBarData[currentPageIndex].first)
    }
}
