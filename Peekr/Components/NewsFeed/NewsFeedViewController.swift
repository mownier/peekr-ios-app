//
//  NewsFeedViewController.swift
//  Peekr
//
//  Created by Mounir Ybanez on 11/9/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import UIKit
import Nuke

public class NewsFeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewCenterReferenceView: UIView!
    
    var data: Pair<Set<User>, [Post]> = pairWith(first: [], second: [])
    var indexOfCurrentPlayingVideo: Int = 0
    
    public override func loadView() {
        super.loadView()
        
        tableView.register(UINib(nibName: "PostTableCell", bundle: nil), forCellReuseIdentifier: "PostTableCell")
        tableView.tableFooterView = UIView()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        getNewsFeed { [unowned self] result in
            switch result {
            case let .okay(info):
                self.data = info
            default:
                break
            }
            self.tableView.reloadData()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tableView
            .visibleCells
            .compactMap({ $0 as? PostTableCell })
            .forEach({ $0.videoView.sanitize() })
    }
}

extension NewsFeedViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.second.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableCell") as! PostTableCell
        let post = data.second[indexPath.row]
        if let date = post.createdOn {
            cell.timeLabel.text = "\(date)"
        } else {
            cell.timeLabel.text = " "
        }
        cell.messageLabel.text = post.message
        if let user = data.first.filter({ $0.id == post.authorID }).first {
            cell.displayNameLabel.text = user.username
        }
        cell.cardBackgroundViewTopConstraint.constant = indexPath.row == 0 ? 8 : 0
        if let url = URL(string: post.thumbnail.downloadURLString) {
            Nuke.loadImage(with: url, into: cell.previewImageView)
        }
        cell.videoView.isHidden = true
        if indexOfCurrentPlayingVideo == indexPath.row,
            let url = urlOfCachedVideo(for: post.video.id) ?? URL(string: post.video.downloadURLString) {
            cell.videoView.onStart = { view in
                guard cell.videoView == view else {
                    return
                }
                view?.isHidden = false
            }
            cell.videoView.configure(url: url)
            cell.videoView.play()
            
        } else {
            cell.videoView.sanitize()
        }
        cell.adjustVideoContainerSizeRelative(to:
            CGSize(
                width: CGFloat(post.video.width),
                height: CGFloat(post.video.height)
            )
        )
        cell.videoView
            .cacheVideoFileKey(post.video.id)
            .cacheFileName("\(post.video.id).mp4")
            .cacheVideoFileType(.mp4)
        return cell
    }
}

extension NewsFeedViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as? PostTableCell
        cell?.videoView.isHidden = true
        cell?.videoView.sanitize()
    }
}

extension NewsFeedViewController: UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let point = view.convert(tableViewCenterReferenceView.frame.origin, to: tableView)
        guard let indexPathAtCenter = tableView.indexPathForRow(at: point),
            indexOfCurrentPlayingVideo != indexPathAtCenter.row else {
                return
        }
        let currentIndexPath = IndexPath(row: indexOfCurrentPlayingVideo, section: 0)
        indexOfCurrentPlayingVideo = indexPathAtCenter.row
        UIView.setAnimationsEnabled(false)
        tableView.reloadRows(at: [currentIndexPath, indexPathAtCenter], with: .none)
        UIView.setAnimationsEnabled(true)
    }
}

public func createNewsFeedViewController() -> NewsFeedViewController {
    let screen: NewsFeedViewController = viewControllerFromStoryboardWith(name: "NewsFeed")
    return screen
}
