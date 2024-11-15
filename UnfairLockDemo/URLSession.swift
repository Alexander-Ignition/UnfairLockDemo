//
//  URLSession+Async.swift
//  UnfairLockDemo
//
//  Created by Alexander Ignition on 20.10.2024.
//

import Foundation
import os.lock

// MARK: - withCheckedThrowingContinuation

extension URLSession {

    func data1(from url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url, completionHandler: { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: (data!, response!))
                }
            })
            task.resume()
        }
    }
}

// MARK: - withTaskCancellationHandler

extension URLSession {

    func data2(from url: URL) async throws -> (Data, URLResponse) {
        var task: URLSessionDataTask?

        actor Handle {
            var task: URLSessionDataTask?
        }

        return try await withTaskCancellationHandler {

            try await withCheckedThrowingContinuation { continuation in
                let dataTask = self.dataTask(with: url) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: (data!, response!))
                    }
                }
                task = dataTask
                dataTask.resume()
            }

        } onCancel: {
            task?.cancel() // ??
        }
    }

}

// MARK: - Foundation

/*
extension URLSession {
    @available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
    func data(from url: URL, delegate: (any URLSessionTaskDelegate)? = nil) async throws -> (Data, URLResponse) {}

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func data(from url: URL) async throws -> (Data, URLResponse) {}
}



 cd /Applications/Xcode.app/Contents
 grep -rnw '.' -e 'os_unfair_lock' —include='*.swiftinterface'
 xed ./Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/Foundation.framework/Modules/Foundation.swiftmodule/arm64-apple-ios.swiftinterface

 */
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension URLSession {

    @_alwaysEmitIntoClient
    public func data(from url: URL) async throws -> (Data, URLResponse) {
        if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
            return try await data(from: url, delegate: nil)
        }
        let cancelState = makeState()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let task = dataTask(with: url) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: (data!, response!))
                    }
                }
                task.resume()
                activate(state: cancelState, task: task)
            }
        } onCancel: {
            cancel(state: cancelState)
        }
    }

    @_alwaysEmitIntoClient
    private func makeState() -> ManagedBuffer<(isCancelled: Bool, task: Foundation.URLSessionTask?), os_unfair_lock> {
        ManagedBuffer<(isCancelled: Bool, task: URLSessionTask?), os_unfair_lock>.create(minimumCapacity: 1) { buffer in
            buffer.withUnsafeMutablePointerToElements { $0.initialize(to: os_unfair_lock()) }
            return (isCancelled: false, task: nil)
        }
    }

    @_alwaysEmitIntoClient
    private func cancel(
        state: ManagedBuffer<(isCancelled: Bool, task: URLSessionTask?), os_unfair_lock>
    ) {
        state.withUnsafeMutablePointers { state, lock in
            os_unfair_lock_lock(lock)
            let task = state.pointee.task
            state.pointee = (isCancelled: true, task: nil)
            os_unfair_lock_unlock(lock)
            task?.cancel()
        }
    }

    @_alwaysEmitIntoClient
    private func activate(
        state: ManagedBuffer<(isCancelled: Bool, task: URLSessionTask?), os_unfair_lock>,
        task: URLSessionTask
    ) {
        state.withUnsafeMutablePointers { state, lock in
            os_unfair_lock_lock(lock)
            if state.pointee.task != nil {
                fatalError("Cannot activate twice")
            }
            if state.pointee.isCancelled {
                os_unfair_lock_unlock(lock)
                task.cancel()
            } else {
                state.pointee = (isCancelled: false, task: task)
                os_unfair_lock_unlock(lock)
            }
        }
    }
}

// MARK: - withCancellableContinuation

extension URLSession {

    func data3(from url: URL) async throws -> (Data, URLResponse) {

        try await withCancellableContinuation { continuation in

            let dataTask = self.dataTask(with: url, completionHandler: { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: (data!, response!))
                }
            })
            dataTask.resume()
            return { dataTask.cancel() }
        }
    }
}
