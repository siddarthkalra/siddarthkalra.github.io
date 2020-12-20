---
layout: post
title:  Uncaught exceptions on macOS
date:   2019-04-19 18:45
description: I recently came across a peculiar distinction between how exceptions manifest on macOS vs. iOS. On iOS, if an NSRangeException (index out of bounds) occurs, your app will crash, no questions asked. However, that is not always the case on macOS
tags: article, swift, mac os, exceptions
---

I recently came across a peculiar distinction between how exceptions manifest on macOS vs. iOS.

On iOS, if an `NSRangeException` (index out of bounds) occurs, your app will crash, no questions asked. However, that is not always the case on macOS. This behaviour doesn't seem to be that widely known and I had to go digging quite a bit to uncover its roots.

On macOS, exceptions that go unhandled will rise to the level of the uncaught exception handler. This is the point where one can perform extra logic before the program exits. The default handler logs the exception to the console before exiting.

However, the key point is that exceptions on the main thread don't rise to the level of the uncaught exception handler as the global application object catches them preemptively. This is why certain exceptions don't lead to a crash on macOS. Apple details this behaviour [here](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Exceptions/Concepts/UncaughtExceptions.html).

If your app is using a crash reporting tool like [Sentry](https://Sentry.io) or [Crashlytics](https://firebase.google.com/docs/crashlytics/), you don't want to silently log exceptions to the console. You want to know about them. So, how do we handle these exceptions?

We can subclass `NSApplication` and override the `reportException(_:)` method to provide our own custom behaviour:

```swift
@objc(CustomExceptionHandlingApp)
class CustomExceptionHandlingApp: NSApplication {

    override func reportException(_ exception: NSException) {
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true])

        // custom code to handle the exception here

        super.reportException(exception)
    }

}
```

After creating the subclass, make sure to update the `NSPrincipalClass` key in your app's Info.plist to the name of the subclass instead of `NSApplication`.

The last thing to note is that if you want your application to exit when an exception occurs then set the `NSApplicationCrashOnExceptions` key to `true`.
