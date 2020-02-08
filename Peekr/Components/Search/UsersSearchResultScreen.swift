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
    
    var data: [Int] = (0..<9).map({ $0 })
    
    override func loadView() {
        super.loadView()
        
        tableView.register(UINib(nibName: "UserTableCell", bundle: nil), forCellReuseIdentifier: "UserTableCell")
    }
}

extension UsersSearchResultScreen: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableCell") as! UserTableCell
        cell.textLabel?.text = "User \(data[indexPath.row])"
        return cell
    }
}

extension UsersSearchResultScreen: UITableViewDelegate {
    
}
