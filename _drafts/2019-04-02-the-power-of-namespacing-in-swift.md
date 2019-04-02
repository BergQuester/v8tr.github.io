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

### Namespacing in Swift

*Namespacing* is implicit in Swift, meaning that all types, variables (etc) are automatically scoped by the module, which, in its turn, corresponds to Xcode target.

Most of the time no module prefixes are needed to access a type from outer scope:

```swift
let zeroOrOne = Int.random(in: 0...1)
print(zeroOrOne) // Prints 0 or 1
```

Here `Int` is a part of Swift standard library, which has external scope. Let's see what happens in case of name collision:

```swift
struct Int {}
let zeroOrOne = Int.random(in: 0...1) // error: type 'Int' has no member 'random'
```
<!-- By default, Swift makes current module namespace default. Hence, when custom `Int` type is declared, it shadows the system one: -->

In second scenario, Swift shadows the system integer type by the custom one. If name collision occurs, current namespace is prioritized over the external one.

Another case is collision of two external names. Say, `FrameworkA` and `FrameworkB` exist, both having `Int` type declared:

<p align="center">
    <a href="{{ "/img/the-power-of-namespacing-in-swift/name-collision.png" | absolute_url }}">
        <img src="/img/the-power-of-namespacing-in-swift/name-collision.png" alt="The Power of Namespacing in Swift"/>
    </a>
</p>

What happens if both of them are imported into current target?

```swift
import FrameworkA
import FrameworkB

print(Int.init()) // Oops, error: Ambiguous use of 'init()'
```

To resolve the ambiguity, a name space must be specified:

```swift
import FrameworkA
import FrameworkB

print(FrameworkA.Int.init()) // Prints: FrameworkA
print(FrameworkB.Int.init()) // Prints: FrameworkB
```

After going through the basics, let's move on to more complex cases.

### Type-Specific Namespacing in Swift


---

*If you enjoyed reading this article, tweet it forward and subscribe: [@V8tr](https://twitter.com/{{ site.author.twitter }}).*

---

[code-injection-article]: http://www.vadimbulavin.com/code-injection-swift/