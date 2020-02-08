//
//  UsersSearchResultScreen.swift
//  Peekr
//
//  Created by Mounir Ybanez on 2/8/20.
//  Copyright © 2020 Nir. All rights reserved.
//

import UIKit

class UsersSearchResultScreen: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var displayItems: [UserTableCell.DisplayItem] = []
    
    override func loadView() {
        super.loadView()
        
        tableView.register(UINib(nibName: "UserTableCell", bundle: nil), forCellReuseIdentifier: "UserTableCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reload()
    }
    
    @discardableResult
    func displayItems(_ items: [UserTableCell.DisplayItem]) -> UsersSearchResultScreen {
        displayItems = items
        return self
    }
    
    @discardableResult
    func reload() -> UsersSearchResultScreen {
        tableView?.reloadData()
        tableView?.backgroundView = displayItems.isEmpty ? {
            let label = UILabel()
            label.textAlignment = .center
            label.text = "No search result"
            return label
        }() : nil
        return self
    }
}

extension UsersSearchResultScreen: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell") as! UserTableCell
        return cell.update(withItem: displayItems[indexPath.row])
    }
}

extension UsersSearchResultScreen: UITableViewDelegate {
    
}
