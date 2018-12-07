---
layout: post
title: "Declarative table view controller or how to stop repeating table view delegate and data source boilerplate"
permalink: /declarative-table-view-controllers/
share-img: ""
---

### Problem Statement

If you recall your first acquaintance with iOS or macOS development, chances high that it was table view that you first stumbled upon. Indeed, tables are among the most widely used UI components in Cocoa and they are usually implemented by means of `UITableView` or `NSTableView`.

When looking through you current project's code base, how many table views can you count? Having lots of view controllers utilizing them one way or another is a commonplace in *Swift* projects. The below picture for a hypothetical app shows the interaction between some if its view controllers:

<p align="center">
    <a href="{{ "img/declarative-table-view-controllers/table-view-duplication.png" | absolute_url }}">
        <img src="/img/declarative-table-view-controllers/table-view-duplication.png" alt="Declarative Table Views - Duplicated Table View Code"/>
    </a>
</p>

Every iOS and macOS developer knows that attaching table view to a new view controller inevitably brings some boilerplate code. It takes at least two methods to setup the simplest table view with dynamic data: the one that creates and configures cells and the other one for the number of rows in section.

Taking aside the obvious drawback of conforming to the same data source methods again and again, let's think about some non-obvious problems with the standard approach to managing table views:
- It is difficult to follow table view delegate and data source methods, since in source code editor they often appear in different order, far from each other or even in different files. Thus, it often requires manual debugging to follow the flow of control.
- View controllers that manage table views become coupled with table view cells through their registration and configuration. The knowledge about how table view cell is instantiated - either from nib of from class - leaks to view controller. It breaks the dependency inversion principle, since module of the higher level (view controller) becomes dependent on the module of lower level (table view cell).
- Leaves lots of room for mistake, since data source methods must be consistent with each other. For example, if methods `numberOfRows(inSection:)`, `numberOfSections(in:)` and `tableView(_,cellForRowAt:)` become inconsistent, it will result in an unwanted behavior or even crash.
- These methods are written in an imperative manner which does not feel *Swifty*.

All in all, what might have seemed like a trivial task at a first glance, gradually evolves into technical dept and eats development time and efforts.

After defining the problem, let's implement our own data source on top of `UITableViewDataSource` that satisfies following criteria:
- Is data-driven.
- Exposes declarative API.
- Reduces boilerplate code, imposed by standard approach to managing table views and their data sources.
- Decouples cells registration from view controllers and table views.

### Table View vs. Table View Controller

The first step towards our goal is opt in to use `UITableViewController` instead of plain table view. It already specializes in managing the latter and works best when interface consists from a table view and nothing else. It also comes with some useful features ready-to-use:
- Clear cell selection every time table view appears on a screen.
- Flash scroll indicator when table view ends displaying.
- Put table in edit mode (exit the edit mode) by tapping Edit (Done) buttons. It also provides keyboard avoidance when in edit mode.
- Provide support for `NSFetchedResultsController` that simplifies managing of *Core Data* requests.

For interfaces which are more complex that just a table view, it requires some extra setup. In such cases `UITableViewController` could be embedded as a child view controller. Here is my personal favorite way of doing it:

{% highlight swift linenos %}

func add(child: UIViewController, container: UIView, configure: (_ childView: UIView) -> Void = { _ in }) {
    addChild(child)
    container.addSubview(child.view)
    configure(child.view)
    child.didMove(toParent: self)
}

{% endhighlight %}

The `configure` closure is natural place to setup constraints, like pin table view to superview edges. The `container` is often the primary view of the parent view controller. You will see how this method applied in practice a few paragraphs next.

Let's follow this article to see how a table view controller can be used in conjunction with a data-driven data source in a most efficient way. 

### Implementing Data-Driven Data Source

The purpose of table view data source is to tell the table how many sections and rows per section it has, and then provide the data to display. In their turn, the delegate methods primarily lend themselves to handle user interaction with the table.

