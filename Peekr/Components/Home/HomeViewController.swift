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
    @IBOutlet weak var composerButton: UIButton!
    
    var tabBarItems: [TabBarItem] = []
    
    private var tabBarData: [Pair<UIButton, UIViewController>] = []
    private var currentPageIndex: Int = -1
    
    var postComposerUpdateScreenObserver: NSObjectProtocol? = nil
    var resultOfSharingPostObserver: NSObjectProtocol? = nil
    var signOutObserver: NSObjectProtocol? = nil
    
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

        postComposerUpdateScreenObserver = registerBroadcastObserverWith(
            name: PostComposerViewController.shareNotification,
            action: shareNotificationAction
        )
        
        resultOfSharingPostObserver = registerBroadcastObserverWith(
            name: PostComposerUpdateScreen.resultOfSharingPostNotification,
            action: resultOfSharingPostAction
        )
        
        signOutObserver = registerBroadcastObserverWith(
            name: MyProfileViewController.signOutConfirmationNotification,
            action: signOutConfirmationAction
        )
        
        composerButton.layer.cornerRadius = composerButton.frame.width / 2
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.backgroundColor = Colors.gray1
        pagingController?.view.backgroundColor = Colors.gray2
        pagingController?.dataSource = self
        pagingController?.delegate = self
        performButton(tabBarData.first?.first)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTapAvatar))
        tap.numberOfTapsRequired = 1
        avatarImageView.addGestureRecognizer(tap)
        avatarImageView.isUserInteractionEnabled = true
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
    
    @IBAction func onTapComposerButton() {
        broadcastWith(name: HomeViewController.showComposeScreenNotification, info: self)
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
    private func onTapAvatar() {
        broadcastWith(name: HomeViewController.showMyProfileScreenNotification, info: self)
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
    
    func shareNotificationAction(_ triple: Triple<PostComposerViewController, String, Pair<URL, URL>>) -> Bool {
        let screen = createPostComposerUpdateScreen()
            .setMessageText(triple.second)
            .setImageURL(triple.third.first)
            .setVideoURL(triple.third.second)
        
        addChild(screen)
        screen.didMove(toParent: self)
        view.addSubview(screen.view)
        
        screen.view.frame = view.bounds
        screen.view.frame.origin.y = tabBarView.frame.maxY
        screen.view.frame.size.height = 84
        
        return true
    }
    
    func resultOfSharingPostAction(_ pair: Pair<PostComposerUpdateScreen, Result<Post>>) {
        guard let screen = children.first(where: { $0 is PostComposerUpdateScreen}) as? PostComposerUpdateScreen else {
            return
        }
        screen.view.removeFromSuperview()
        screen.removeFromParent()
        screen.didMove(toParent: nil)
    }
    
    func signOutConfirmationAction(screen: MyProfileViewController) -> Bool {
        unregisterBroadcastObserversWith(pairs:
            pairWith(first: PostComposerViewController.shareNotification, second: postComposerUpdateScreenObserver),
            pairWith(first: PostComposerUpdateScreen.resultOfSharingPostNotification, second: resultOfSharingPostObserver),
            pairWith(first: MyProfileViewController.signOutConfirmationNotification, second: signOutObserver)
        )
        return true
    }
    
    struct TabBarItem {
        
        let selectedImageName: String
        let defaultImageName: String
        let screen: (HomeViewController) -> UIViewController
    }
    
    static let showMyProfileScreenNotification = Notification.Name(rawValue: HomeStrings.showMyProfileScreenNotificationRawName)
    static let showComposeScreenNotification = Notification.Name(rawValue: HomeStrings.showComposeScreenNotificationRawName)
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
