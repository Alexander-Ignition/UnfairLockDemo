//
//  WBAllocatedUnfairLock.swift
//  UnfairLockDemo
//
//  Created by Alexander Ignition on 20.10.2024.
//

import Foundation

public struct WBAllocatedUnfairLock<State>: @unchecked Sendable {

    private let buffer: ManagedBuffer<State, os_unfair_lock>

    public init(uncheckedState initialState: State) {
        buffer = .create(minimumCapacity: 1, makingHeaderWith: { buffer in
            buffer.withUnsafeMutablePointerToElements { lock in
                lock.initialize(to: os_unfair_lock())
            }
            return initialState
        })
    }

    public func withLockUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R {
        try buffer.withUnsafeMutablePointers { state, lock in
            os_unfair_lock_lock(lock)
            defer {
                os_unfair_lock_unlock(lock)
            }
            return try body(&state.pointee)
        }
    }

    public func withLock<R>(
        _ body: @Sendable (inout State) throws -> R
    ) rethrows -> R where R : Sendable {
        try withLockUnchecked(body)
    }
}
