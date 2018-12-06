---
layout: post
title: "Declarative table view controller or how to stop repeating table view delegate and data source boilerplate"
permalink: /declarative-table-view-controllers/
share-img: ""
---

The standard approach to table view management and data source implementation has a number of flaws, including hard to understand flow of control, cumbersome syntax, error-prone, violation of dependency inversion principle.

### Problem Statement

When looking through you current project's code base, how many table views can you count? Having lots of view controllers utilizing them one way or another is a commonplace in *Swift* projects.

Every *iOS* and *macOS* developer knows that attaching table view to a new view controller inevitably brings some boilerplate code. It takes at least two methods to setup the simplest table view with dynamic data: the one that creates and configures cells and the other one for the number of rows in section.

Taking aside the obvious drawback of repeated code of table view data source methods, let's think about some non-obvious problems:
1. It is difficult to follow the flow of control of table view data source and delegate methods, since they are often placed in different order, are far from each other or even located in different files.
2. The knowledge about which cells are attached to a table view and how cells are instantiated (nib or class) leaks to corresponding view controllers. It violates the [dependency inversion principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle), since module of the higher level (view controller) becomes dependent on the module of lower level (table view cell).
3. Leaves lots of room for mistake, since data source methods must be consistent with each other. For example, if `numberOfRows(inSection:)`, `numberOfSections(in:)` and `tableView(_,cellForRowAt:)` are inconsistent, it results in an unwanted behavior or even crash.
4. When a cell is dequeued from a table view, it has generic `UITableViewCell` type which is in most cases should be type casted to a concrete class.
5. The whole table view data source protocol implementation is imperative which does not feel *Swifty*.

Eventually, what at first glance might have seemed like a trivial task, gradually evolves into technical dept and eats development time and efforts.

After defining the problem, let's implement our own data source on top of `UITableViewDataSource` that satisfies following criteria:
- Reduces boilerplate code, imposed by standard approach to managing table views and their data sources.
- Consistent.
- Has declarative API.
- Decouples cells registration from view controllers and table views.

#### Preconditions

