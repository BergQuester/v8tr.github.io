---
layout: post
title: "Declarative table view controller or how to stop repeating table view delegate and data source boilerplate"
permalink: /declarative-table-view-controllers/
share-img: ""
---

### Problem Statement

If you recall your first acquaintance with iOS or macOS development, chances high that it was table view that you first learned. Indeed, tables are probably among the most widely adopted UI components in Cocoa and `UITableView` or `NSTableView` is the key control when it comes to their implementation.

When looking through you current project's code base, how many table views can you count? Imagine yourself working on a e-commerce app. Then the below picture might be the case for you:

<br/>

<p align="center">
    <a href="{{ "img/declarative-table-view-controllers/table-view-duplication.png" | absolute_url }}">
        <img src="/img/declarative-table-view-controllers/table-view-duplication.png" alt="Declarative Table Views - Duplicated Table View Code"/>
    </a>
</p>

<br/>

Sad but true, each of the above classes implements table view delegate and data source methods, registers cells. It might be dealing with keyboard, including keyboard avoidance, custom gestures and explicit handling of return key presses. Furthermore, each class manages their table views as outlets or programmatically. Even more, such code is usually written in imperative manner and does not feel *swifty*.

What might have seemed like a small task at first glance, gradually evolves into technical dept and eats development time and efforts. In present article lets discuss what can we do better about it and focus on following aspects of the problem:

- Remove duplication of table view delegate and data source methods.
- Use declarative approach rather than imperative which is imposed by standard Cocoa API.
- Extract boilerplate such as cells registration and keyboard handling. 

<!-- - Table views code usually duplicated
- Diagram with multiple screens that use table view and duplicate data source, delegate methods
- Step forward: plugin controllers + remove boilerplate delegate and data source methods
- Benefits: investigate benefits of using table view controller over table view
- Introduce custom solution   -->

### Table View vs. Table View Controller

Table view controllers were designed to be used when interface consists from a table view and nothing else. Thus, they are 


We come up with an out-of-the-box solution to one of the stated problems by use of Table View Controllers.

Usage of table view controllers over table views can help us resolve one from the above points without much efforts. Additionally, it offers some nice functionality for free.

Apple [suggests](https://developer.apple.com/documentation/uikit/uitableviewcontroller) to use table view controllers when an interface consists from a table view and nothing else. We can easily overcome this by embedding them as children. Here is one of the ways to implement this:

{% highlight swift linenos %}

func add(child: UIViewController, container: UIView, configure: (_ childView: UIView) -> Void = { _ in }) {
    addChild(child)
    container.addSubview(child.view)
    configure(child.view)
    child.didMove(toParent: self)
}

{% endhighlight %}

---

*If this article helped you, tweet it forward.*

"https://twitter.com/intent/tweet?text={{ page.title | url_encode }}+{{ site.url }}{{ page.url }} via @{{ site.author.twitter }}"

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). I would highly appreciate you sharing this article if you find it useful.*

---

[starter-repo]: https://github.com/V8tr/CollectionViewGridLayout-Starter
[final-repo]: https://github.com/V8tr/CollectionViewGridLayout-Final