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
    
    var data: Pair<Set<User>, [Post]> = pairWith(first: [], second: [])
    
    public override func loadView() {
        super.loadView()
        
        tableView.register(UINib(nibName: "PostTableCell", bundle: nil), forCellReuseIdentifier: "PostTableCell")
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
        return cell
    }
}

public func createNewsFeedViewController() -> NewsFeedViewController {
    let screen: NewsFeedViewController = viewControllerFromStoryboardWith(name: "NewsFeed")
    return screen
}
