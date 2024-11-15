# Unfair Lock Demo

- [NSLock](https://github.com/swiftlang/swift-corelibs-foundation/blob/main/Sources/Foundation/NSLock.swift)
- [The Fastest Mutexes](https://justine.lol/mutex/)
    - [HackerNews](https://news.ycombinator.com/item?id=41721668)
    - [Habr](https://habr.com/ru/companies/beget/articles/848318/)

```sh
cd /Applications/Xcode.app/Contents
grep -rnw '.' -e 'OSAllocatedUnfairLock' —include='*.swiftinterface'
xed ./Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/lib/swift/os.swiftmodule/arm64e-apple-macos.swiftinterface
```

```sh
cd /Applications/Xcode.app/Contents
grep -rnw '.' -e 'os_unfair_lock' —include='*.swiftinterface'
xed ./Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/System/Library/Frameworks/Foundation.framework/Modules/Foundation.swiftmodule/arm64-apple-ios.swiftinterface
```
