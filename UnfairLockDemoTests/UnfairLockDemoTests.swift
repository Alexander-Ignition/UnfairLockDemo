//
//  UnfairLockDemoTests.swift
//  UnfairLockDemoTests
//
//  Created by Alexander Ignition on 23.10.2024.
//

import XCTest
@testable import UnfairLockDemo

final class UnfairLockDemoTests: XCTestCase {
    private let iterations = 10_000

    func testStateWithLock() {
        let counter = WBAllocatedUnfairLock(uncheckedState: 0)

        DispatchQueue.concurrentPerform(iterations: iterations) { i in
            counter.withLock { $0 += 1 }
        }
        XCTAssertEqual(counter.withLock { $0 }, iterations)
    }

    func testStateWithLock2() {
        let counter = WBAllocatedUnfairLock(uncheckedState: 0)

        DispatchQueue.concurrentPerform(iterations: iterations) { i in
            counter.withLock { $0 += 1 }
        }
        XCTAssertEqual(counter.withLock { $0 }, iterations)
    }
}
