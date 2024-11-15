//
//  Cancellation.swift
//  UnfairLockDemo
//
//  Created by Alexander Ignition on 04.11.2024.
//

import os.lock

typealias Cancellation = @Sendable () -> Void

func withCancellableContinuation<T>(
    body: (CheckedContinuation<T, any Error>) -> Cancellation
) async throws -> T {
    let lock = WBAllocatedUnfairLock<Cancellation?>(uncheckedState: nil)

    return try await withTaskCancellationHandler {

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, any Error>) in

            let cancellation = body(continuation)

            if Task.isCancelled {
                cancellation()
            } else {
                lock.withLock { $0 = cancellation }
            }
        }
    } onCancel: {
        let cancellation = lock.withLock { cancellation in
            defer { cancellation = nil }
            return cancellation
        }
        cancellation?()
    }
}
