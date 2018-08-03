---
layout: post
title: "Mediator Pattern Case Study"
permalink: /mediator-pattern-case-study/
share-img: "/img/mediator_share.png"
---

Programmers encounter same problems over and over again. The common solution to such problems, that is generic and reusable enough to be used millions of times, is called a design pattern. Lets have a closer look at a mediator pattern that is often unfairly left unnoticed.

### Overview

As already been said, a design pattern is a general solution to an occurring software engineering problem. Its neither code itself nor can be directly transformed into code. A design pattern is rather a template that describes **how** to solve a problem.

Mediator lends itself to solving following problems:
* Tight coupling of objects that directly interact with each other.
* Interaction logic is distributed among a set of objects and cannot be reused.
* Interaction logic is hard to test.
* Interaction logic cannot be changed independently.

Mediator object encapsulates the interaction policies in a hidden and unconstraining way. Objects being manipulated by mediator have no idea it exists. It sits quietly behind the scenes and imposes its policies without their permission or knowledge.

### Case study

Mediator is best demonstrated by a real word example. The code below is taken from the [sample project][sample-project] created for this article.

Imagine, you are adding search history feature to an existing search screen. Here are the use cases to be implemented:
1. Show a list of latest search terms.
2. Add new terms to the list.
3. Preserve search terms when an application is closed.

The below diagram shows components structure.

<p align="center">
    <a href="{{ "img/mediator_1.svg" | absolute_url }}">
        <img src="/img/mediator_1.svg" alt="SearchHistoryMediator UML diagram"/>
    </a>
</p>
 
`HistoryRepository` is an example of [Repository design pattern][repository-def]. It abstracts away details of how search history is persisted.

{% highlight swift linenos %}

protocol HistoryRepository {
    var history: [String] { get }
    func addSearchTerm(_ term: String)
}

{% endhighlight %}

`HistoryView` is a simple interface that removes coupling between `SearchHistoryMediator` and `UIView`:

{% highlight swift linenos %}

protocol HistoryView {
    var isHidden: Bool { get set }
    func setHistory(_ history: [String])
}

{% endhighlight %}

`SearchHistoryMediator` has dependencies injected in initializer. It immediately subscribes for `UISearchBar` events and sets initial state for `HistoryView`. If block-based KVO syntax looks unfamiliar, I recommend checking WWDC session [What's New in Cocoa Touch](https://developer.apple.com/videos/play/wwdc2017/201/), 21m.

{% highlight swift linenos %}

class SearchHistoryMediator: NSObject {
    private let searchBar: UISearchBar
    private var historyView: HistoryView
    private var observasion: NSKeyValueObservation?
    private let historyRepository: HistoryRepository

    init(searchBar: UISearchBar, historyView: HistoryView, historyRepository: HistoryRepository) {
        self.searchBar = searchBar
        self.historyView = historyView
        self.historyRepository = historyRepository
        super.init()

        self.historyView.isHidden = true
        self.historyView.setHistory(historyRepository.history)

        searchBar.delegate = self
        observasion = searchBar.observe(\.text) { [weak self] (searchBar, _) in
            self?.historyView.isHidden = searchBar.text?.isEmpty ?? false
        }
    }
}

{% endhighlight %}

The rest of interaction logic is performed in `UISearchBarDelegate` methods:

{% highlight swift linenos %}

extension SearchHistoryMediator: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        historyView.isHidden = false
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        historyView.isHidden = true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        historyView.isHidden = true
        if let text = searchBar.text, !text.isEmpty {
            historyRepository.addSearchTerm(text)
            historyView.setHistory(historyRepository.history)
            searchBar.text = nil
        }
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        historyView.isHidden = true
        searchBar.resignFirstResponder()
    }
}

{% endhighlight %}

Here are few lines from from `SampleViewController` that show how trivial it is to attach the Mediator to an existing search bar.

{% highlight swift linenos %}

private(set) lazy var mediator: SearchHistoryMediator = {
    return SearchHistoryMediator(searchBar: searchBar, historyView: historyView, historyRepository: historyRepository)
}()

override func viewDidLoad() {
    super.viewDidLoad()
    _ = mediator
}

{% endhighlight %}

### Conclusion

In the above example, the Mediator handles `UISearchBar` events and sets `HistoryView` and `HistoryRepository` states accordingly. The Mediator ensures that components are loosely coupled and they don't call each other explicitly.

Consider using Mediator every time: 
1. Interaction between a set of objects is well defined and complex.
2. A common point of control over a set of objects is required.

Although Mediator is a well-known pattern, it's not as widely used as it could. As long as you clearly understand Mediator usage, it will become a significant tool in your toolset.

[repository-def]: https://msdn.microsoft.com/en-us/library/ff649690.aspx
[sample-project]: https://github.com/V8tr/SearchHistoryMediator
