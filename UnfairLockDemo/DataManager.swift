//
//  DataManager.swift
//  UnfairLockDemo
//
//  Created by Alexander Ignition on 20.10.2024.
//

import Foundation
import os.lock

final class DataManager: Sendable {
//    private var cache: [String: Data] = [:]
//    private let lock = NSLock()
    private let lock = OSAllocatedUnfairLock<[String: Data]>(uncheckedState: [:])

    var count: Int {
        lock.withLock { cache in
            cache.count
        }
    }

    func save(_ data: Data, for key: String) {
        lock.withLock { cache in
            cache[key] = data
        }
    }

    func read(for key: String) -> Data? {
        lock.withLock { cache in
            cache[key]
        }
    }
}
