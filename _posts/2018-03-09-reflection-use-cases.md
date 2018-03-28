---
layout: post
title: Reflection and Mirror in Swift
permalink: /2018-03-09-reflection-and-mirror-in-swift/
---

Although Swift is a statically typed language, there is a secret double life to Swift’s type system at runtime that paves the way to some dynamism. This allows to look at the types and the methods that we defined in our code and build higher abstractions on top of that. This technique is called Reflection. In the article we will have a look at Reflection and `Mirror` type as well as discuss several practical usage cases.

# Reflection and Mirror

Reflection is [defined][reflection-def] as the ability of a computer program to examine, introspect, and modify its own structure and behavior at runtime.

[Introspection][introspection-def], in turn, is the ability of a program to examine the type or properties of an object at runtime.

Swift's Reflection is limited, providing read-only access to a subset of type metadata. Such metadata is encapsulated in `Mirror` instances. Under the hood, there is `Mirror` implementation for each Swift metadata type: `Tuple`, `Struct`, `Enum`, `Class`, `Metatype`, [Opaque][opaque-type-def], all derived from `ReflectionMirrorImpl` abstract class. 

These classes are capable of reading arbitrary fields of corresponding metadata types. Parent-child hierarchies are crawled by means of Objective-C runtime. The latter has **platform limitations**, because requires [unbridged][toll-free-bridging-def] interoperation with Objective-C, which is supported only by Apple platforms. This means, the use of `Mirror` on other platforms will crash your app.

## JSON parsing

JSON parsing is probably the first thing that comes in mind with respect to Reflection appliance. Let's see a trivial example that demonstrates the basic idea.

{% highlight swift linenos %}

protocol JSONSerializable {
    func toJSON() throws -> Any?
}

enum CouldNotSerializeError: Error {
    case noImplementation(source: Any, type: String)
    case undefinedKey(source: Any, type: String)
}

extension JSONSerializable {

    func toJSON() throws -> Any? {
        let mirror = Mirror(reflecting: self)

        guard !mirror.children.isEmpty else { return self }

        var result: [String: Any] = [:]

        for child in mirror.children {
            if let value = child.value as? JSONSerializable {
                if let key = child.label {
                    result[key] = try value.toJSON()
                } else {
                    throw CouldNotSerializeError.undefinedKey(source: self, type: String(describing: type(of: child.value)))
                }
            } else {
                throw CouldNotSerializeError.noImplementation(source: self, type: String(describing: type(of: child.value)))
            }
        }

        return result
    }
}

{% endhighlight %}

Now adding JSON serialization is as simple as conforming to `JSONSerializable`. Let's see it in action:

{% highlight swift linenos %}

struct Order {
    let uid = UUID()
    let itemsCount = 1
    let isDeleted = false
    let name = "A cup"
    let subtitle: String? = nil
    let category = Category(name: "Cups")
}

struct Category {
    let name: String
}

extension String: JSONSerializable {}
extension Int: JSONSerializable {}
extension Bool: JSONSerializable {}
extension Optional: JSONSerializable {}
extension UUID: JSONSerializable {}
extension Order: JSONSerializable {}
extension Category: JSONSerializable {}

do {
    try Order().toJSON()
} catch {
    print(error)
}

{% endhighlight %}

The `Order` instance is serialized into:

{% highlight swift linenos %}

["itemsCount": 1, "name": "A cup", "isDeleted": false, "category": ["name": "Cups"], "uid": F888F5A7-F499-4748-BB28-2B9BDD4D8399, "subtitle": nil]

{% endhighlight %}

Let's filter out all `nil` values by extending our serialization for `Optional` type:

{% highlight swift linenos %}

extension Optional: JSONSerializable {
    func toJSON() throws -> Any? {
        if let x = self {
            guard let value = x as? JSONSerializable else {
                throw CouldNotSerializeError.noImplementation(source: x, type: String(describing: type(of: x)))
            }
            return try value.toJSON()
        }
        return nil
    }
}

{% endhighlight %}

Now all `nil` values are filtered out and the `Order` instance from the above example is serialized into:

{% highlight swift linenos %}

["itemsCount": 1, "name": "A cup", "isDeleted": false, "category": ["name": "Cups"], "uid": 07614D63-5A08-465D-8CC8-195434A2C371]

{% endhighlight %}

You can find the full code for this example [here][json-serialization-gist]. That's enough as for JSON serialization, let's move on with another example.

## Automatic Equatable and Hashable conformance

Conforming to `Equatable` and `Hashable` is always boring and leaves lots of room for mistake. Every time you add a new property, it's super easy to forget to update corresponding hash value and equality operator.

There is a family of [dump][dump-docs] functions that composes textual representation of the given items by using their mirrors. This approach makes an assumption that equal objects always have the same mirrors. Evaluate this assumption against your domain model before incorporating it into your production code.

{% highlight swift linenos %}

protocol AutoEquatable: Equatable {}

extension AutoEquatable {

