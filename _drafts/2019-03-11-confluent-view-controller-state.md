---
layout: post
title: "Confluent View Controller State"
permalink: /collection-view-cells-self-sizing/
share-img: ""
---

### Problem Statement

When we talk about objects, we often refer to the **state** of the objects to mean the **combination of all the data** in the fields of the objects. 

Consider structure of typical view controller with several UI elements:

```swift
class ViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var emptyStateLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    // Some implementation
}
```

Semantically each property has 2 states:
1. `tableView` — showing or not showing data.
2. `errorLabel` — shown or hidden.
3. `emptyStateLabel` — shown or hidden.
4. `activityIndicator` — shown and animating or hidden and stopped.

Based on the aforementioned definition of *state*, the *combinatorial number* of states grows with *factorial complexity*. That is, the total number of states makes up **24**. At the same time, only the below 4 are meaningful:
1. *Displaying data*. This automatically means that neither error nor empty state label are shown and activity indicator has stopped animating.
2. *Is loading data*
3. *Is showing error*
4. *Empty state*

What about the remaining **20** states? They do not have any semantical meaning, although are syntactical legit. Consider a state: table view displays data, while error is shown and activity indicator is animating. View controller states similar to this one are confluent or degenerate. Even in our simple case, it results in *20* more places to make a mistake, *20* more code paths to cover with tests and overall complicates data and logic flows.

In this article let's focus on making meaningful states explicit and get rid of the confluent view controller states.

### Defining Final State Machine

Final State Machine (FMS)

---

*If you enjoyed reading this article, tweet it forward and subscribe: [@V8tr](https://twitter.com/{{ site.author.twitter }}).*

---