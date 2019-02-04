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

<!-- Collection views are undoubtedly among most widely used and at the same time most flexible controls in iOS and macOS development. The default flow layout allows for numerous customizations fitting most projects' needs, and if it is not enough, literally any cells positioning and configuration can be implemented by providing your own layout. -->

With regards to collection view cells sizing three strategies exist:
- Layout Property - `UICollectionViewFlowLayout.itemSize`
- Delegate - `collectionView(layout:sizeForItemAt:)`
- Cell - self-sizing cells

*Self-sizing cells strategy* is usually the most preferable among all, since it allows to encapsulate the layout details inside a cell instead of leaking to view controller code.

There are two ways to cut the cake:
- Autolayout sizing: add constraints to `cell.contentView`.
- Manual-sizing code: Override `sizeThatFits`.

The former solution is usually more compelling as it allows to setup sizing by means of the auto layout engine without writing a single line of code. 


In present article let's implement `UICollectionView` with custom cells which size themselves dynamically to fit their content.

### Starter Project

**DONT FORGET TO INSERT CORRECT LINK TO STARTER PROJECT**

Let's begin with a fresh project. In order not to spend your time on writing boilerplate code and project setup, since it is something you've done hundreds of times before, I've got you covered and created a starter project.

To ensure that we are on the same page and in order to get straight to the point, grab [this starter project](https://developer.apple.com/documentation/uikit/uicollectionviewflowlayout/1617709-estimateditemsize) and briefly glance through the files.

Here are the most important highlights:
1. `ViewController` is the core class in this tutorial where all the fun will take place.
2. `Item` is a model class that backs our cells. 
3. `ViewController` has an array of `items` with placeholder texts which will drive collection view cells rendering.
   
{: .box-note}
*Wondering why this is it important to have models for collection view cells even for a small tutorial like this? Then you can read my recent article about [data-driven table view](({{ "/data-drive-table-views/" | absolute_url }})) where it is explained in detail.*
   
### Creating Custom Collection View Cell

Let's create a simple `UICollectionViewCell` subclass: nothing fancy, just a label outlet. 

First, create a new file `CollectionCell.swift` with the following code:

```swift
class CollectionCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}
```

Second, setup a cell in `Main.storyboard`. It happens in multiple steps:

1\. Go to `Main.storyboard` and select `ViewController` which already has a collection view added. Select cell prototype and set its class to `CollectionCell`. Also set cell reuse identifier to *"CollectionCell"* to match with its class name. The result is next:
<p align="center">
    <a href="{{ "img/collection-view-cells-dynamic-height/cell-setup-1.png" | absolute_url }}">
        <img src="/img/collection-view-cells-dynamic-height/cell-setup-1.png" alt="Dynamic Collection View Cells Sizing: Step by Step Tutorial"/>
    </a>
</p>
   
2\. Add a label and pin it to the edges of the collection view cell. I suggest to set label's text to *"[Title]"* to make it self-explanatory.
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

Dynamic cells sizing is a feature of `UICollectionViewFlowLayout`. In order to support it, the layout's `estimatedItemSize` property must be set to a non-zero value. This property is an equivalent of estimated row height in table views. 

When estimated size is set, a layout computes a first approximation using estimated size, and then re-calculates it when the updated attributes are received. Thus it will boost the performance if estimated size is close to the actual one.

{: .box-note}
*If you would like to learn which steps views and cells undergo before being drawn on the screen, what are `intrinsicContentSize` and alignment rectangle, I recommend reading [my article on the subject](({{ "/data-drive-table-views/" | absolute_url }})).*

After learning about estimated item size, let's configure the layout:

1\. Create the new property `collectionLayout` by dragging `UICollectionViewFlowLayout` from the storyboard.  
2\. Setup automatic size in `didSet`:

```swift
collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
```

The result looks next:
<p align="center">
    <a href="{{ "img/collection-view-cells-dynamic-height/layout-setup-1.png" | absolute_url }}">
        <img src="/img/collection-view-cells-dynamic-height/layout-setup-1.png" alt="Dynamic Collection View Cells Sizing: Step by Step Tutorial"/>
    </a>
</p>


---

*If you enjoyed reading this article, tweet it forward and subscribe: [@V8tr](https://twitter.com/{{ site.author.twitter }}).*

---