    static func ==(lhs: Self, rhs: Self) -> Bool {
        var lhsDump = String()
        dump(lhs, to: &lhsDump)

        var rhsDump = String()
        dump(rhs, to: &rhsDump)

        return rhsDump == lhsDump
    }
}

{% endhighlight %}

Now let's create trivial structs to demonstrate the idea:

{% highlight swift linenos %}

struct Order {
    let uid: UUID
    let count: Int
    let orderedAt: Date
    let item: Item
}

struct Item {
    let uid: UUID
    let title: String
    let description: String?
    let priceUSD: Double
}

struct Person {
    let name: String
}

extension Order: AutoEquatable {}
extension Person: AutoEquatable {}

class AutoEquatableTests: XCTestCase {

    let coffee = Item(uid: UUID(), title: "Coffee", description: "Nescafe Original", priceUSD: 5)
    lazy var twoCoffees: Order = { Order(uid: UUID(), count: 2, orderedAt: Date(), item: coffee) }()

    func test_isEqual_samePersons_areEqual()
    {
        XCTAssertEqual(Person(name: "name"), Person(name: "name"))
    }

    func test_notEqual_personsWithDifferentNames_areNotEqual()
    {
        XCTAssertNotEqual(Person(name: "name"), Person(name: "anotherName"))
    }

    func test_isEqual_sameOrders_areEqual()
    {
        XCTAssertEqual(twoCoffees, twoCoffees)
    }

    func test_notEqual_differentOrders_areNotEqual()
    {
        let sandwich = Item(uid: UUID(), title: "Sandwich", description: nil, priceUSD: 5)
        let oneSandwich = Order(uid: UUID(), count: 1, orderedAt: Date(), item: sandwich)

        XCTAssertNotEqual(twoCoffees, oneSandwich)
    }
}

{% endhighlight %}

An important note is that `Item` is not `AutoEquatable`, which means only the top level type must conform to `AutoEquatable`.

The approach with `AutoHashable` is very similar. Let's briefly see how it works:

{% highlight swift linenos %}

protocol AutoHashable: Hashable {}

extension AutoHashable {

    var hashValue: Int {
        var buf = String()
        dump(self, to: &buf)
        return buf.hashValue
    }
}

extension Order: AutoHashable {}
extension Person: AutoHashable {}

class AutoHashableTests: XCTestCase {

    let coffee = Item(uid: UUID(), title: "Coffee", description: "Nescafe Original", priceUSD: 5)
    lazy var twoCoffees: Order = { Order(uid: UUID(), count: 2, orderedAt: Date(), item: coffee) }()

    func test_hashValue_personsWithEqualNames_haveEqualHash()
    {
        XCTAssertEqual(Person(name: "name").hashValue, Person(name: "name").hashValue)
    }

    func test_hashValue_personsWithDifferentNames_haveDifferentHash()
    {
        XCTAssertNotEqual(Person(name: "name").hashValue, Person(name: "anotherName").hashValue)
    }

    func test_hashValue_sameOrders_haveEqualHash()
    {
        XCTAssertEqual(twoCoffees.hashValue, twoCoffees.hashValue)
    }

    func test_hashValue_differentOrders_haveDifferentHash()
    {
        let sandwich = Item(uid: UUID(), title: "Sandwich", description: nil, priceUSD: 5)
        let oneSandwich = Order(uid: UUID(), count: 1, orderedAt: Date(), item: sandwich)

        XCTAssertNotEqual(twoCoffees.hashValue, oneSandwich.hashValue)
    }
}

{% endhighlight %}

Source code for this example can be found [here][automatic-hashable-equatable-gist].

## Wrapping up

Reflection provides great opportunity to combine it's dynamic features together with Swift static type system. Despite being rather limited, it can bring high value to your production code by reducing boilerplate you write. Besides the above examples of so-called dynamic Reflection, you might want to observe static code generators like [Sourcery][sourcery-repo] and [SwiftGen][swiftgen-repo] which might be another good solution to some of these problems.

[reflection-def]: https://en.wikipedia.org/wiki/Reflection_(computer_programming)
[introspection-def]: https://en.wikipedia.org/wiki/Type_introspection
[witness-table-def]: https://github.com/apple/swift/blob/master/docs/SIL.rst#witness-tables
[opaque-type-def]: https://developer.apple.com/library/content/documentation/CoreFoundation/Conceptual/CFDesignConcepts/Articles/OpaqueTypes.html
[toll-free-bridging-def]: https://developer.apple.com/library/content/documentation/CoreFoundation/Conceptual/CFDesignConcepts/Articles/tollFreeBridgedTypes.html
[dump-docs]: https://developer.apple.com/documentation/swift/1539127-dump
[json-serialization-gist]: https://gist.github.com/V8tr/3ab9ab1a550415fae5d61aa39d3a2185
[automatic-hashable-equatable-gist]: https://gist.github.com/V8tr/4507110d40e0b62fb09f1600bd992a96
[sourcery-repo]: https://github.com/krzysztofzablocki/Sourcery
[swiftgen-repo]: https://github.com/SwiftGen/SwiftGen