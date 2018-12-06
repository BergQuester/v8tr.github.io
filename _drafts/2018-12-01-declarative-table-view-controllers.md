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

Sad but true, each of the above classes implements table view delegate and data source methods, registers cells. It might be dealing with keyboard, including keyboard avoidance, custom gestures and explicit handling of return key presses. Furthermore, each class manages their table views as outlets or programmatically. Even more, such code is usually written in imperative manner and does not feel *swifty*. Table view are also difficult to test in isolation, since table data is too coupled with its presentation. It is also difficult to understand the structure of table view, since data flow is divided between so many methods.

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

The `configure` closure is natural place to setup constraints, like pin table view to superview edges. The `container` is often primary view of parent view controller.

### Reusable Table View Delegate and Data Source

The purpose of table view data source is to tell the table how many sections and rows per section it has, and then provide the data to display. In their turn, delegate methods primarily lend themselves to handle user interaction with the table.

Most of us must have already memorized the signatures of these methods -- so frequently we implement them. Even the simplest table view with dynamic content must contain at least two of these methods - one for cell creation and the other for the number of rows in section.

The next step towards cutting table view boilerplate code is to abstract away the aforementioned protocols into a reusable and extendable solution that can be easily attached to any table view and tested in isolation. Furthermore, it must utilize table view controller rather than a plain table view.

#### Step 1: Section model

The first thing we do is create a basic data structure that will be backing table views.

{% highlight swift linenos %}

struct Section<Item> {
    var items: [Item]
}

{% endhighlight %}

#### Step 2: Data Source model

Next, let's define a data-driven data source that accepts `Section`s as its input and provides a number of convenience methods in top of them. 

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

The data-driven nature of data source allows to cut off `UITableViewDataSource` methods that define number of sections and number of rows in section.

#### Step 3: Table Configurator

The last thing we need is cells configuration. When cell is dequeued from table view, it has generic `UITableViewCell` type which is in most cases should be type casted to a concrete type. In our solution we will avoid this by associating `Item` data model with a cell class.

{% highlight swift linenos %}

protocol ConfiguratorType {
    associatedtype Item
    associatedtype Cell: UITableViewCell
    
    func reuseIdentifier(for item: Item, indexPath: IndexPath) -> String
    func configure(cell: Cell, item: Item, tableView: UITableView, indexPath: IndexPath) -> Cell
    func registerCells(in tableView: UITableView)
}

{% endhighlight %}

The protocol defines 3 methods responsible for cells registration and configuration. Let's define an extension that dequeues and configures a cell from a table view.

{% highlight swift linenos %}

extension ConfiguratorType {
    
    func configuredCell(for item: Item, tableView: UITableView, indexPath: IndexPath) -> Cell {
        let reuseIdentifier = self.reuseIdentifier(for: item, indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! Cell
        return self.configure(cell: cell, item: item, tableView: tableView, indexPath: indexPath)
    }
}

{% endhighlight %}

The main reason for making `ConfiguratorType` a protocol rather than a concrete type is support of different kinds of cells within single table view. Let's focus on implementation for the homogenous table views first. We'll create another configurator later in this article. 

{% highlight swift linenos %}

struct Configurator<Item, Cell: UITableViewCell>: ConfiguratorType {
    typealias CellConfigurator = (Cell, Item, UITableView, IndexPath) -> Cell
    
    let configurator: CellConfigurator
    let reuseIdentifier = "\(Cell.self)"
    
    func reuseIdentifier(for item: Item, indexPath: IndexPath) -> String {
        return reuseIdentifier
    }
    
    func configure(cell: Cell, item: Item, tableView: UITableView, indexPath: IndexPath) -> Cell {
        return configurator(cell, item, tableView, indexPath)
    }
    
    func registerCells(in tableView: UITableView) {
        if let path = Bundle.main.path(forResource: "\(Cell.self)", ofType: "nib"),
            FileManager.default.fileExists(atPath: path) {
            let nib = UINib(nibName: "\(Cell.self)", bundle: .main)
            tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        } else {
            tableView.register(Cell.self, forCellReuseIdentifier: reuseIdentifier)
        }
    }
}

{% endhighlight %}

The configurator is initialized with a closure that configures table view cell with a given item. It also enforces a common convention on table view cell reusable identifiers and nibs to match the name of corresponding cell class.

Method `registerCells(in:)` is one of particular interest. It registers cells by nib (if exists) or by class, encapsulating the knowledge of how table view cell initialized. 

`Configurator` allows to cut lots of boilerplate code related to table view cells configuration and registration:
- Automatically register cells in a table view.
- Avoid type casing of dequeued table view cells.
- Associate table view cell with its model.

Now we are ready to combine `DataSource`, `Configurator` and `UITableViewController` in a single solution.

### Putting It Altogether

Finally, let's create a table view controller driven by `DataSource` and `Configurator` that we just defined. 

{% highlight swift linenos %}

class PluginTableViewController<Item, Cell: UITableViewCell>: UITableViewController {
    
