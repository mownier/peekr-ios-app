//
//  State.swift
//  Pangako
//
//  Created by Mounir Ybanez on 2/14/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import Foundation

enum State<Value> {
    
    case pending
    case resolved(Value)
    case rejected(Error)
}