Most of us must have already memorized the signatures of these methods -- so frequently we implement them. As already been said, we need at least two of those to implement even the simplest table view with dynamic content.

The next step is to abstract away `UITableViewDelegate` protocol into a reusable and extendable solution that can be easily attached to any table view and tested in isolation. Furthermore, it must utilize table view controller rather than a plain table view.

#### Step 1: Section Model

The first thing we do is create a basic data structure that backs a single section within a table view.

{% highlight swift linenos %}

struct Section<Item> {
    var items: [Item]
}

{% endhighlight %}

#### Step 2: Data Source Model

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

Now we could stop worrying that methods `numberOfRows(inSection:)`, `numberOfSections(in:)` and `tableView(_,cellForRowAt:)` might become inconsistent, since the data source derives them based on the sections model provided. Furthermore, it is completely unaware of `UIKit` and can be easily reused and tested in isolation.

#### Step 3: Table Configurator

The last thing we need is cells configuration. When a cell is dequeued from a table view, it has generic `UITableViewCell` type which is in most cases should be type casted to a concrete class. In our solution we will avoid this by means of associated types.

{% highlight swift linenos %}

protocol ConfiguratorType {
    associatedtype Item
    associatedtype Cell: UITableViewCell
    
    func reuseIdentifier(for item: Item, indexPath: IndexPath) -> String
    func configure(cell: Cell, item: Item, tableView: UITableView, indexPath: IndexPath) -> Cell
    func registerCells(in tableView: UITableView)
}

{% endhighlight %}

`ConfiguratorType` defines 3 methods responsible for cells registration and configuration. Let's define an extension that dequeues and configures a cell from a table view.

{% highlight swift linenos %}

extension ConfiguratorType {
    
    func configuredCell(for item: Item, tableView: UITableView, indexPath: IndexPath) -> Cell {
        let reuseIdentifier = self.reuseIdentifier(for: item, indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! Cell
        return self.configure(cell: cell, item: item, tableView: tableView, indexPath: indexPath)
    }
}

{% endhighlight %}

`ConfiguratorType` is defined as a protocol to allow separate implementation for table views that have single kind of cells registered and different kinds of cells correspondingly.

Fow now let's focus on implementation for the homogenous table views. We'll create another configurator later in this article. 

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

The configurator is initialized with a closure that configures a cell with a given item. 

{: .box-note}
*The configurator enforces a naming convention on table view cells to have their reusable identifiers and nib names to match the name of the class.*

Method `registerCells(in:)` is one of particular interest. It registers cells by nib (if exists) or by class, encapsulating the knowledge of how table view cell is initialized. 

`Configurator` allows to cut even more boilerplate code related to table view cells configuration and registration:
- Automatically register cells in a table view.
- Avoid type casing of dequeued table view cells.
- Associate table view cell with its model.

Now we are ready to combine `DataSource`, `Configurator` and `UITableViewController` in a single solution.

### Putting It Altogether

Finally, let's create a table view controller driven by `DataSource` and `Configurator`. 

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

For the purpose of this article `PluginTableViewController` is restricted to 3 methods, although it can be easily extended with the full scope of table view data source methods.

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

That's it, just 12 lines in `setupTable()` method. The code is declarative and easy-to-understand, compared to default table view data source methods. It satisfies the criteria defined at the beginning and does not possess the drawbacks of standard approach to managing table views.

As a bonus, let's examine a more complex case with different kinds of cells in a single table views, where cells are initialized both from nib and class.

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

<!-- "https://twitter.com/intent/tweet?text={{ page.title | url_encode }}+{{ site.url }}{{ page.url }} via @{{ site.author.twitter }}" -->

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). I would highly appreciate you sharing this article if you find it useful.*

---

[starter-repo]: https://github.com/V8tr/CollectionViewGridLayout-Starter
[final-repo]: https://github.com/V8tr/CollectionViewGridLayout-Final