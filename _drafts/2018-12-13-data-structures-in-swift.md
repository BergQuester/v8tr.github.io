---
layout: post
title: "Data Structures in Swift"
permalink: /data-structures-in-swift/
share-img: "/img/data-drive-table-views-share.png"
---

### Problem Statement



### Defining Data & Data Structures

Swift is a high-level programming language and as software engineers we are freed from operating bits, storage units or memory registers. The fundamental structure blocks that we are using are represented by arrays, sets, ranges, dictionaries, numbers and other *data structures*.

The *data* represent an abstraction of reality that is focused on most relevant traits with regards to the certain problem and ignoring everything peripheral.



*Swift*, as well as any other programming language, represents an abstract computer capable of interpreting the terms used in this language. The software engineer who uses Swift is freed from knowing how numbers or other data structures are implemented on the machine level. Indeed, it is way easier to understand and design a program when operating arrays, sets, dictionaries or numbers other than bits, storage units and memory registers.

The root 


<!-- Swift is a statically typed language with allows the compiler to make a number of checks that reduce the likelihood of some types of errors. Like  -->

The importance of using a language that offers a convenient set of basic abstractions common to most problems of data processing lies mainly in the area of reliability of the resulting programs. It is easier to design a program based on reasoning with familiar notions of numbers, sets, sequences, and repetitions than on bits, storage units, and jumps.

The choice of representation of data is often a fairly difficult one, and it is not uniquely determined by the facilities available.

From this example we can also see that the question of representation often transcends several levels of
detail

A programming language represents an abstract computer capable of interpreting the terms used in this language, which may embody a certain level of abstraction from the objects used by the actual machine. Thus, the programmer who uses such a higher-level language will be freed (and barred) from questions of number representation, if the number is an elementary object in the realm of this language.

### Implementation

Special for Strings

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