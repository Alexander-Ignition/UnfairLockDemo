//
//  DataManagerTests.swift
//  UnfairLockDemoTests
//
//  Created by Alexander Ignition on 24.10.2024.
//

import XCTest
@testable import UnfairLockDemo

final class DataManagerTests: XCTestCase {
    private let iterations = 10

    func testSave() {
        let dataManager = DataManager()

        DispatchQueue.concurrentPerform(iterations: iterations) { i in
            dataManager.save(Data(), for: "\(i)")
        }
        XCTAssertEqual(dataManager.count, iterations)
    }
}
