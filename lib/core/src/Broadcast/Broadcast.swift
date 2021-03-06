//
//  Broadcast.swift
//  Peekr
//
//  Created by Mounir Ybanez on 8/28/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import Foundation

let broadcastCenter = NotificationCenter.default

@discardableResult
public func broadcastWith<T>(name: Notification.Name, info: T) -> Bool {
    let userInfo = [CoreStrings.broadcastInfoKey: info]
    broadcastCenter.post(name: name, object: nil, userInfo: userInfo)
    return true
}

public func registerBroadcastObserverWith<T, R>(name: Notification.Name, action: @escaping (T) -> R) -> NSObjectProtocol? {
    return broadcastCenter.addObserver(forName: name, object: nil, queue: nil) { notif in
        let info = notif.userInfo?[CoreStrings.broadcastInfoKey] as? T
        if let data = info {
            let _ = action(data)
            return
        }
        
        if T.self == Void.self {
            let data: Void
            let _ = action(data as! T)
        }
    }
}

@discardableResult
public func broadcastWith(name: Notification.Name) -> Bool {
    broadcastCenter.post(name: name, object: nil, userInfo: nil)
    return true
}

@discardableResult
public func unregisterBroadcastObserversWith(pairs: Pair<Notification.Name, NSObjectProtocol?>...) -> Bool {
    guard !pairs.isEmpty else {
        return false
    }
    return !pairs.compactMap({ item -> Pair<Notification.Name, NSObjectProtocol>? in
        guard let observer = item.second else {
            return nil
        }
        return pairWith(first: item.first, second: observer)
        
    }).map({ pair -> Bool in
        broadcastCenter.removeObserver(pair.second, name: pair.first, object: nil)
        return true
        
    }).isEmpty
}
