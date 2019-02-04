---
layout: post
title: "Dynamic Collection View Cells Sizing: Step by Step Tutorial"
permalink: /collection-view-cells-dynamic-height/
share-img: ""
---

When working with collection views, chances high that you have spend considerable amount of time sizing cells programmatically. In this article you will learn how UICollectionViewCells can dynamically adjust their size based on their content.

### Problem Statement

Collection views are undoubtedly among most widely used and at the same time most flexible controls in iOS and macOS development. The default flow layout allows for numerous customizations fitting most projects' needs, and if it is not enough, literally any cells positioning and configuration can be implemented by providing your own layout.

Dynamic sizing for table view cells is used extensively, while the exactly same feature for collection views is unjustly left unnoticed. Being around [since iOS 8](https://developer.apple.com/documentation/uikit/uicollectionviewflowlayout/1617709-estimateditemsize), `UICollectionViewCells` self-sizing is still not as widely adopted as it could be. This might be partially explained by numerous non-obvious pitfalls which arise when trying to implement collection view cells with dynamic size and lack of tutorials covering these pitfall in detail.

In present article let's implement `UICollectionView` with custom cells which size themselves dynamically to fit their content.

### Starter Project

**DONT FORGET TO INSERT CORRECT LINK TO STARTER PROJECT**

Let's begin coding in a fresh project. In order not to spend your time on writing boilerplate code and project setup, since it is something you've done hundreds of times before, I've got you covered and created a starter project.

To ensure that we are on the same page and in order to get straight to the point, grab [this starter project](https://developer.apple.com/documentation/uikit/uicollectionviewflowlayout/1617709-estimateditemsize) and briefly glance through the files.

Here are the most important highlights:
1. `ViewController` is the core class in this tutorial where all the fun will take place.
2. `Item` is a model class that backs our cells. 
3. `ViewController` has an array of `items` with placeholder texts which will drive collection view cells rendering.
   
{: .box-note}
*Wondering why this is it important to have models for collection view cells even for a small tutorial like this? Then you can read my recent article about [data-driven table view](({{ "/data-drive-table-views/" | absolute_url }})) where it is explained in detail.*
   
### Creating Custom Collection View Cell

Let's create a simple `UICollectionViewCell` subclass: nothing fancy, just a single label with text. First, create a new file `CollectionCell.swift` with the following code:

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

What makes collection view so flexible is decoupled layout and rendering of its cells. Dynamic cells sizing is a feature of `UICollectionViewFlowLayout`, which is the default for collection views. 

When `estimatedItemSize` is set to the `automatic`, the layout is smart enough to use `intrinsicContentSize` value to size collection view cells.

{: .box-note}
*If you would like to learn which steps views and cells undergo before being drawn on the screen, what are `intrinsicContentSize` and alignment rectangle, I recommend reading [my article on the subject](({{ "/data-drive-table-views/" | absolute_url }})).*

According to the above, let's set layout's `estimatedItemSize` property to use automatic sizing. It can be done in 2 steps:

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