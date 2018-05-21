---
layout: post
title: Multicast Delegate and Delegates Composition
permalink: /multicast-delegate/
share-img: "/img/multicast_delegate_share.png"
---

Delegate is among the most commonly used patterns in iOS apps. Although one-to-one delegation might be suitable for the majority of cases, sometimes you need to delegate to more than one object and that is where the canonical pattern begins to falter.

### Delegate pattern

**Delegation** is defined as passing responsibility for the behavior implementation from one instance to another. 

When an instance delegates some if its behavior, it speaks: "I don't know how to implement this method. Please do it for me".

*Delegation* is a great tool for objects composition, which is an alternative to inheritance. The biggest advantage of the former lies in the fact that it creates mutable relationships between objects which is way more flexible than the static ones introduce by inheritance.

Strictly speaking, such well-known example as `UITableViewDelegate` does not fully comply with this definition. Besides methods similar to `tableView(_,heightForRowAt:)`, that indeed pass their implementation to delegates, there are many tracking methods like `tableView(_,didSelectRowAt:)`, which are much closer to the *Observer* pattern rather than the *Delegate*.

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
    func doFoo() {
        print("Foo called")
    }
}

let logger = Logger()

let myClass = MyClass()
myClass.delegate = delegate

myClass.foo()

{% endhighlight %}

So far so good.

Now imagine that you have decided to add analytics tracking to `foo` and `MyClass` does not belong to you, i.e. you cannot change its code. How will you approach it? The answer is **delegates composition** (aka **multicast delegate**).

{: .box-note}
 *You might check [Code Injection][code-injection-article] where we discuss how analytics and logging can be extracted from view controller life cycle methods by means of Objective-C runtime and method swizzling.*

Lets define requirements to start off with the implementation:
* `MyClass` must stay intact.
* `MyClass` must delegate `foo` to both logging and analytics engines.
* The solution must be generic and reusable.

### Multicast Delegate

We begin with `MulticastDelegate` which is a utility class that holds a number of delegates and invokes arbitrary blocks of code on them. We chose `NSHashTable` to store weak references to delegates.

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

Next, lets apply [Composite design pattern](https://en.wikipedia.org/wiki/Composite_pattern) to create a composite delegate that conforms to `MyClassDelegate`.

{% highlight swift linenos %}

class MyClassMulticastDelegate: MulticastDelegate<MyClassDelegate>, MyClassDelegate {
    func doFoo() {
        invoke { $0.doFoo() }
    }
}

{% endhighlight %}

Now we are ready to add analytics.

{% highlight swift linenos %}

class AnalyticsEngine {}

extension AnalyticsEngine: MyClassDelegate {
    func doFoo() {
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

That's it: now both analytics engine and logger have `doFoo` called.

### Practical example: UISearchBarDelegate

After playing with dummy example, lets move on to a real world use case where we create multiple delegates for `UISearchBar` to make our search controller very lightweight.

First, define a multicast delegate for a search bar that listens for *UISearchBarDelegate* callbacks and propagates them further.

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

Imagine that we have a search controller that displays search results every time *'Search'* button is tapped.

{% highlight swift linenos %}

class SearchViewController: UIViewController {
    let searchBar = UISearchBar()
}

{% endhighlight %}

You ask where all the code gone? Keep reading to see the twist 😉.

Lets implement `SearchResultsController` that responds to `UISearchBarDelegate` events and presents itself over the search controller.

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
        // Hide from `SearchViewController`
    }
}

{% endhighlight %}

Search controller must be unaware of analytics and logging, so we have them added as search bar delegates. They just need to conform to `UISearchBarDelegate` protocol and be composed into multicast delegate.

{% highlight swift linenos %}

extension AnalyticsEngine: UISearchBarDelegate {}
extension Logger: UISearchBarDelegate {}

let search = SearchViewController()

let logger = Logger()
let analyticsEngine = AnalyticsEngine()
let searchResults = SearchResultsViewController(search)

let searchBarMulticastDelegate = SearchBarMulticastDelegate(delegates: [logger, analyticsEngine, searchResults])
search.searchBar.delegate = searchBarMulticastDelegate

{% endhighlight %}

That's it, now `SearchViewController` contains just one line of code and still preserves all required functionality: logging, analytics and even displays search results upon search/cancel tap events.

### Wrapping up

*Multicast delegation* is a useful technique that is based on *Composite* design pattern.

We have learned how to implement reusable *multicast delegate* in Swift that preserves weak references and propagates arbitrary blocks of code to its inner delegates.

By the `UISearchBar` example we have shown how *multicast delegate* can be used to design our search view controller very lightweight, reduce coupling between objects and make our code modular and reusable.

---

*I'd love to meet you in Twitter: [here](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you found it useful.*

---

[code-injection-article]: http://www.vadimbulavin.com/code-injection-swift/
[sample-project]: https://github.com/V8tr/CoreData_in_Swift4_Article