//
//  Promise.swift
//  Peekr
//
//  Created by Mounir Ybanez on 9/28/19.
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

enum State<Value> {
    
    case pending
    case resolved(Value)
    case rejected(Error)
}

class Promise<Value>: Any {
    
    typealias ResolveAction = (Value) -> Void
    typealias RejectAction = (Error) -> Void
    typealias WorkAction = (@escaping ResolveAction, @escaping RejectAction) throws -> Void
    
    var state: State<Value>
    var executors: [Executor<Value>] = []
    
    let lock = DispatchQueue(label: "com.nir.Peekr.Promise.lock.queue", qos: .userInitiated)
    
    init(queue: DispatchQueue = .main, _ action: @escaping WorkAction) {
        self.state = .pending
        queue.async {
            do {
                try action(self.resolve, self.reject)
            } catch {
                self.reject(error)
            }
        }
    }
    
    @discardableResult
    func then(on queue: DispatchQueue = .main, _ resolution: @escaping ResolveAction) -> Promise<Value> {
        return then(on: queue, resolution, { _ in })
    }
    
    @discardableResult
    func then<NewValue>(on queue: DispatchQueue = .main, _ resolution: @escaping (Value) throws -> NewValue) -> Promise<NewValue> {
        return Promise<NewValue> { resolve, reject in
            self.then(on: queue, { value in
                do {
                    resolve(try resolution(value))
                } catch {
                    reject(error)
                }
            }, reject)
        }
    }
    
    @discardableResult
    func then<NewValue>(on queue: DispatchQueue = .main, _ resolution: @escaping (Value) throws -> Promise<NewValue>) -> Promise<NewValue> {
        return Promise<NewValue> { resolve, reject in
            self.then(on: queue, { value in
                do {
                    try resolution(value).then(on: queue, resolve, reject)
                } catch {
                    reject(error)
                }
            }, reject)
        }
    }
    
    @discardableResult
    func then(on queue: DispatchQueue = .main, _ resolution: @escaping ResolveAction, _ rejection: @escaping RejectAction) -> Promise<Value> {
        registerExecutor(on: queue, resolution, rejection)
        return self
    }
    
    @discardableResult
    func `catch`(on queue: DispatchQueue = .main, _ rejection: @escaping RejectAction) -> Promise<Value> {
        registerExecutor(on: queue, { _ in }, rejection)
        return self
    }
    
    func registerExecutor(on queue: DispatchQueue, _ resolution: @escaping ResolveAction, _ rejection: @escaping RejectAction) {
        lock.async {
            self.executors.append(
                Executor(
                    queue: queue,
                    resolution: resolution,
                    rejection: rejection,
                    completion: self.fireActions
                )
            )
        }
        fireActions()
    }
    
    func resolve(_ value: Value) {
        updateState(to: .resolved(value))
    }
    
    func reject(_ error: Error) {
        updateState(to: .rejected(error))
    }
    
    func updateState(to newState: State<Value>) {
        switch state {
        case .pending:
            lock.sync {
                state = newState
            }
            fireActions()
            
        default:
            break
        }
    }
    
    func fireActions() {
        lock.async {
            switch self.state {
            case let .resolved(value) where !self.executors.isEmpty:
                let executor = self.executors.removeFirst()
                executor.executeResolution(value)
                
            case let .rejected(error) where !self.executors.isEmpty:
                let executor = self.executors.removeFirst()
                executor.executeRejection(error)
                
            default:
                break
            }
        }
    }
}
