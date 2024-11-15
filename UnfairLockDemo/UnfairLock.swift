//
//  UnfairLock.swift
//  UnfairLockDemo
//
//  Created by Alexander Ignition on 20.10.2024.
//

import os.lock

final class UnfairLock {
    private let pointer: os_unfair_lock_t // UnsafeMutablePointer<os_unfair_lock_s>

    init() {
        pointer = .allocate(capacity: 1)
        pointer.initialize(to: os_unfair_lock())
    }

    deinit {
        pointer.deinitialize(count: 1)
        pointer.deallocate()
    }

    func lock() { 
        os_unfair_lock_lock(pointer)
    }

    func unlock() {
        os_unfair_lock_unlock(pointer)
    }
}
