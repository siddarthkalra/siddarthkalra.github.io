---
layout: post
title:  What are the differences between Swift, the standard library and Foundation?
date:   2021-01-03 00:00
tags: article, swift, FAQ
---

# What are the differences between Swift, the standard library and Foundation?

If you write any Swift code or consume content related to Swift, you are bound to come across references to the standard library and Foundation. To gain a more in-depth understanding of the Swift ecosystem, it's important to know the differences between these terms. 

This is especially true if you plan to become a Swift contributor one day or if you plan to use the language on non-Apple platforms such as Linux. The evolution of Swift's ecosystem on non-Apple platforms is still a work in progress so the differences can become quite apparent. You might find yourself reaching for a particular tool or class and learn that it's unavailable because actually it's part of Foundation and not Swift itself. 

So let's start with a visual breakdown and then jump into a high level overview for each term:

![Swift, standard library and Foundation comparison](/images/swift-vs-stdlib-vs-foundation.svg)

## Swift

The Swift language encompasses a few different systems like the compiler, runtime, build system, IDE support etc. The Swift compiler is predominantly written in C++. A full language guide can be found on [swift.org](https://swift.org/) and the source code is available on [GitHub](https://github.com/apple/swift). You might occasionally run into subtle platform specific edge cases. For example, this [link](https://bugs.swift.org/issues/?jql=labels+%3D+Linux) shows you the current known bugs for Linux. But generally speaking, the full set of language features should be available on every platform officially supported by Swift.

## Standard library

The Standard library builds on top of the lexicon defined by the Swift language and is also part of the [Swift open source project](https://github.com/apple/swift/tree/main/stdlib). It's written in Swift itself, unlike the Swift compiler. It focuses on providing primitive language features such as common data types (e.g. Int, Float), structures (e.g. Array, Dictionary), protocols and functions.  A full implementation of the standard library should be available on every platform officially supported by Swift.

## Foundation

Foundation is a separate framework that provides core functionality not offered by Swift or the standard library. It sits one level higher than the standard library on the stack. Its goal is to offer common functionality that many modern applications require to be successful. Thus, it includes structures and helpers for networking, internationalization, serialization, strings, numbers, dates and more.

The variant shipped on Apple platforms is primarily written in Objective-C and is not open source. On non-Apple platforms, since an Objective-C runtime is unavailable, there is an [open source project](https://github.com/apple/swift-corelibs-foundation) that aims to micmic and replicate Apple's original implementation of Foundation. This replication effort is still a [work in progress](https://github.com/apple/swift-corelibs-foundation/blob/main/Docs/Status.md) in terms of reaching full feature parity.

## References

- [AppBuilders 2018 - Becoming An Effective Contributor to Swift](https://www.youtube.com/watch?v=oGJKsp-pZPk)
- [https://swift.org/standard-library/#standard-library-design](https://swift.org/standard-library/#standard-library-design)
- [https://swift.org/core-libraries/#foundation](https://swift.org/core-libraries/#foundation)
- [https://developer.apple.com/documentation/foundation](https://developer.apple.com/documentation/foundation)
- [https://swift.org/platform-support/](https://swift.org/platform-support/)