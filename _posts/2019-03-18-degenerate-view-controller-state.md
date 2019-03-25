---
layout: post
title: "Eliminating Degenerate View Controller States"
permalink: /degenerate-view-controller-states/
share-img: "/img/degenerate-view-controller-states-share.png"
---

The concept of object state is so fundamental that anyone hardly thinks of its definition. In present article let's define what is an object state, which states are called degenerate; how they can be identified and avoided.

### Problem Statement

When we talk about objects, we often refer to the **state** of the objects to mean the **combination of all the data** in the fields of the objects. In other words, each possible combination of Swift `struct` or `class` properties makes up a new state. Hence, the *combinatorial number of states grows with factorial complexity*. For a typical view controller with `4` properties `24` states are derived, most of which are meaningless. Let's call such states **degenerate** and learn how they can be identified and avoided.

### Identifying Degenerate View Controller States

Imagine that you are implementing a view controller that loads data from the network and based on the response does one of the following:
1. Populates table view with data. If there is no data to show, an empty state message is displayed.
2. Shows error label in case of network error.
   
Such view controller is defined as follows:

```swift
class ViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var emptyStateLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    // Some implementation
}
```

From the user experience standpoint, each property has two distinct states or behaviors:
1. `tableView` — showing or not showing data.
2. `errorLabel` — shown or hidden.
3. `emptyStateLabel` — shown or hidden.
4. `activityIndicator` — shown and animating or hidden and stopped.

Arguably, more states could be added to the list; namely: shown and stopped activity indicator, or shown error label without the error message. This highly depends on particular application business logic, user experience, domain area. Not to overcomplicate the example, here and next we assume that the list is comprehensive.

Four states are enough to completely describe view controller's data and logic flow:
1. *Displaying data*
2. *Is loading data*
3. *Is showing error*
4. *Empty state*

What about the remaining **20** states, derived from *combinatorial combination of properties*, as per our definition of state? It's completely possible to have a case where table view displays data, while error message is shown. This one and the remaining 19 states are degenerate and should be avoided, since they result in *20* more places to make a mistake, *20* more code paths to cover with tests and dramatically complicate data and logic flows.

### View Controller as a Finite State Machine

**Finite state machine (FSM)** is an abstract model that can be in exactly one of a finite number of states at any given time. The FSM can change from one state to another in response to some external inputs; such change is called a transition. An FSM is described by:
- List of states.
- Initial state.
- Conditions for each state transition.

