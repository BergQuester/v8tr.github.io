---
layout: post
title: Delegates Composition and Multicast Delegate
permalink: /delegates-composition-multicast-delegate/
share-img: "/img/core_data_in_swift_4_share_img.png"
---

Delegate is among the most commonly used patterns in iOS apps. Although one-to-one delegation might be suitable for the vast amount of cases, sometimes you need to delegate to more than one object and that is where the canonical pattern begins to falter. Lets implement one-to-many delegation.

### Delegate pattern

**Delegation** is defined as passing responsibility for the behavior implementation from one instance to another. 

Being less formal, a delegate speaks: "I don't know how to implement this method. Please do it for me".

Delegation is a great tool for types composition, which is an alternative to inheritance. The biggest advantage of the former lies in the fact that it creates mutable relationships between types which is way more flexible.

Strictly speaking, such prominent example as `UITableViewDelegate` does not fully comply with this definition. Besides methods similar to `tableView(_,heightForRowAt:)`, that pass their implementation to delegates, there are many tracking methods like `tableView(_,didSelectRowAt:)`, which are much closer to *Observer* pattern rather than the *Delegate*.

### Canonical Implementation

The canonical implementation with single delegate must be no surprise to you.

{% highlight swift linenos %}

protocol MyClassDelegate: class {
	func doFoo()
}

class MyClass {
	weak var delegate: MyClassDelegate?

	func foo() {
		delegate?.doFoo()
	}
}

{% endhighlight %}

Here `MyClass` passes `foo` implementation to its delegate by calling `doFoo` protocol method. 

### Problem Statement

Say, we want to add Logging to `foo` method without introducing any breaking changes to `MyClass`.

{% highlight swift linenos %}

class Logger {}

extension Logger: MyClassDelegate {
	func onFoo() {
		print("Foo called")
	}
}

let logger = Logger()

let myClass = MyClass()
myClass.delegate = delegate

myClass.foo()

{% endhighlight %}

So far so good.

Now imagine that you have decided to add Analytics Tracking to `foo` and `MyClass` does not belong to you, i.e. you cannot change its code. How will you approach it? The answer is multicast delegate.

Lets define requirements to start off with the implementation:
* `MyClass` must stay intact.
* `MyClass` must delegate `foo` to both Logger and Analytics engine.
* The solution must be modular and reusable.

### Multicast Delegate

We begin with `MulticastDelegate` is the core class that holds a collection of delegates and invokes arbitrary blocks of code on them.

{% highlight swift linenos %}

class MulticastDelegate<T> {
	private let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()

	func add(_ delegate: T) {
		delegates.add(delegate as AnyObject)
	}

	func remove(_ delegateToRemove: T) {
		for delegate in delegates.allObjects.reversed() {
			if delegate === delegateToRemove as AnyObject {
				delegates.remove(delegate)
			}
		}
	}

	func invoke(_ invocation: (T) -> Void) {
		for delegate in delegates.allObjects.reversed() {
			invocation(delegate as! T)
		}
	}
}

{% endhighlight %}

Next, lets apply [Composite design pattern](https://en.wikipedia.org/wiki/Composite_pattern) to create a composite delegate that conforms to `MyClassDelegate`. You might want to check [Code Injection][code-injection-article] where discuss how analytics and logging can be extracted from view controller life cycle methods by means of *Objective-C runtime* and *method swizzling*.

{% highlight swift linenos %}

class MyClassMulticastDelegate: MulticastDelegate<MyClassDelegate>, MyClassDelegate {
	func onFoo() {
		invoke { $0.onFoo() }
	}
}

{% endhighlight %}

Now we are ready to add analytics.

{% highlight swift linenos %}

class AnalyticsEngine {}

extension AnalyticsEngine: MyClassDelegate {
	func onFoo() {
		print("Track foo event")
	}
}

let logger = Logger()
let analyticsEngine = AnalyticsEngine()

let delegate = MyClassMulticastDelegate()
delegate.add(logger)
delegate.add(analyticsEngine)

let myClass = MyClass()
myClass.delegate = delegate

myClass.foo()

{% endhighlight %}

### UITableViewDelegate

After we played with dummy example, lets move on to a real world use case where we create multiple delegates for `UISearchBar` to make our search controller very lightweight.

First, define a multicast delegate for a search bar.

{% highlight swift linenos %}

final class SearchBarMulticastDelegate: NSObject, UISearchBarDelegate {

	private let multicast = MulticastDelegate<UISearchBarDelegate>()

	init(delegates: [UISearchBarDelegate]) {
		super.init()
		delegates.forEach(multicast.add)
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		multicast.invoke { $0.searchBarSearchButtonClicked?(searchBar) }
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		multicast.invoke { $0.searchBarCancelButtonClicked?(searchBar) }
	}
}

{% endhighlight %}

Imagine that our search controller needs to display search results every time 'Search' button is clicked. Lets make `SearchResultsController` that responds to search / cancel click events and handled its own presents on `SearchViewController`.

{% highlight swift linenos %}

class SearchResultsController: UIViewController, UISearchBarDelegate {
	private unowned var svc: SearchViewController

	init(_ svc: SearchViewController) {
		self.svc = svc
		super.init(nibName: nil, bundle: nil)
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		// Show over `SearchViewController`
	}

	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		// Hide
	}
}

{% endhighlight %}

And of course, add our favorite analytics and logging.

{% highlight swift linenos %}

extension AnalyticsEngine: UISearchBarDelegate {}
extension Logger: UISearchBarDelegate {}

class SearchViewController: UIViewController {
	let searchBar = UISearchBar()
}

let search = SearchViewController()

let logger = Logger()
let analyticsEngine = AnalyticsEngine()
let searchResults = SearchResultsViewController(search)

let searchBarMulticastDelegate = SearchBarMulticastDelegate(delegates: [logger, analyticsEngine, searchResults])
search.searchBar.delegate = searchBarMulticastDelegate

{% endhighlight %}

Thats it, now `SearchViewController` contains just one line of code and still preserves all required functionality: logging, analytics and even displays search results upon search/cancel click event.

### Wrapping up

---

*I'd love to meet you in Twitter: [here](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you found it useful.*

---

[code-injection-article]: http://www.vadimbulavin.com/code-injection-swift/
[sample-project]: https://github.com/V8tr/CoreData_in_Swift4_Article