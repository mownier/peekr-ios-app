//
//  UserTableCell.swift
//  Peekr
//
//  Created by Mounir Ybanez on 2/8/20.
//  Copyright © 2020 Nir. All rights reserved.
//

import UIKit

class UserTableCell: UITableViewCell {

    @discardableResult
    func update(withItem item: DisplayItem) -> UserTableCell {
        textLabel?.text = item.displayName
        return self
    }
    
    struct DisplayItem {
        
        let id: String
        let avatar: String
        let displayName: String
        
        init(
            id: String = "",
            displayName: String = "",
            avatar: String = ""
        ) {
            self.id = id
            self.displayName = displayName
            self.avatar = avatar
        }
    }
}
