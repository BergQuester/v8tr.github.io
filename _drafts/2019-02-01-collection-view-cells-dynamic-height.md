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

### Configure Dynamic Width

Here goes the non-obvious pitfall: by default collection view cell content view does not have auto layout enabled which needs some tweaks in order for self-sizing to work.

To fix this, we pin content view in awakeFromNib method. Open `CollectionCell.swift` and paste the code:

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

As stated at the beginning of the tutorial, `ViewController` is wired up as delegate and data source of the collection view. This causes the app to crash, because protocol methods are not implemented yet. Enter below code at the bottom of `ViewController.swift`.

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

The above code does trivial configurations to the cells. The constants are extracted to a enum to make the intention more clear.

---

*If you enjoyed reading this article, tweet it forward and subscribe: [@V8tr](https://twitter.com/{{ site.author.twitter }}).*

---