    let dataSource: DataSource<Item>
    let configurator: Configurator<Item, Cell>
    
    init(dataSource: DataSource<Item>, configurator: Configurator<Item, Cell>) {
        self.dataSource = dataSource
        self.configurator = configurator
        super.init(nibName: nil, bundle: nil)
        configurator.registerCells(in: tableView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfItems(in: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = dataSource.item(at: indexPath)
        return configurator.configuredCell(for: item, tableView: tableView, indexPath: indexPath)
    }
}

{% endhighlight %}

For the demonstration purpose `PluginTableViewController` is restricted to core methods, although it can be easily extended with the full scope of table view data source methods.

To see how it plays in action, let's attach it to a view controller.

{% highlight swift linenos %}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    }
    
    func setupTable() {
        let section0 = Section(items: ["A", "B", "C"])
        let section1 = Section(items: ["1", "2", "3"])
        let dataSource = DataSource(sections: [section0, section1])

        let configurator = Configurator { (cell, model: String, tableView, indexPath) -> TableCell in
            cell.textLabel?.text = model
            return cell
        }
        
        let table = PluginTableViewController(dataSource: dataSource, configurator: configurator)
        
        add(child: table, container: view)
    }
}

{% endhighlight %}

That's it, just 12 lines in `setupTable()` method. The code is declarative and easy-to-understand, compared to default table view data source methods. It is easy to follow, since everything is contained in a single method, instead of being spread between a number of methods or even files.

As a bonus, let's examine a more complex case with a table view that contains cells of different type, defined both in a nib and a class.

### Table View with Heterogenous Cells

Let's define another model backing table view cells which a enum with two kinds of cells, each with its own associated value:

{% highlight swift linenos %}

private enum Cell {
    typealias Model = String
    typealias AnotherModel = String
    
    case cell(Model)
    case anotherCell(AnotherModel)
}

{% endhighlight %}

It can be any type instead of `String` associated with `cell` and `anotherCell`. To emphasize that let's define them as type aliases.

The new configurator will aggregate several single-cell configurators and forward calls to them.

{% highlight swift linenos %}

struct AggregateConfigurator: ConfiguratorType {
    let cellConfigurator: Configurator<Cell.Model, TableCell>
    let anotherCellConfigurator: Configurator<Cell.AnotherModel, NibCell>
    
    func reuseIdentifier(for item: Cell, indexPath: IndexPath) -> String {
        switch item {
        case .cell:
            return cellConfigurator.reuseIdentifier
        case .anotherCell:
            return anotherCellConfigurator.reuseIdentifier
        }
    }
    
    func configure(cell: UITableViewCell, item: Cell, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch item {
        case .cell(let model):
            return cellConfigurator.configuredCell(for: model, tableView: tableView, indexPath: indexPath)
        case .anotherCell(let model):
            return anotherCellConfigurator.configuredCell(for: model, tableView: tableView, indexPath: indexPath)
        }
    }
    
    func registerCells(in tableView: UITableView) {
        cellConfigurator.registerCells(in: tableView)
        anotherCellConfigurator.registerCells(in: tableView)
    }
}

{% endhighlight %}

`AggregateConfigurator` is initialized with two other configurators - one for each cell type, and forwards calls to them to satisfy the protocol. It's an example of Composite design patter. You can read more about it here, or check some practical use cases in **[link to article]**.

And now let's put things together in a parent view controller. We are using the same `setupTable()` method as before:

{% highlight swift linenos %}

func setupTable() {
    let section0 = Section<Cell>(items: [.cell("A"), .cell("B"), .cell("C")])
    let section1 = Section<Cell>(items: [.anotherCell("1"), .anotherCell("2"), .anotherCell("3")])
    let dataSource = DataSource(sections: [section0, section1])
    
    let configurator1 = Configurator { (cell, model: Cell.Model, tableView, indexPath) -> TableCell in
        cell.textLabel?.text = model
        return cell
    }
    
    let configurator2 = Configurator { (cell, model: Cell.AnotherModel, tableView, indexPath) -> NibCell in
        cell.textLabel?.text = model
        return cell
    }
    
    let aggregate = AggregateConfigurator(cellConfigurator: configurator1, anotherCellConfigurator: configurator2)
    
    let table = PluginTableViewController(dataSource: dataSource, configurator: aggregate)
    
    add(child: table, container: view)
}

{% endhighlight %}

Although the code has increased from 12 lines to 19, it is still expressible and easy-to-understand.

### Summary

---

*If this article helped you, tweet it forward.*

"https://twitter.com/intent/tweet?text={{ page.title | url_encode }}+{{ site.url }}{{ page.url }} via @{{ site.author.twitter }}"

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). I would highly appreciate you sharing this article if you find it useful.*

---

[starter-repo]: https://github.com/V8tr/CollectionViewGridLayout-Starter
[final-repo]: https://github.com/V8tr/CollectionViewGridLayout-Final