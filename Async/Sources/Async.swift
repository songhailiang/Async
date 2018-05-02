//
//  Async.swift
//  Async
//
//  Created by songhailiang on 2018/4/28.
//  Copyright © 2018 songhailiang. All rights reserved.
//

import Foundation

/// More easier to use GCD
public struct Async {

    private let job: DispatchWorkItem
    private init(work: DispatchWorkItem) {
        job = work
    }

    /// execute a block async on main queue
    ///
    /// - Parameters:
    ///   - seconds: delay seconds
    ///   - block: the block need to be executed
    /// - Returns: An `Async` struct
    @discardableResult
    public static func main(after seconds: Double? = nil, _ block: @escaping () -> Void) -> Async {
        return async(after: seconds, block: block, queue: .main)
    }

    /// execute a block async on global queue
    ///
    /// - Parameters:
    ///   - seconds: delay seconds
    ///   - block: the block need to be executed
    /// - Returns: An `Async` struct
    @discardableResult
    public static func global(after seconds: Double? = nil, _ block: @escaping () -> Void) -> Async {
        return async(after: seconds, block: block, queue: .global())
    }

    /// execute a block async on a custom queue
    ///
    /// - Parameters:
    ///   - seconds: delay seconds
    ///   - block: the block need to be executed
    /// - Returns: An `Async` struct
    @discardableResult
    public static func custom(label: String, after seconds: Double? = nil, _ block: @escaping () -> Void) -> Async {
        let queue = DispatchQueue(label: label, attributes: [.concurrent])
        return async(after: seconds, block: block, queue: queue)
    }

    private static func async(after seconds: Double? = nil, block: @escaping () -> Void, queue: DispatchQueue) -> Async {
        let work = DispatchWorkItem(block: block)
        if let seconds = seconds {
            queue.asyncAfter(deadline: .now() + seconds, execute: work)
        } else {
            queue.async(execute: work)
        }
        return Async(work: work)
    }

    /// execute a block async on main queue, after the current block has finished.
    ///
    /// - Parameters:
    ///   - seconds: delay seconds
    ///   - block: the block need to be executed
    /// - Returns: An `Async` struct
    @discardableResult
    public func main(after seconds: Double? = nil, _ block: @escaping () -> Void) -> Async {
        return chain(after: seconds, block: block, queue: .main)
    }

    /// execute a block async on global queue, after the current block has finished.
    ///
    /// - Parameters:
    ///   - seconds: delay seconds
    ///   - block: the block need to be executed
    /// - Returns: An `Async` struct
    @discardableResult
    public func global(after seconds: Double? = nil, _ block: @escaping () -> Void) -> Async {
        return chain(after: seconds, block: block, queue: .global())
    }

    /// execute a block async on an custom queue, after the current block has finished.
    ///
    /// - Parameters:
    ///   - seconds: delay seconds
    ///   - block: the block need to be executed
    /// - Returns: An `Async` struct
    @discardableResult
    public func custom(label: String, after seconds: Double? = nil, _ block: @escaping () -> Void) -> Async {
        let queue = DispatchQueue(label: label, attributes: [.concurrent])
        return chain(after: seconds, block: block, queue: queue)
    }

    /// Cancel the current block, if it hasn't already begun running to GCD
    public func cancel() {
        job.cancel()
    }

    private func chain(after seconds: Double? = nil, block: @escaping () -> Void, queue: DispatchQueue) -> Async {
        let work = DispatchWorkItem(block: block)
        if let seconds = seconds {
            job.notify(queue: queue, execute: {
                queue.asyncAfter(deadline: .now() + seconds, execute: work)
            })
        } else {
            job.notify(queue: queue, execute: work)
        }
        return Async(work: work)
    }
}

public struct AsyncGroup {

    public struct AsyncGroupJob {
        private var group: DispatchGroup?
        fileprivate init(group: DispatchGroup) {
            self.group = group
        }

        public func finish() {
            self.group?.leave()
        }
    }

    var group: DispatchGroup

    public init() {
        group = DispatchGroup()
    }

    /// when all async jobs are finished, the block will be called.
    ///
    /// - Parameter block: the block that needs to be executed
    public func finished(_ block: @escaping () -> Void) {
        group.notify(queue: .main, execute: {
            block()
        })
    }

    /// start an async job, need to call job.finish() when the job finished.
    /// e.g.
    /// group.start { (job) in
    ///     Async.main(after: 3, {
    ///         job.finish()
    ///     })
    /// }
    ///
    /// - Parameter block: the block that needs to be executed
    public func start(_ block: @escaping (AsyncGroupJob) -> Void) {
        let job = AsyncGroupJob(group: group)
        let work = {
            block(job)
        }
        self.group.enter()
        async(block: work, queue: .main)
    }

    private func async(block: @escaping () -> Void, queue: DispatchQueue) {
        queue.async(group: group, execute: block)
    }
}

