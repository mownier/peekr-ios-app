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
        cell.updateImageOfSoundButtonWith(name: "icon-volume")
        cell.elapsedTimeLabel.text = formatPlayingTime(0.0)
        cell.elapsedTimeLabel.isHidden = true
        cell.soundButton.isHidden = true
        cell.videoView.isHidden = true
        if indexOfCurrentPlayingVideo == indexPath.row,
            let url = urlOfCachedVideo(for: post.video.id) ?? URL(string: post.video.downloadURLString) {
            if url.absoluteString == post.video.downloadURLString {
                cell.loadingView.startAnimating()
                
            } else {
                cell.loadingView.stopAnimating()
            }
            cell.videoView.onStart = { view in
                guard cell.videoView == view else {
                    return
                }
                cell.videoView.isHidden = false
                cell.loadingView.stopAnimating()
            }
            cell.videoView.onReadyToPlay = { _ in
                cell.elapsedTimeLabel.isHidden = false
                cell.soundButton.isHidden = false
                cell.elapsedTimeLabel.text = formatPlayingTime(0.0)
            }
            cell.videoView.configure(url: url)
            
        } else {
            cell.loadingView.stopAnimating()
            cell.videoView.sanitize()
        }
        cell.videoView.onRemainingTimeInSeconds = { _, seconds in
            cell.elapsedTimeLabel.text = formatPlayingTime(seconds)
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
        return cell.delegate(self)
    }
}

extension NewsFeedViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as? PostTableCell
        cell?.videoView.isHidden = true
        cell?.videoView.sanitize()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexOfCurrentPlayingVideo != indexPath.row else {
            return
        }
        let currentIndexPath = IndexPath(row: indexOfCurrentPlayingVideo, section: 0)
        indexOfCurrentPlayingVideo = indexPath.row
        UIView.setAnimationsEnabled(false)
        tableView.reloadRows(at: [currentIndexPath, indexPath], with: .none)
        UIView.setAnimationsEnabled(true)
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

extension NewsFeedViewController: PostTableCellDelegate {
    
    public func postTableCellOnMuted(_ cell: PostTableCell) {
        cell.updateImageOfSoundButtonWith(name: "icon-volume")
    }
    
    public func postTableCellOnUnmuted(_ cell: PostTableCell) {
        cell.updateImageOfSoundButtonWith(name: "icon-volume-high")
    }
}

public func createNewsFeedViewController() -> NewsFeedViewController {
    let screen: NewsFeedViewController = viewControllerFromStoryboardWith(name: "NewsFeed")
    return screen
}

func formatPlayingTime(_ seconds: Double) -> String {
    let time = seconds
    let h = (time / 3600.0).toInt()
    let m = ((time - Double(h) * 3600) / 60).toInt()
    let s = (time - Double(h * 3600 + m * 60)).toInt()
    
    let hourFormat: String
    if (h > 0) {
        if (h < 10) {
            hourFormat = "0\(h)"
        } else {
            hourFormat = "\(h)"
        }
        
    } else {
        hourFormat = ""
    }
    
    let minuteFormat: String
    if hourFormat.isEmpty || m >= 10 {
        minuteFormat = "\(m)"
    
    } else {
        minuteFormat = "0\(m)"
    }
    
    
    let secondFormat: String
    if s < 10 {
        secondFormat = "0\(s)"
        
    } else {
        secondFormat = "\(s)"
    }
    
    return [hourFormat, minuteFormat, secondFormat]
        .filter({ !$0.isEmpty })
        .joined(separator: ":")
}

extension Double {
    
    func toInt() -> Int {
        return (isInfinite || isNaN) ? 0 : Int(self)
    }
}
