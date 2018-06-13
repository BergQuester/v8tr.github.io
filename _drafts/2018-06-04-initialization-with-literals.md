---
layout: post
title: Designing Richer API Using Initialization with Literals
permalink: /initialization-with-literals/
share-img: "/img/multicast_delegate_share.png"
---

### Introduction

*“Indeed, the ratio of time spent reading versus writing is well over 10 to 1. We are constantly reading old code as part of the effort to write new code. ...[Therefore,] making it easy to read makes it easier to write.” - Robert C. Martin*

Rephrasing Robert Martin, one should not neglect readability of their code in favor of speed of writing it. In this post we'll see how *Initialization with Literals* can help us to build more expressible and richer APIs.

### Explaining Initialization with Literals

Swift has a family of `ExprissibleByLiteral` protocols that allows structs, classes and enums to be initialized using a *literal*. 

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

`ExpressibleByStringLiteral` stands for a type that can be initialized with a string literal. The initializer `init(stringLiteral: Self.StringLiteralType)` is the only method that needs to be implemented for this protocol conformance.

`ExpressibleByExtendedGraphemeClusterLiteral` stands for the type that can be initialized with a string containing a *single* extended grapheme cluster, e.g. "ந". More about the extended grapheme clusters can be found in [Unicode standard][extended-grapheme-cluster]. 

`ExpressibleByUnicodeScalarLiteral` can be initialized with a string containing a *single* [Unicode scalar][unicode-scalar] value. e.g. "♥".

When conforming to `ExpressibleByStringLiteral`, you should always evaluate whether your type can be initialized from a *Unicode scalar* and a *Grapheme Cluster literal*, and implement them as well.

#### ExpressibleByStringLiteral and URL

When defining manually typed URLs and URL requests, it is handful to initialize them with a strings omitting `URL`'s initializer.

{% highlight swift linenos %}

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = URL(string: value)!
    }
}

{% endhighlight %}

Now both URL and URL request can be initialized with a string:

{% highlight swift linenos %}

let url: URL = "https://www.vadimbulavin.com"
print(url) // prints 'https://www.vadimbulavin.com'

let request = URLRequest(url: "https://www.vadimbulavin.com")
print(request) // prints 'https://www.vadimbulavin.com'

{% endhighlight %}

#### ExpressibleByStringLiteral and NSRegularExpression

Swift borrows `NSRegularExpression` class from Objective-C. We can write our own wrapper over it adding some syntactic sugar:

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
print(regex.matches(in: "abc")) // prints that match is found

{% endhighlight %}

### ExpressibleByIntegerLiteral

`ExpressibleByIntegerLiteral` represents a type that can be initialized with an integer *literal*.

#### ExpressibleByIntegerLiteral and UILayoutPriority

The [pre-defined auto layout priorities][uilayoutpriority-docs] are often not enough to express complex constraints. Lets define convenience methods to set custom `UILayoutPriority`.

{% highlight swift linenos %}

extension UILayoutPriority: ExpressibleByIntegerLiteral {
	public init(integerLiteral value: Int) {
		self.init(rawValue: Float(value))
	}
}

extension NSLayoutConstraint {
	func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
		self.priority = priority
		return self
	}
}

{% endhighlight %}

Now you can set custom priorities with an integer:

{% highlight swift linenos %}

let label = UILabel()
label.setContentHuggingPriority(1, for: .horizontal)

let anotherLabel = UILabel()
label.leadingAnchor.constraint(equalTo: anotherLabel.leadingAnchor).withPriority(1).isActive = true

{% endhighlight %}

#### ExpressibleByIntegerLiteral and Date

Convenience initializer for a `Date`. Especially useful for hardcoded dates in Unit tests.

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

Apple [discourages][expressiblebynilliteral-docs] from conforming to `ExpressibleByNilLiteral` for custom types. Presently only the `Optional` type conforms to it, which is used to express the **absence** of a value. The following example demonstrates incorrect usage of `ExpressibleByNilLiteral` that confuses the notion of *absence of value* with *zero value*.

{% highlight swift linenos %}

struct MyStruct {
	let value: Int
}

extension MyStruct: ExpressibleByNilLiteral {
	init(nilLiteral: ()) {
		self = MyStruct(value: 0)
	}
}

let myStruct: MyStruct = nil
print(myStruct) // prints 'MyStruct(value: 0)'

{% endhighlight %}

Always use the `Optional` type to express the notion of value absence.

### ExpressibleByArrayLiteral

Conform to `ExpressibleByArrayLiteral` protocol when implementing custom collections that are backed by an *Array*, ex. *Stack, Graph, Queue, LinkedList* etc. Here is a simple example of a `Sentence` collection that demonstrates the idea.

{% highlight swift linenos %}

struct Sentence {
	let words: [String]
}

extension Sentence: ExpressibleByArrayLiteral {
	init(arrayLiteral elements: String...) {
		self = Sentence(words: elements)
	}
}

{% endhighlight %}

{: .box-note}
*Array type and the array literal are different things. This means that you can’t initialize a type that conforms to `ExpressibleByArrayLiteral` by assigning an existing array to it.*

According to the above, the following example does not compile:

{% highlight swift linenos %}

let sentence: Sentence = ["A", "B", "C"]
print(sentence) // prints 'Sentence(words: ["A", "B", "C"])'

let words = ["A", "B", "C"]
let anotherSentence: Sentence = words // error: Cannot convert value of type '[String]' to specified type 'Sentence'

{% endhighlight %}

### ExpressibleByDictionaryLiteral

Similar to its Array counterpart, `ExpressibleByDictionaryLiteral` is primarily used for custom collections and types that are backed by Dictionary. HTTP request headers are among such examples.

{% highlight swift linenos %}

struct HTTPHeaders {
	private let headers: [String: String]
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
	init(dictionaryLiteral elements: (String, String)...) {
		var headers: [String: String] = [:]
		for pair in elements {
			headers[pair.0] = pair.1
		}
		self = HTTPHeaders(headers: headers)
	}
}

{% endhighlight %}

{: .box-note}
*A dictionary literal should not be confused with an instance of Dictionary. Thus it is not possible to initialize a type that conforms to `ExpressibleByDictionaryLiteral` by assigning a Dictionary instance to it.*

And here is an example that demonstrates the above nuance:

{% highlight swift linenos %}

let headers: HTTPHeaders = ["Content-Type": "application/json"]
print(headers) // prints 'HTTPHeaders(headers: ["Content-Type": "application/json"])'

let headersDictionary = ["Content-Type": "application/json"] // headersDictionary is an instance of Dictionary, not a Dictionary literal
let anotherHeaders: HTTPHeaders = headersDictionary // error: Cannot convert value of type '[String : String]' to specified type 'HTTPHeaders'

{% endhighlight %}

### Wrapping Up

*Literal* is a notation for representing a fixed *value* in source code. Integers, strings, booleans, floating-points, arrays, dictionaries are all literals.

An instance of *Array* and an *array literal* are two different notions and they should not be confused. The same is true for *Dictionary*.

Swift contains a family of `ExpressibleByLiteral` protocols that are used for custom types to be initialized with a matching *literal*.

A number of practical examples were examined to demonstrate that *Initialization with Literals* can make your API more clean and direct.

[extended-grapheme-cluster]: http://unicode.org/reports/tr29/
[unicode-scalar]: https://unicode.org/glossary/#unicode_scalar_value
[uilayoutpriority-docs]: https://developer.apple.com/documentation/uikit/uilayoutpriority
[expressiblebynilliteral-docs]: https://developer.apple.com/documentation/swift/expressiblebynilliteral