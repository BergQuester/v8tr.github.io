---
layout: post
title: Multicast Delegate in Swift
permalink: /multicast-delegate-swift/
share-img: "/img/core_data_in_swift_4_share_img.png"
---

Delegate is among the most commonly used patterns in iOS apps. Although one-to-one delegation might be suitable for the vast amount of cases, sometimes you need to delegate to more than one object and that is where the canonical pattern begins to falter. Lets implement one-to-many delegation.

### Delegate pattern

**Delegation** is defined as passing responsibility for the behavior implementation from one instance to another. 

Being less formal, a delegate speaks: "I don't know how to implement this method. Please do it for me".

Delegation is a great tool for types composition, which is an alternative to inheritance. The biggest advantage of the former lies in the fact that it creates mutable relationships between types which is way more flexible.

Strictly speaking, such prominent example as `UITableViewDelegate` does not fully comply with this definition. Besides methods similar to `tableView(_,heightForRowAt:)`, that pass their implementation to delegates, there are many tracking methods like `tableView(_,didSelectRowAt:)`, which are much closer to *Observer* pattern rather than the *Delegate*.

### Canonical Implementation

The canonical implementation with single delegate looks as follows.

{% highlight swift linenos %}

protocol MyClassDelegate: class {
	func onFoo()
}

class MyClass {
	weak var delegate: MyClassDelegate?

	func foo() {
		delegate?.onFoo()
	}
}

{% endhighlight %}

---

*I'd love to meet you in Twitter: [here](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you found it useful.*

---

[private-concurrency-type]: https://developer.apple.com/documentation/coredata/nsmanagedobjectcontextconcurrencytype/1506495-privatequeueconcurrencytype
[fetch-request-docs]: https://developer.apple.com/documentation/coredata/nsfetchrequest
[fetching-managed-objects-article]: https://developer.apple.com/library/content/documentation/DataManagement/Conceptual/CoreDataSnippets/Articles/fetching.html
[managed-object-context-docs]: https://developer.apple.com/documentation/coredata/nsmanagedobjectcontext
[sample-project]: https://github.com/V8tr/CoreData_in_Swift4_Article