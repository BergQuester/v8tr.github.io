---
layout: post
title: Designing Richer API Utilizing Initialization with Literals
permalink: /initialization-with-literals/
share-img: "/img/multicast_delegate_share.png"
---

### Introduction

*“Indeed, the ratio of time spent reading versus writing is well over 10 to 1. We are constantly reading old code as part of the effort to write new code. ...[Therefore,] making it easy to read makes it easier to write.” - Robert C. Martin*

Rephrasing Robert Martin, one should not neglect readability of their code in favor of convenience of writing it. Today we'll see how Initialization with Literals technique can be used to build more expressible and richer APIs.

### Explaining Initialization with Literals

Swift has a family of `ExprissibleByLiteral` protocols that allows structs, classes and enums to be initialized using some literal, ex. array, string, integer etc.

For instance, the standard library integer and floating-point types conform to `ExpressibleByIntegerLiteral` protocol, thus can be initialized with an integer literal:

{% highlight swift linenos %}

// Type inferred as 'Int'
let intValue = 1

// A floating-point value initialized using an integer literal. Type inferred as 'Double'
let doubleValue: Double = 1

{% endhighlight %}

The full list of literals with corresponding protocols is next:

- ExpressibleByArrayLiteral
- ExpressibleByDictionaryLiteral
- ExpressibleByIntegerLiteral
- ExpressibleByFloatLiteral
- ExpressibleByBooleanLiteral
- ExpressibleByNilLiteral
- ExpressibleByStringLiteral
- ExpressibleByExtendedGraphemeClusterLiteral
- ExpressibleByUnicodeScalarLiteral

| Protocol | Initializer |
| -------- | ----------- |
| `ExpressibleByArrayLiteral | `init(arrayLiteral: Self.ArrayLiteralElement...)` <br><br> *ArrayLiteralElement* - The type of the elements of an array literal |
| `ExpressibleByDictionaryLiteral` | `init(dictionaryLiteral:(Self.Key, Self.Value)...)` <br><br> *Key,Value* - The key and the value types of a dictionary literal |
| `ExpressibleByIntegerLiteral` | `init(integerLiteral: Self.IntegerLiteralType)` <br><br> A type that represents an integer literal |
| `ExpressibleByFloatLiteral` | `init(floatLiteral: Self.FloatLiteralType)` <br><br> A type that represents a floating-point literal. |
| `ExpressibleByBooleanLiteral` | `init(booleanLiteral: Self.BooleanLiteralType)` <br><br> A type that represents a Boolean literal, such as Bool. |
| `ExpressibleByNilLiteral` | `init(nilLiteral: ())` <br><br> A type that can be initialized using the nil literal, nil. |
| `ExpressibleByStringLiteral` | `init(stringLiteral: Self.StringLiteralType)` <br><br> A type that can be initialized with a string literal. |
| `ExpressibleByExtendedGraphemeClusterLiteral` | `init(extendedGraphemeClusterLiteral: Self.ExtendedGraphemeClusterLiteralType)` <br><br> A type that represents an extended grapheme cluster literal. |
| `ExpressibleByUnicodeScalarLiteral` | `init(unicodeScalarLiteral: Self.UnicodeScalarLiteralType)` <br><br> A type that represents a Unicode scalar literal. |


### In-depth explanation per literal

### Integer Literal

Imagine, your are developing an app in a banking domain, where the notion of finances is the core of your domain model. Defining your model clear and direct is crucial in that case. How would you approach it? Lets start with a simple example:

{% highlight swift linenos %}

struct Dollar {
	let amount: Int
}

let tenDollars = Dollar(amount: 10)

{% endhighlight %}



### Common Solution

### Applying Initialization with Literals

### Wrapping Up

---

*I'd love to meet you in Twitter: [here](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you found it useful.*

---

[code-injection-article]: http://www.vadimbulavin.com/code-injection-swift/