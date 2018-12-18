---
layout: post
title: "Handling Out of Bounds Exception the Swift Way"
permalink: /handling-out-of-bounds-exception/
share-img: "/img/data-drive-table-views-share.png"
---

### Problem Statement

The *array* is probably the most widely used data structure in Swift. It organizes data in a way that each component can be picked at random and is quickly accessible. To be able to mark an individual element, an *index* is introduced. Index must be an integer between *0* and *n-1*, where *n* is the number of elements and the *size* of the array.

If *index* does not satisfy the aforementioned condition, the renown *out of bounds exception* is raised and the program crashes. Even without the precise statistics, I would venture to guess that it is among the most frequent error causes in Swift programs.

In this article we will see how to safeguard Swift arrays and other collections to eliminate the out of bounds exceptions.

### Safeguarding Out of Bounds Exception



### Implementation

```swift
extension BidirectionalCollection {
    subscript(safe offset: Int) -> Element? {
        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
        return self[i]
    }
}
```

### Source Code

If you are interested in seeing the full source code for this article, go ahead and [download the sample project from GitHub](https://github.com/V8tr/PluginTableViewController).

### Summary


---

*If you enjoyed reading this article, tweet it forward and subscribe: [@V8tr](https://twitter.com/{{ site.author.twitter }}).*

---

[starter-repo]: https://github.com/V8tr/CollectionViewGridLayout-Starter
[final-repo]: https://github.com/V8tr/CollectionViewGridLayout-Final