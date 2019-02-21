---
layout: post
title: "Dynamic Collection View Cells Sizing: Step by Step Tutorial"
permalink: /collection-view-cells-dynamic-height/
share-img: ""
---

When working with collection views, chances high that you have spent considerable amount of time sizing cells programmatically. In this article you will learn how UICollectionViewCells can dynamically adjust their size based on their content.

### Problem Statement

Considering that iOS and macOS are becoming more and more complex, dynamic fonts and internationalization are must have features for every app. To support these features, going "all-dynamic user interface" strategy is almost always the best choice.

While dynamic sizing for table view cells is used extensively, the exactly same feature for collection views is unjustly left unnoticed. Being around [since iOS 8](https://developer.apple.com/documentation/uikit/uicollectionviewflowlayout/1617709-estimateditemsize), `UICollectionViewCells` self-sizing is still not as widely adopted as it could be. This might be partially explained by numerous non-obvious pitfalls which arise when trying to implement collection view cells with dynamic size and lack of tutorials covering these pitfall in detail.

With regards to collection view cells sizing three strategies exist:
- Layout Property - `UICollectionViewFlowLayout.itemSize`
- Delegate - `collectionView(layout:sizeForItemAt:)`
- Cell - self-sizing cells

*Self-sizing cells strategy* is usually the most preferable among all, since it allows to encapsulate the layout details inside a cell instead of leaking to view controller code.

There are two ways to cut the cake:
- Autolayout sizing: add constraints to `cell.contentView`.
- Manual-sizing code: Override `sizeThatFits`.

The former solution is usually more compelling as it allows to setup sizing by means of the auto layout engine without writing a single line of code. 

Dynamic sizing for table view cells is used extensively, while the exactly same feature for collection views is unjustly left unnoticed. Being around [since iOS 8](https://developer.apple.com/documentation/uikit/uicollectionviewflowlayout/1617709-estimateditemsize), `UICollectionViewCells` self-sizing is still not as widely adopted as it could be. This might be partially explained by numerous non-obvious pitfalls which arise when trying to implement collection view cells with dynamic size and lack of tutorials covering these pitfall in detail.

In present article let's implement `UICollectionView` with custom cells which size themselves dynamically to fit their content.

### Starter Project

**DONT FORGET TO INSERT CORRECT LINK TO STARTER PROJECT**

Let's begin with a fresh project. In order not to spend your time on writing boilerplate code and project setup, since it is something you've done hundreds of times before, I've got you covered and created a starter project.

Let's begin coding in a fresh project. In order not to spend your time on writing boilerplate code and project setup, since it is something you've done dozens of times before, I've got you covered and created a starter project.

To ensure that we are on the same page and in order to get straight to the point, grab [this starter project](https://developer.apple.com/documentation/uikit/uicollectionviewflowlayout/1617709-estimateditemsize) and briefly glance through the files.

Here are few things to note from the starter project:
1. `ViewController` is an empty view controller subclass with an attached collection view.
2. If you run the project, it will crash, because collection view data source and delegate are wired up inside a storyboard, but not implemented. We'll fix that later.
3. `Item` is a model class that backs collection view cells.
4. `ViewController` holds an array of `items` with placeholder texts which will drive collection view cells rendering.
   
{: .box-note}
*Wondering why this is it important to have models for collection view cells even for a small tutorial like this? Then you can read my recent article about [data-driven table view](({{ "/data-drive-table-views/" | absolute_url }})) where it is explained in detail.*
   
### Creating Custom Collection View Cell

Let's implement a simple `UICollectionViewCell` subclass with a single label.

First, create a new file `CollectionCell.swift` with the following code:

```swift
class CollectionCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}
```

Second, setup cell prototype in `Main.storyboard`. This step leaves room for mistake, hence detailed explanation of the process:

1\. Go to `Main.storyboard` and select `ViewController`. It already has a collection view with a cell prototype added. Set the cell's class **and** reuse identifier to `CollectionCell`. The result looks next:
<p align="center">
    <a href="{{ "img/collection-view-cells-dynamic-height/cell-setup-1.png" | absolute_url }}">
        <img src="/img/collection-view-cells-dynamic-height/cell-setup-1.png" alt="Dynamic Collection View Cells Sizing: Step by Step Tutorial"/>
    </a>
</p>
   
2\. Add a label and pin it to the edges of the cell. The good practice is to set title's text to something meaningful, e.g. *"[Title]"*.
<p align="center">
    <a href="{{ "img/collection-view-cells-dynamic-height/cell-setup-2.png" | absolute_url }}">
        <img src="/img/collection-view-cells-dynamic-height/cell-setup-2.png" alt="Dynamic Collection View Cells Sizing: Step by Step Tutorial"/>
    </a>
</p>

3\. Connect the label with the property `titleLabel` which was defined in `CollectionCell.swift` earlier.
<p align="center">
    <a href="{{ "img/collection-view-cells-dynamic-height/cell-setup-3.png" | absolute_url }}">
        <img src="/img/collection-view-cells-dynamic-height/cell-setup-3.png" alt="Dynamic Collection View Cells Sizing: Step by Step Tutorial"/>
    </a>
</p>

### Configure UICollectionViewFlowLayout

Dynamic cells sizing is a feature of `UICollectionViewFlowLayout`. In order to support it, the layout's `estimatedItemSize` property must be set to a non-zero value. It is an equivalent for estimated row height in table views.

When the estimated size is set, the flow layout computes a first approximation of cells arrangement, and then re-calculates it when the updated attributes are received. Hence it will boost the performance if estimated size is close to the actual one.

{: .box-note}
*If you would like to learn which steps views undergo before being drawn on the screen, I recommend reading [my article on the subject](({{ "/data-drive-table-views/" | absolute_url }})).*

Getting back to the code, let's configure the layout:

1. Drag `collectionLayout` from the storyboard and create a new property.
2. Supply automatic size in `didSet` method:

```swift
collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
```

The result looks next:
<p align="center">
    <a href="{{ "img/collection-view-cells-dynamic-height/layout-setup-1.png" | absolute_url }}">
        <img src="/img/collection-view-cells-dynamic-height/layout-setup-1.png" alt="Dynamic Collection View Cells Sizing: Step by Step Tutorial"/>
    </a>
</p>

### Enabling Horizontal Self Sizing

Here goes the non-obvious pitfall: by default cell content view prevents self-sizing, given that it does not have auto layout enabled.

To address that, we need to explicitly pin content view to the edges of the cell. Open `CollectionCell.swift` and paste the following code which does exactly that:

```swift
override func awakeFromNib() {
     super.awakeFromNib()
     
     contentView.translatesAutoresizingMaskIntoConstraints = false
     
     NSLayoutConstraint.activate([
         contentView.leftAnchor.constraint(equalTo: leftAnchor),
         contentView.rightAnchor.constraint(equalTo: rightAnchor),
         contentView.topAnchor.constraint(equalTo: topAnchor),
         contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
     ])
 }
```

As it was mentioned at the beginning of the tutorial, `ViewController` is wired up as delegate and data source of the collection view by means of a storyboard. If you have launched the app, you must have noticed an exception indicating this. 

The time has come to fix the crash and implement collection view data source and delegate method. We add cells configuration along the way:

```swift

// MARK: - Collection view delegate and data source methods

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reuseID, for: indexPath) as! CollectionCell
        
        cell.titleLabel.text = items[indexPath.item].title
        cell.layer.borderWidth = Constants.borderWidth
        cell.layer.borderColor = UIColor.lightGray.cgColor
        
        return cell
    }
}

// MARK: - Constants

private enum Constants {
    static let spacing: CGFloat = 16
    static let borderWidth: CGFloat = 0.5
    static let reuseID = "CollectionCell"
}
```

The `Constants` enum is a nice way to organize constants. You can disregard `spacing` for now - we'll get back to it few paragraphs below.

Now launch the project and inspect the resulting cells. Here is what you are supposed to see:

<p align="center">
    <a href="{{ "img/collection-view-cells-dynamic-height/demo-1.png" | absolute_url }}">
        <img src="/img/collection-view-cells-dynamic-height/demo-1.png" width="450" alt="Dynamic Collection View Cells Sizing: Step by Step Tutorial"/>
    </a>
</p>

First 4 cells look fine, while the rest do not fit the screen. This reveals the need to constraint the cells horizontally to let them grow into multiple lines.

### Enabling Vertical Self-Sizing

This part is the trickiest among all and should be done in two steps.

1\. Enable multi-line label. Open `Main.storyboard` > select title label > in *Attributes Inspector* set *number of lines* to `0` and *line Break* to `Word Wrap`. Here is how it looks:

<p align="center">
    <a href="{{ "img/collection-view-cells-dynamic-height/cell-setup-4.png" | absolute_url }}">
        <img src="/img/collection-view-cells-dynamic-height/cell-setup-4.png" alt="Dynamic Collection View Cells Sizing: Step by Step Tutorial"/>
    </a>
</p>

2\. Add extra width constraint to the cell which will prevent cells from growing beyond screen bounds. Given that the label has been set as multi-line in the previous step, cells will grow vertically when the width limit is reached. Let's do this in two steps.

2.1\. The below code adds auto layout width constraint to `CollectionCell.swift` and hides it behind a `maxWidth` property. 

```swift
 // Note: must be strong
 @IBOutlet private var maxWidthConstraint: NSLayoutConstraint! {
     didSet {
         maxWidthConstraint.isActive = false
     }
 }
 
 var maxWidth: CGFloat? = nil {
     didSet {
         guard let maxWidth = maxWidth else {
             return
         }
         maxWidthConstraint.isActive = true
         maxWidthConstraint.constant = maxWidth
     }
 }
```
By default the constraint is inactive and thus should be set to *strong reference* so that it is not released from memory. Once `maxWidth` is set to *non-nil* value, the constraint is activated and width value is applied to the constraint. Such design makes the intention more clear and encapsulates the implementation details.

2.2\. Add auto layout width constraint to the label. The constant value should be `less than or equal X`, where `X` is anything above zero -- in my case it's 50. Here is how the constraint looks:

<p align="center">
    <a href="{{ "img/collection-view-cells-dynamic-height/cell-setup-6.png" | absolute_url }}">
        <img src="/img/collection-view-cells-dynamic-height/cell-setup-6.png" alt="Dynamic Collection View Cells Sizing: Step by Step Tutorial"/>
    </a>
</p>


2.3\. Connect the constraint to the `maxWidthConstraint` outlet.

<p align="center">
    <a href="{{ "img/collection-view-cells-dynamic-height/cell-setup-5.png" | absolute_url }}">
        <img src="/img/collection-view-cells-dynamic-height/cell-setup-5.png" alt="Dynamic Collection View Cells Sizing: Step by Step Tutorial"/>
    </a>
</p>

3\. Lastly, limit cells width to the bounds of the screen, so that the text can grow vertically into multiple lines. Open `ViewController.swift` and add next line to `collectionView(:cellForItemAt:)` method:

```swift
cell.maxWidth = collectionView.bounds.width - Constants.spacing
```

Now launch the project to see how the layout has changed. It is supposed to look next:

<p align="center">
    <a href="{{ "img/collection-view-cells-dynamic-height/demo-2.png" | absolute_url }}">
        <img src="/img/collection-view-cells-dynamic-height/demo-2.png" width="450" alt="Dynamic Collection View Cells Sizing: Step by Step Tutorial"/>
    </a>
</p>

### Checklist

In this tutorial we draw lots of attention to details, as there are plenty of places where things might get wrong, which resulted in quite a wordy article.

A brief checklist is here to help summarize the steps which should to enable collection view cells self-sizing:

1. Identify dynamic elements withing collection view cell which should grow.
2. Setup auto layout constraints in a such way, that dynamic elements are pinned to all edges of the content view either directly or indirectly, ex. when wrapped in containers like `UIView` or `UIStackView`.
3. Enable auto layout for cell content view and pin it to the edges of the cell.
4. Add extra width constraint with *'less than equal'* relation which limits cell from growing horizontally beyond screen bounds.
5. Make sure that dynamic UI elements can grow vertically when content increases. Some examples are: make `UILabel` multi-line, disable scrolling for `UITextView` etc.
6. Set cell maximal width from `collectionView(:cellForItemAt:)`.

### Source Code

You can find [final project here][final-repo]. And here is [starter project][starter-repo].

### Summary

Collection view cells can be sized either programmatically or via Interface Builder. The latter strategy is way easier and allows to design complex dynamic user interface without a single line of code.

Cells self-sizing by means of auto layout is connected with a number of pitfalls which might keep you busy for a couple of hours, if not days. 

The present step-by-step tutorial goes in great detail about every such issue and provides a checklist with a high-level summary of the steps to enable collection view cells self-sizing.

---

*If you enjoyed reading this article, tweet it forward and subscribe: [@V8tr](https://twitter.com/{{ site.author.twitter }}).*

---