To better understand Finite State Machine nature, consider a subway turnstile, governed by a simple FSM. The round rectangles are states; there are only two of them: locked and unlocked. To unlock a turnstile, a person can drop a coin. The arrows are called transitions, since they describe how FSM changes between states [[1]](https://cleancoders.com/episode/clean-code-episode-28/show). The label on a transition has two parts: the name of the event that triggered the transition, and the action to be performed.

<p align="center">
    <a href="{{ "img/fsm-turnstile.svg" | absolute_url }}">
        <img src="/img/fsm-turnstile.svg" alt="Eliminating Degenerate View Controller States"/>
    </a>
</p>

The view controller we defined earlier falls under the definition of Finite State Machine and its life cycle is described on the figure below:

<p align="center">
    <a href="{{ "img/fsm-view-controller.svg" | absolute_url }}">
        <img src="/img/fsm-view-controller.svg" alt="Eliminating Degenerate View Controller States"/>
    </a>
</p>

Here square brackets denote conditions required to trigger a specific transition. The black circle shows initial state, meaning that loading starts immediately after view controller's view had been loaded.

### Implementing View Controller State

Once the states and transitions had been defined, it's a trivial task to translate them into code. There are a number of ways to cut the cake, where one of the most common is `switch / case` statement. The states from the FSM figure are implemented as follows:

```swift
extension ViewController {
    enum State {
        case loading
        case showingData([Item])
        case empty
        case error(Error)
    }   
}
```

Here `Item` represents an entity loaded from the network. Data loading is initiated right in `viewDidLoad` method by means of `ItemService` (which implementation is out of the scope of the present article). Nested `switch / case` statement fully handles state transitions:

```swift
protocol ItemService {
    func loadItems(completion: @escaping (Result<[Item]>) -> Void)
}

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var emptyStateLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    private var items: [Item] = []

    var itemService: ItemService!

    private var state: State = .empty {
        didSet {
            hideAll()
            
            switch state {
            case .empty:
                emptyStateLabel.isHidden = false
            case .error(let error):
                errorLabel.isHidden = false
                errorLabel.text = error.localizedDescription
            case .loading:
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
            case .showingData(let items):
                self.items = items
                tableView.isHidden = false
                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    private func loadData() {
        state = .loading
        
        itemService.loadItems { [weak self] result in
            switch result {
            case .success(let items) where items.isEmpty:
                self?.state = .empty
            case .success(let items):
                self?.state = .showingData(items)
            case .failure(let error):
                self?.state = .error(error)
            }
        }
    }
    
    private func hideAll() {
        tableView.isHidden = true
        errorLabel.isHidden = true
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        emptyStateLabel.isHidden = true
    }
}
```
All four meaningful states are made explicit by being extracting to a distinct type; the transitions are handled in `switch` statement. Data and logic flows are crystal clear and the code is straightforward to read and test. The code makes it impossible to apply degenerate state to the view controller, providing easy and understandable way of setting only the meaningful ones.

### Implementing Finite State Machine via State Pattern

*State design pattern* is another viable implementation of *Finite State Machine*. The core idea is to have a subclass per state, each knowing how to apply itself. The below figure demonstrates the classes structure:

<p align="center">
    <a href="{{ "img/fsm-state-pattern.svg" | absolute_url }}">
        <img src="/img/fsm-state-pattern.svg" alt="Eliminating Degenerate View Controller States"/>
    </a>
</p>

Despite looking daunting at a first spot, the pattern allows to extract state handling code from `ViewController`, being beneficial on large-scale solutions. Let's rework our example to see how Finite State Machine works when state design pattern applied.

First, implement the root `State` class. Static `state(_,viewController:)` is a factory method, which creates one of `State` subclasses based on the supplied `State.Kind`. Method `enter()` is the one that handles state-specific behavior and supposed to be override in subclasses.

```swift
class State {
    
    weak var viewController: ViewController!
    
    init(viewController: ViewController) {
        self.viewController = viewController
    }
    
    static func state(_ state: Kind, viewController: ViewController) -> State {
        switch state {
        case .showingData(let items):
            return ShowingDataState(items: items, viewController: viewController)
        case .loading:
            return LoadingState(viewController: viewController)
        case .empty:
            return EmptyState(viewController: viewController)
        case .error(let error):
            return ErrorState(error: error, viewController: viewController)
        }
    }
    
    func enter() {
        viewController.tableView.isHidden = true
        viewController.errorLabel.isHidden = true
        viewController.activityIndicator.isHidden = true
        viewController.activityIndicator.stopAnimating()
        viewController.emptyStateLabel.isHidden = true
    }
}

extension State {
    
    enum Kind {
        case loading
        case showingData([Item])
        case empty
        case error(Error)
    }
}
```
Next, implement state classes, each knowing how to execute itself.

```swift
final class ShowingDataState: State {
    
    let items: [Item]
    
    init(items: [Item], viewController: ViewController) {
        self.items = items
        super.init(viewController: viewController)
    }
    
    override func enter() {
        super.enter()
        viewController.items = items
        viewController.tableView.isHidden = false
        viewController.tableView.reloadData()
    }
}

final class LoadingState: State {
    
    override func enter() {
        super.enter()
        viewController.emptyStateLabel.isHidden = false
    }
}

final class EmptyState: State {
    
    override func enter() {
        super.enter()
        viewController.emptyStateLabel.isHidden = false
    }
}

final class ErrorState: State {
    
    let error: Error
    
    init(error: Error, viewController: ViewController) {
        self.error = error
        super.init(viewController: viewController)
    }
    
    override func enter() {
        super.enter()
        viewController.errorLabel.isHidden = false
        viewController.errorLabel.text = error.localizedDescription
    }
}
```

`ViewController` should be updated as well to use the factory method:

```swift
class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var emptyStateLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var items: [Item] = []
    
    var itemService: ItemService!
    
    lazy var state = State.state(.empty, viewController: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    private func loadData() {
        state = .state(.loading, viewController: self)
        state.enter()
        
        itemService.loadItems { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let items) where items.isEmpty:
                self.state = .state(.empty, viewController: self)
            case .success(let items):
                self.state = .state(.showingData(items), viewController: self)
            case .failure(let error):
                self.state = .state(.error(error), viewController: self)
            }
            
            self.state.enter()
        }
    }
}
```

The view controller sits quietly and let's concrete states apply their own policies upon it. It comes not without a price: we had to leak encapsulation and make `items` property public. Such tradeoff is common when implementing *state design pattern* and is usually acceptable.

### Conclusion

*State of object* means the combination of all the data in the fields of the object. The number of such combinations increases with factorial complexity, hence gets out of control very quickly. Most of such states are degenerate and must be disallowed on the code level.

Identifying meaningful states and making them explicit by implementing *finite state machine* is the main way of dealing with degenerate object states. The use of `switch / case` operators and *state design pattern* are the most notable ways of *FSM* implementation. Generally, the former suits best for simple cases, while the latter is recommended for large-scale and complex solutions, since it allows to extract state handling policies into specialized classes.

---

*If you enjoyed reading this article, tweet it forward and subscribe: [@V8tr](https://twitter.com/{{ site.author.twitter }}).*

---