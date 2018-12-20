---
layout: post
title: "Handling Index Out of Range Exception the Swift Way"
permalink: /handling-out-of-bounds-exception/
share-img: "/img/handling-out-of-bounds-exception-share.png"
---

In this article you will learn a practical technique of how to treat index out of range exception in Swift arrays and other collections.

### Problem Statement

The *array* is probably the most widely used data structure in Swift. It organizes data in a way that each component can be picked at random and is quickly accessible. To be able to mark an individual element, an *index* is introduced. Index must be an integer between *0* and *n-1*, where *n* is the number of elements and the *size* of the array.

If *index* does not satisfy the aforementioned condition, the renown *out of bounds* or *index out of range* exception is raised and the program crashes. I would conjecture that it is among the most frequent error causes in Swift programs.

In this article we will see how to safeguard Swift arrays and other collections to eliminate this kind of error.

### Handling Index Out of Range Exception

Here is a trivial use case that demonstrates the problem:

```swift
let array = [0, 1, 2]
let index = 3
print(array[3]) // Fatal error: Index out of range
```

Since `array` does not have an element under *index* 3, the above code leads to the *index out of range exception* and crash. It can be visualized as follows:

<p align="center">
    <a href="{{ "img/handling-out-of-bounds-exception-icon.png" | absolute_url }}">
        <img src="/img/handling-out-of-bounds-exception-icon.png" alt="Handling Index Out of Range (Index Out of Bounds) Exception the Swift Way"/>
    </a>
</p>

By adding a small sanity check we can eliminate this error:

```swift
if index >= 0 && index < array.count {
    print(array[index])
}
```

Although the crash has been fixed, it does not seem like a decent solution. Indeed, the code looks ugly and it should be repeated every time an array element is accessed. We can do it better.

Let's implement an `Array` extension that returns an element by its index and does bounds check:

```swift
extension Array {
    func getElement(at index: Int) -> Element? {
        let isValidIndex = index >= 0 && index < count
        return isValidIndex ? self[index] : nil
    }
}
```

Although it does the job, the API still does not feel *Swifty*. We can improve its readability by means of *subscripts*.

### Overloading Subscript

*Subscripts* provide shortcuts to access elements in an array or other collection. The default *subscript* raises an exception when an index appears to be out of valid range. Let's overload it to return an optional element instead.

```swift
extension Array {
    subscript(safe index: Index) -> Element? {
        let isValidIndex = index >= 0 && index < count
        return isValidIndex ? self[index] : nil
    }
}
```

Although the syntax is now concise, what about the other collections, like `Range`, where elements are also frequently accessed by their index? Let's implement a universal subscript agnostic of any concrete collection type:

```swift
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
```

Now it can be applied universally across different collections:

```swift
[1, 2, 3][safe: 4] // Array - prints 'nil'
(0..<3)[safe: 4] // Range - prints 'nil'
```

### Summary

Index out of range exception is a common source of crashes in Swift projects, thus handling it properly and concisely is highly important.

We have investigated vast range of solutions, starting from a naive and non-reusable one. The final implementation overloads a subscript and is common for all Swift collections that use integer index, such as arrays and ranges.

---

*If you enjoyed reading this article, tweet it forward and subscribe: [@V8tr](https://twitter.com/{{ site.author.twitter }}).*

---

[starter-repo]: https://github.com/V8tr/CollectionViewGridLayout-Starter
[final-repo]: https://github.com/V8tr/CollectionViewGridLayout-Final