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

Sad but true, each of the above classes implements table view delegate and data source methods, registers cells. It might be dealing with keyboard, including keyboard avoidance, custom gestures and explicit handling of return key presses. Furthermore, each class manages their table views as outlets or programmatically. Even more, such code is usually written in imperative manner and does not feel *swifty*. Table view are also difficult to test in isolation, since table data is too coupled with its presentation.

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

Naturally, when adding table to a screen you have two options: a table view or a table view controller, where the former is the most common choice. However, by using `UITableViewController` you can save yourself a lot of efforts, since it provides lots of useful features ready to use, namely:
- Clears cell selection every time table view appears on a screen.
- Flashes scroll indicator when table view ends displaying.
- Puts table in edit mode (exits the edit mode) by tapping Edit (Done) buttons. It also provides keyboard avoidance when in edit mode.
- Provides support for `NSFetchedResultsController` that simplifies managing of *Core Data* requests.

The above means that if we opt in to use table view controllers instead of table views, we can already cut lots of boilerplate code. After agreeing on that, let's see how we can use them in a most efficient way. 

The first thing that should be noted about `UITableViewController` is that it works best when your screen consists from a table view and nothing else. However, we can easily overcome this by embedding it as a child view controller. Here is my personal favorite way of doing it:

{% highlight swift linenos %}

func add(child: UIViewController, container: UIView, configure: (_ childView: UIView) -> Void = { _ in }) {
    addChild(child)
    container.addSubview(child.view)
    configure(child.view)
    child.didMove(toParent: self)
}

{% endhighlight %}

### Reusable Table View Delegate and Data Source

The purpose of table view data source is to tell the table how many sections and rows per section it has, and then provide the data to display. In their turn, delegate methods primarily lend themselves to handle user interaction with the table.

Most of us must have already memorized the signatures of these methods -- so frequently we implement them. Even the simplest table view with dynamic content must contain at least two of these methods - one for cell creation and the other for the number of rows in section.

The next step towards cutting table view boilerplate code is to abstract away the aforementioned protocols into a reusable and extendable solution that can be easily attached to any table view. Furthermore, it must utilize table view controller rather than a plain table view.

#### Step 1: Section model

We want table view rows to be backed by a data model. For this purpose we create a new type that backs a single section with its rows.

{% highlight swift linenos %}

struct Section<Item> {
    var items: [Item]
}

{% endhighlight %}

#### Step 2: Data Source model

Next, let's transform `UITableViewDataSource` protocol into a new type that accepts `Section` as its input and provides a number of convenience methods in top of it.

{% highlight swift linenos %}

struct DataSource<Item> {
    var sections: [Section<Item>]
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfItems(in section: Int) -> Int {
        guard section < sections.count else { return 0 }
        return sections[section].items.count
    }
    
    func item(at indexPath: IndexPath) -> Item {
        return sections[indexPath.section].items[indexPath.row]
    }
}

{% endhighlight %}

The data source is completely unaware of table view. It is also reusable and easy to test.

### Step 3: Table Configurator

Another feature we need is cells registration and configuration. Lets implement a `Configurator` that simplifies this process. First, we need a protocol which has table view cell and its model as associated types. It will allow us to use concrete types instead of `UITableViewCell` to avoid type casting.

{% highlight swift linenos %}

protocol ConfiguratorType {
    associatedtype Item
    associatedtype Cell: UITableViewCell
    
    func reuseIdentifer(for item: Item, indexPath: IndexPath) -> String
    func configure(cell: Cell, item: Item, tableView: UITableView, indexPath: IndexPath) -> Cell
    func registerCells(in tableView: UITableView)
}

{% endhighlight %}

The protocol defines 3 methods responsible for cells registration and configuration. Let's define a concrete implementation of it that handles a single type of cell and model.

struct Configurator<Item, Cell: UITableViewCell>: ConfiguratorType {
    typealias CellConfigurator = (Cell, Item, UITableView, IndexPath) -> Cell
    
    let reuseIdentifier: String
    let configurator: CellConfigurator
    
    func reuseIdentifer(for item: Item, indexPath: IndexPath) -> String {
        return reuseIdentifier
    }
    
    func configure(cell: Cell, item: Item, tableView: UITableView, indexPath: IndexPath) -> Cell {
        return configurator(cell, item, tableView, indexPath)
    }
    
    func registerCells(in tableView: UITableView) {
        tableView.register(Cell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

---

*If this article helped you, tweet it forward.*

"https://twitter.com/intent/tweet?text={{ page.title | url_encode }}+{{ site.url }}{{ page.url }} via @{{ site.author.twitter }}"

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). I would highly appreciate you sharing this article if you find it useful.*

---

[starter-repo]: https://github.com/V8tr/CollectionViewGridLayout-Starter
[final-repo]: https://github.com/V8tr/CollectionViewGridLayout-Final