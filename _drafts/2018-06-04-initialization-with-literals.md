---
layout: post
title: Designing Richer API Using Initialization with Literals
permalink: /initialization-with-literals/
share-img: "/img/multicast_delegate_share.png"
---

### Introduction

*“Indeed, the ratio of time spent reading versus writing is well over 10 to 1. We are constantly reading old code as part of the effort to write new code. ...[Therefore,] making it easy to read makes it easier to write.” - Robert C. Martin*

Rephrasing Robert Martin, one should not neglect readability of their code in favor of convenience of writing it. In this post we'll see how *Initialization with Literals* can help us building more expressible and richer APIs.

### Explaining Initialization with Literals

Swift has a family of `ExprissibleByLiteral` protocols that allow structs, classes and enums to be initialized using a *literal*. 

*Literal* is a notation for representing a fixed *value* in source code. Such notations as integers, floating-point numbers, strings, booleans and characters are literals. Literals are not limited to atomic values. The compound objects like array and dictionary fall within the scope of this definition as well.

{% highlight swift linenos %}
let a = 1
{% endhighlight %}

Here, *1* is an integer *literal* that is used to initialize a constant *a*. 

*Literals* are the essential blocks of the code and implementing shorthands for them makes your code more clean and direct. 

Examine how conformance to `ExpressibleByIntegerLiteral` protocol of integer and floating-point types from Swift Standard Library allows both of them to be initialized with an integer literal:

{% highlight swift linenos %}

// Type inferred as 'Int'
let intValue = 1

// A floating-point value initialized using an integer literal. Type inferred as 'Double'
let doubleValue: Double = 1

{% endhighlight %}

The full list of protocols is next:

- `ExpressibleByArrayLiteral`
- `ExpressibleByDictionaryLiteral`
- `ExpressibleByIntegerLiteral`
- `ExpressibleByFloatLiteral`
- `ExpressibleByBooleanLiteral`
- `ExpressibleByNilLiteral`
- `ExpressibleByStringLiteral`
- `ExpressibleByExtendedGraphemeClusterLiteral`
- `ExpressibleByUnicodeScalarLiteral`

Let's discuss them one by one together with practical examples.

### ExpressibleByStringLiteral

`ExpressibleByStringLiteral` stands for a type that can be initialized with a string literal. To conform to it you'll need to implement `init(stringLiteral: Self.StringLiteralType)`.

Additionally you should consider implementing `ExpressibleByExtendedGraphemeClusterLiteral` and `ExpressibleByUnicodeScalarLiteral`.

The former stands for the type that can be initialized with a string containing a *single* extended grapheme cluster, e.g. "ந". More about the extended grapheme clusters can be found in [Unicode standard][extended-grapheme-cluster]. 

`ExpressibleByUnicodeScalarLiteral` can be initialized with a string containing a *single* [Unicode scalar][unicode-scalar] value. e.g. "♥".

#### ExpressibleByStringLiteral and URL

The code below extends `URL`, so that one can create it from a string. It is especially useful for manually typed `URL`s.

{% highlight swift linenos %}

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = URL(string: value)!
    }
}

{% endhighlight %}

Now you can write code like this:

{% highlight swift linenos %}

let url: URL = "https://www.vadimbulavin.com"
print(url) // prints 'https://www.vadimbulavin.com'

let request = URLRequest(url: "https://www.vadimbulavin.com")
print(request) // prints 'https://www.vadimbulavin.com'

{% endhighlight %}

#### ExpressibleByStringLiteral and NSRegularExpression

Swift borrows `NSRegularExpression` class from Objective-C. We can write our own thin wrapper over it that adds some syntactic sugar:

{% highlight swift linenos %}

struct RegularExpression {
	private let regex: NSRegularExpression

	init(regex: NSRegularExpression) {
		self.regex = regex
	}

	func matches(in string: String, options: NSRegularExpression.MatchingOptions = []) -> [NSTextCheckingResult] {
		return regex.matches(in: string, options: options, range: NSMakeRange(0, string.count))
	}
}

extension RegularExpression: ExpressibleByStringLiteral {
	init(stringLiteral value: String) {
		let regex = try! NSRegularExpression(pattern: value, options: [])
		self.init(regex: regex)
	}
}

let regex: RegularExpression = "abc"
print(regex.matches(in: "abc")) // prints found match

{% endhighlight %}

### ExpressibleByIntegerLiteral

`ExpressibleByIntegerLiteral` represents a type that can be initialized with an integer literal. It does not have any nuances like string literal does, so jump straight to the examples.

#### ExpressibleByIntegerLiteral and Dollar

Imagine, your are developing an app that operates in a financial domain. Here is how your `Dollar` model might look like.

{% highlight swift linenos %}

struct Dollar {
	let amount: Int
}

extension Dollar: ExpressibleByIntegerLiteral {
	init(integerLiteral value: Int) {
		self = Dollar(amount: value)
	}
}

let tenDollars: Dollar = 10
print(tenDollars) // prints 'Dollar(amount: 10)'

{% endhighlight %}

#### ExpressibleByIntegerLiteral and Date

Convenience initializer for a `Date`. Can be useful for hardcoded dates in Unit tests.

{% highlight swift linenos %}

extension Date: ExpressibleByIntegerLiteral {
	public init(integerLiteral value: Int) {
		let formatter = DateFormatter()
		formatter.dateFormat = "MMddyyyy"
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		self = formatter.date(from: String(value)) ?? Date()
	}
}

let date: Date = 01_01_2000
print(date) // prints '2000-01-01 00:00:00 +0000'

{% endhighlight %}

### ExpressibleByNilLiteral

Apple discourages from conforming to `ExpressibleByNilLiteral`. Presently only the `Optional` type conforms to it.

### Applying Initialization with Literals

### Wrapping Up

Swift literal convertibles can be used to provide convenient shorthand initializers for custom objects.

---

*I'd love to meet you in Twitter: [here](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you found it useful.*

---

[extended-grapheme-cluster]: http://unicode.org/reports/tr29/
[unicode-scalar]: https://unicode.org/glossary/#unicode_scalar_value