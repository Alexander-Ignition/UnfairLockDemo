//
//  UnfairLockDemoApp.swift
//  UnfairLockDemo
//
//  Created by Alexander Ignition on 20.10.2024.
//

import SwiftUI
import os.lock
import Combine

@main
struct UnfairLockDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    let lock = OSAllocatedUnfairLock(initialState: false)
                    print(lock)
                    dump(lock)
                }
        }
    }
}
