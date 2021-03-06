---
layout: post
title:  A collection of key paths, same root type but different values
date:   2019-03-15 10:18
description: I love Swift KeyPaths as they allow us to work in a type-safe environment. But I ran into a problem the other day when using them for a feature I was implementing.
tags: article, swift, key paths
---

# A collection of key paths, same root type but different values

I love Swift [`KeyPaths`](https://developer.apple.com/documentation/swift/keypath) as they allow us to work in a type-safe environment. But I ran into a problem the other day when using them for a feature I was implementing.

I wanted the ability to create an array of `KeyPaths` where the `Root` was the same type but the `Value` types were different. The first thing I tried was this:

```swift
class Dog {
    @objc let name: String = ""
    @objc let age: Int = 0
}

let keyPaths = [\Dog.name, \Dog.age]
```

Xcode reports that `keyPaths` has the type `PartialKeyPath<Dog>`. This actually makes sense because `name` is a `String` while `age` is an `Int`. So, Swift uses a [`PartialKeyPath`](https://developer.apple.com/documentation/swift/partialkeypath), which type-erases the `Values` for you.

This was great but didn't work for my particular problem. I wanted to use `KeyPaths` to represent property names in a type-safe manner. Given a `KeyPath`, print out the property name of the value, like so:

```swift
func printPropertyName<Root, Value>(keyPath: KeyPath<Root, Value>) {
    let propertyName = NSExpression(forKeyPath: keyPath).keyPath
    print(propertyName)
}

printPropertyName(keyPath: \Dog.name) // prints name
printPropertyName(keyPath: \Dog.age) // prints age
```

`NSExpression` is a great Apple API that gives us the ability to retrieve the property name of a `KeyPath`, if the property is annotated with `@objc`.

Next, I wanted the ability to pass in a collection of `KeyPaths` like so:

```swift
printPropertyNames(keyPaths: [\Dog.name, \Dog.age])
```

As we saw earlier, the type of the array would be `PartialKeyPath<Dog>`. Unfortunately, since the `KeyPath's` `Value` is type-erased, we loose the ability to retrieve the property names and `NSExpression()` no longer works for us.

```swift
func printPropertyNames<Root>(keyPaths: [PartialKeyPath<Root>]) {
    keyPaths.forEach { keyPath in
        let valueName = NSExpression(forKeyPath: keyPath).keyPath
        print(valueName)
    }
}

printPropertyNames(keyPaths: [\Dog.name, \Dog.age])
```

The compiler tells us we're crazy by throwing an error `Cannot invoke initializer for type 'NSExpression' with an argument list of type '(forKeyPath: (PartialKeyPath<Root>))'` for the code shown above.

So, how do we get around this problem? Well, one approach is to wrap our `KeyPath` access in a closure.

Let's start by defining a function that makes this wrapping closure for us. We'll refer to the closure as a `PropertyRef`:

```swift
typealias PropertyName = String

func makePropertyRef<Root, Value>(keyPath: KeyPath<Root, Value>) -> (Root.Type) -> PropertyName {
    return { rootType in
        let propertyName = NSExpression(forKeyPath: keyPath).keyPath
        return propertyName
    }
}
```

Now, given a `KeyPath`, we can make a `PropertyRef`. All that remains is to rewrite our print property name function to work with `PropertyRefs` instead of `KeyPaths`:

```swift
func printPropertyNames<Root>(propertyRefs: (Root.Type) -> PropertyName...) {
    let propertyNames = propertyRefs.map { $0(Root.self) }
    print(propertyNames)
}

printPropertyNames(propertyRefs: makePropertyRef(keyPath: \Dog.name), makePropertyRef(keyPath: \Dog.age))
```

This is great because we retain the type-safety that KeyPaths give us and it stops us from mixing `Root` types, which is exactly what we want.

```swift
printPropertyNames(propertyRefs: makePropertyRef(keyPath: \Dog.breed)) // compiler error
printPropertyNames(propertyRefs: makePropertyRef(keyPath: \Dog.name), makePropertyRef(keyPath: \Cat.age)) // compiler error
```

So, there you have it. We now have the ability to produce a collection of `KeyPaths` where our `Root` is the same but the values are different while retaining our ability to access the property names of the `Values`.
