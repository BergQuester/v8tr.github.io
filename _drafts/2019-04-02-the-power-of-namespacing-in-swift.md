---
layout: post
title: "The Power of Namespacing in Swift"
permalink: /the-power-of-namespacing-in-swift/
share-img: ""
---

Although Swift has no language features for full-fledge name spacing, its lack is compensated by multiple techniques which lend themselves to improving code structure. Let's take a look at different ways of implementing name spacing in Swift. 

### Defining Namespace

**Namespace** is a named region of program used to group variable, types and methods. Namespacing has following benefits:
- Allows to improve code structure by organizing the elements, which otherwise would have global scope, into the local scopes. 
- Prevents name collision.
- Provides [encapsulation](https://en.wikipedia.org/wiki/Encapsulation_(computer_programming)).

### Implicit Namespacing in Swift

*Namespacing* is implicit in Swift, meaning that all types, variables (etc) are automatically scoped by the module, which, in its turn, corresponds to Xcode target.

Most of the time no module prefixes are needed to access a type from outer scope:

```swift
let zeroOrOne = Int.random(in: 0...1)
print(zeroOrOne) // Prints 0 or 1
```

Here `Int` is a part of Swift standard library, which has external scope. 

### Excplicit Namespacing in Swift

Let's see what happens in case of name collision, when local type `Int` is defined:

```swift
struct Int {}

let zeroOrOne = Int.random(in: 0...1) // error: type 'Int' has no member 'random'
```

System integer type is shadowed by the local one, when the collision occurs. To resolve the ambiguity, the namespace must be explicitly specified:

```swift
struct Int {}

let zeroOrOne = Swift.Int.random(in: 0...1)
let myInt = Article_Namespacing.Int.init()
```

`Swift` is the *namespace* for all foundation types and primitives, including `Int` [[1]](https://github.com/apple/swift-corelibs-foundation). `Article_Namespacing` is global *namespace* of current Xcode target.

Another possible case is collision of names from two external frameworks. Say, `FrameworkA` and `FrameworkB` both declare their own `Int` types, as depicted below:

<p align="center">
    <a href="{{ "/img/the-power-of-namespacing-in-swift/name-collision.png" | absolute_url }}">
        <img src="/img/the-power-of-namespacing-in-swift/name-collision.png" alt="The Power of Namespacing in Swift"/>
    </a>
</p>

What happens if both of them are imported and accessed from current Xcode target?

```swift
import FrameworkA
import FrameworkB

print(Int.init()) // Oops, error: Ambiguous use of 'init()'
```

To resolve the ambiguity, a name space must be explicitly specified:

```swift
import FrameworkA
import FrameworkB

print(FrameworkA.Int.init()) // Prints: FrameworkA
print(FrameworkB.Int.init()) // Prints: FrameworkB
```

Taking into account that imports are the only language feature providing namespacing, let's see more advanced usage scenarios.

### Import Declaration Grammar

Modules have hierarchial structure and could be composed of sub-modules [[2]](https://clang.llvm.org/docs/Modules.html#introduction). It is possible to limit imported namespace to sub-modules:

```swift
import UIKit.NSAttributedString
```

{: .box-note}
*`UIKit.NSAttributedString` sub-module imports the entire `UIKit`, and additionally `Foundation`, hence such import will not benefit*

https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#grammar_import-path-identifier

---

*If you enjoyed reading this article, tweet it forward and subscribe: [@V8tr](https://twitter.com/{{ site.author.twitter }}).*

---

[code-injection-article]: http://www.vadimbulavin.com/code-injection-swift/