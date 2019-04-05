---
layout: post
title: "The Power of Namespacing in Swift"
permalink: /the-power-of-namespacing-in-swift/
share-img: "/img/the-power-of-namespacing-in-swift/share.png"
---

Namespacing is a powerful feature to improve code structure. Although being limited in Swift, it can be compensated with pseudo-namespaces. Let's take a look at how it works in Swift by default and how it can be simulated.

### Defining Namespace

**Namespace** is a named region of program used to group variable, types and methods. Namespacing has following benefits:
- Allows to improve code structure by organizing the elements, which otherwise would have global scope, into the local scopes. 
- Prevents name collision.
- Provides [encapsulation](https://en.wikipedia.org/wiki/Encapsulation_(computer_programming)).

**What about Swift?** *Namespacing* is implicit in Swift, meaning that all types, variables (etc) are automatically scoped by the module, which, in its turn, corresponds to Xcode target.

Most of the time no module prefixes are needed to access an externally scoped type:

```swift
let zeroOrOne = Int.random(in: 0...1)
print(zeroOrOne) // Prints 0 or 1
```
Although `Int` is declared outside, the scope is figured automatically.

**What if names conflict?** In case of name collision, local types shadow the external ones:

```swift
struct Int {}

let zeroOrOne = Int.random(in: 0...1) // error: type 'Int' has no member 'random'
```

Local type `Int` does not declare method `random(in:)`, hence the error. To resolve the ambiguity, the namespace must be explicitly specified. `Swift` is the *namespace* for all foundation types and primitives, including `Int` [[1]](https://github.com/apple/swift-corelibs-foundation). `Article_Namespacing` is the *namespace* of current Xcode target: 

```swift
struct Int {}

let zeroOrOne = Swift.Int.random(in: 0...1)
let myInt = Article_Namespacing.Int.init()
```

**What if external names conflict?** Another possible case is collision of names from two frameworks. Say, `FrameworkA` and `FrameworkB` both declare their own `Int` types, as depicted below:

<p align="center">
    <a href="{{ "/img/the-power-of-namespacing-in-swift/name-collision.png" | absolute_url }}">
        <img src="/img/the-power-of-namespacing-in-swift/name-collision.png" alt="The Power of Namespacing in Swift"/>
    </a>
</p>

The ambiguity cannot be resolved automatically:

```swift
import FrameworkA
import FrameworkB

print(Int.init()) // Oops, error: Ambiguous use of 'init()'
```

It is addressed by adding namespaces:

```swift
import FrameworkA
import FrameworkB

print(FrameworkA.Int.init()) // Prints: FrameworkA
print(FrameworkB.Int.init()) // Prints: FrameworkB
```

Import statement has multiple lesser-known traits, which are worth to be discussed.

### Import Statement Grammar

**Import by sub-module**. Modules have hierarchial structure and could be composed of sub-modules [[2]](https://clang.llvm.org/docs/Modules.html#introduction). It is possible to limit imported namespace to sub-modules:

```swift
import UIKit.NSAttributedString

func foo() -> UIView { // All good
    return UIView()
}
```

Wonder why `UIView` is still accessible? `UIKit.NSAttributedString` imports the entire `UIKit`, and additionally `Foundation`.

**Import by symbol.** Only the imported symbol (and not the module that declares it) is made available in the current scope:

```swift
import class UIKit.NSAttributedString

func foo() -> UIView { // error: Use of undeclared type 'UIView'
    return UIView()
}
```

Note the `class` keyword here; `struct` and `enum` are among the possible options. Full import statement grammar is [available at swift.org](https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#grammar_import-path-identifier).

### Namespacing Techniques

The implicit per-module namespacing is often not enough to express complex code structures. The solution is to create pseudo-namespaces by means of `enum`s.

**Why enum?** Unlike structs, enums do not have synthesized initializers; unlike classes they do not allow for subclassing, which makes them a perfect candidate to simulate a namespace. Let's see the practical examples.

**Better-organized constants**. Different ways to specify constants exist: global variables, properties, config files. Namespace groups constants in a readable, understandable and consistent way, without polluting outer scope. View controllers often have user-interface-related constraints, expressible via namespaced constants:

```swift
class ItemListViewController {
    ...
}

extension ItemListViewController {

    enum Constants {
        static let itemsPerPage = 7
        static let headerHeight: CGFloat = 60
    }
}
```

How the constants will be named if put into global scope? I guess, those are close enough: 

```swift
let itemListViewControllerItemsPerPage = 7
let itemListViewControllerHeaderHeight: CGFloat = 60
```

The names look identical, are difficult to read and error-prone to type. No more cumbersome names. Compare with: 

```swift
ItemListViewController.Constants.itemsPerPage
ItemListViewController.Constants.headerHeight
```

**Factories and factory methods**. The creation of objects often contains complex mapping, validations, special cases handling. Namespaced factories and factory methods provide a handy way of keeping creation and mapping logic close the the original type, without polluting the external scope:

```swift
struct Item {
    ...
}

extension Item {

    enum Factory {
        static func make(from anotherItem: AnotherItem) -> Item {
            // Complex computations to map AnotherItem into Item
            return Item(...)
        }
    }
}

// Usage:

let anotherItem = AnotherItem()
let item = Item.Factory.make(from: anotherItem)
```

**Grouping by usage area**. Network layer often needs specialized models for requests and responses, which are not used anywhere else, hence are good candidates to be grouped into a namespace:

```swift
enum API {

    enum Request {

        struct UpdateItem {
            let id: Int
            let title: String
            let description: String
        }
    }

    enum Response {

        struct ItemList {
            let items: [Item]
            let page: Int
            let pageSize: Int
        }
    }
}
```
Such code is self-documented; global scope is not polluted with `Request` name, since it is ambiguous without a context.

### Summary

The importance of good code structure is difficult to overestimate. Namespacing improves code structure by grouping relevant elements into local scopes and makes code self-documented.

Swift has limited built-in support for namespacing, which can be compensated by placing elements into `enum`s as pseudo-namespaces.

The [article on Swift Code Style]({{ "/swift-code-style/" | absolute_url }}) might be of particular interest if looking for more ways to improve code quality.

---

*If you enjoyed reading this article, tweet it forward and subscribe: [@V8tr](https://twitter.com/{{ site.author.twitter }}).*

---

[code-injection-article]: http://www.vadimbulavin.com/code-injection-swift/