The assumption is made that you are familiar with table views and their setup. If not, I suggest to read [Table View Programming Guide for iOS](https://developer.apple.com/library/archive/documentation/UserExperience/Conceptual/TableView_iPhone/CreateConfigureTableView/CreateConfigureTableView.html) and then return to this article.

### Table View vs. Table View Controller

The first step towards our goal is opt in to use `UITableViewController`. It specializes in managing table views and also comes with some useful features ready-to-use:
- Clear cell selection every time table view appears on a screen.
- Flash scroll indicator when table view ends displaying.
- Put table in edit mode (exit the edit mode) by tapping Edit (Done) buttons. It also provides keyboard avoidance when in edit mode.
- Provide support for `NSFetchedResultsController` that simplifies managing of *Core Data* requests.

Table view controllers work best when interface consists from a table view and nothing else. However it can be easily overcome by adding `UITableViewController` as a child view controller. Here is my favorite way of doing it:

{% highlight swift linenos %}

func add(child: UIViewController, container: UIView, configure: (_ childView: UIView) -> Void = { _ in }) {
    addChild(child)
    container.addSubview(child.view)
    configure(child.view)
    child.didMove(toParent: self)
}

{% endhighlight %}

The `configure` closure is a natural place to setup constraints, like pin table view to `superview` edges. You will see how this method applied in practice a few paragraphs below.

### Implementing Data-Driven Data Source

The purpose of table view data source is to tell the table how many sections and rows per section it has, and then provide the data to display. In their turn, the delegate methods primarily lend themselves to handle user interaction with the table.

The root cause of table view data source methods being inconsistent is that they do not have a single source of truth. The suggested `DataSource` implementation in here to address this issue.

#### Step 1: Section Model

`Section` is a foundational model that represents a single section within a table view. `Item` is defined as a generic to be able to use any custom type.

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

The root cause of table view data source methods being inconsistent has been eliminated, since the implementation is driven by a single source of truth with is the array of sections. Furthermore, it is completely unaware of `UIKit` as well as `UITableView` and can be used to feed any UI component, such as `UIStackView` or `UICollectionView`.

#### Step 3: Table Configurator

The last things in our list are related to cells configuration. The below interface defines common behavior for it.

{% highlight swift linenos %}

protocol ConfiguratorType {
    associatedtype Item
    associatedtype Cell: UITableViewCell
    
    func reuseIdentifier(for item: Item, indexPath: IndexPath) -> String
    func configure(cell: Cell, item: Item, tableView: UITableView, indexPath: IndexPath) -> Cell
    func registerCells(in tableView: UITableView)
}

{% endhighlight %}

`ConfiguratorType` defines 3 methods responsible for cells registration and configuration. 

By means of associated types a table view cell is connected to a model which allows to avoid type casting. Let's implement an extension that demonstrates the idea.

{% highlight swift linenos %}

extension ConfiguratorType {
    
    func configuredCell(for item: Item, tableView: UITableView, indexPath: IndexPath) -> Cell {
        let reuseIdentifier = self.reuseIdentifier(for: item, indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! Cell
        return self.configure(cell: cell, item: item, tableView: tableView, indexPath: indexPath)
    }
}

{% endhighlight %}

`ConfiguratorType` is defined as a protocol to allow different implementations for table views with single and multiple kinds of cells registered.

Fow now let's focus on the first implementation. We'll create another configurator later in this article. 

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
*The configurator enforces a naming convention on table view cells to have their reusable identifiers and nib names to match the name of their class.*

Method `registerCells(in:)` is one of particular interest. It registers cells by nib (if exists) or by class, encapsulating the knowledge of how table view cell is initialized. 

`Configurator` allows to cut even more boilerplate code related to table view cells configuration and registration:
- Automatically register cells in a table view.
- Avoid type casing of dequeued table view cells.
- Associate table view cell with its model.

By that time, all the building blocks have been implemented and are ready to be combined into a final solution.

### Putting It Altogether

Let's create a table view controller driven by `DataSource` and `Configurator`. 

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
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
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

The whole method `setupTable()` contains only 12 lines. It contributes to readability a lot, since everything happens in a single place and the code is declarative. It satisfies the criteria defined at the beginning and does not possess the drawbacks of standard approach to managing table views.

As a bonus, let's examine a more complex case with different kinds of cells in a single table view, where cells are initialized both from nib and class.

### Table View with Mixed Cells

First, a new model that backs cells within table view needs to be created.

{% highlight swift linenos %}

private enum Cell {
    typealias Model = String
    typealias AnotherModel = String
    
    case cell(Model)
    case anotherCell(AnotherModel)
}

{% endhighlight %}

`cell` and `anotherCell` are the two kinds of cells, each with its associated value. Type aliases emphasize that any model can be associated with each kind of cell.

Next, implement a configurator that registers and configures the aforementioned cells.

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

`AggregateConfigurator` is initialized with two single-cell configurators, and forwards protocol methods to the correct ones, based on the type of a cell.

Taking the previous example, the `setupTable()` method is changed as follows:

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

Although the code has increased from 12 lines to 19, it is still expressive and easy-to-understand.

### Summary

The common approach to table view management and data source implementation has a number of flaws, such as: hard to understand flow of control, cumbersome syntax, error-prone, violation of dependency inversion principle.

By combining a reusable table view controller with a data-driven data source we can come up with a solution that does not posses the aforementioned flaws.

The designed solution demonstrates this idea by implementing different practical scenarios.

---

*If you enjoyed reading this article, tweet it forward and subscribe: [@V8tr](https://twitter.com/{{ site.author.twitter }}).*

---

[starter-repo]: https://github.com/V8tr/CollectionViewGridLayout-Starter
[final-repo]: https://github.com/V8tr/CollectionViewGridLayout-Final