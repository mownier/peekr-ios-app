//
//  Executor.swift
//  Pangako
//
//  Created by Mounir Ybanez on 2/14/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import Foundation

struct Executor<Value> {
    
    let queue: DispatchQueue
    let resolution: (Value) -> Void
    let rejection: (Error) -> Void
    let completion: () -> Void
    
    func executeResolution(_ value: Value) {
        queue.async {
            self.resolution(value)
            self.completion()
        }
    }
    
    func executeRejection(_ error: Error) {
        queue.async {
            self.rejection(error)
            self.completion()
        }
    }
}
