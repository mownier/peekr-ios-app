//
//  Pangako.swift
//  Pangako
//
//  Created by Mounir Ybanez on 2/14/19.
//  Copyright © 2019 Nir. All rights reserved.
//

import Foundation

public final class Pangako<Value> {
    
    public typealias ResolveAction = (Value) -> Void
    public typealias RejectAction = (Error) -> Void
    public typealias WorkAction = (@escaping ResolveAction, @escaping RejectAction) throws -> Void
    
    var state: State<Value>
    var executors: [Executor<Value>] = []
    
    let lock = DispatchQueue(label: "com.nir.Pangako.lock.queue", qos: .userInitiated)
    
    public init(queue: DispatchQueue = .main, _ action: @escaping WorkAction) {
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
    public func then(on queue: DispatchQueue = .main, _ resolution: @escaping ResolveAction) -> Pangako<Value> {
        return then(on: queue, resolution, { _ in })
    }
    
    @discardableResult
    public func then<NewValue>(on queue: DispatchQueue = .main, _ resolution: @escaping (Value) throws -> NewValue) -> Pangako<NewValue> {
        return Pangako<NewValue> { resolve, reject in
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
    public func then<NewValue>(on queue: DispatchQueue = .main, _ resolution: @escaping (Value) throws -> Pangako<NewValue>) -> Pangako<NewValue> {
        return Pangako<NewValue> { resolve, reject in
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
    public func then(on queue: DispatchQueue = .main, _ resolution: @escaping ResolveAction, _ rejection: @escaping RejectAction) -> Pangako<Value> {
        registerExecutor(on: queue, resolution, rejection)
        return self
    }
    
    @discardableResult
    public func `catch`(on queue: DispatchQueue = .main, _ rejection: @escaping RejectAction) -> Pangako<Value> {
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
