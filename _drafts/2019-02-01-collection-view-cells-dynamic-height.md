---
layout: post
title: "Dynamic Collection View Cells Sizing: Step by Step Tutorial"
permalink: /collection-view-cells-dynamic-height/
share-img: ""
---

When working with collection views, chances high that you have spend considerable amount of time sizing cells programmatically. In this article you will learn how UICollectionViewCells can dynamically adjust their size based on their content.

### Problem Statement

Collection views are undoubtedly among most widely used and at the same time most flexible controls in iOS and macOS development. The default flow layout allows for numerous customizations fitting most projects' needs, and if it is not enough, literally any cells positioning and configuration can be implemented by providing your own layout.

Most of iOS and macOS developers use dynamic sizing for table view cells, while the same feature for collection views is unjustly left unnoticed. Being around [since iOS 8](https://developer.apple.com/documentation/uikit/uicollectionviewflowlayout/1617709-estimateditemsize), `UICollectionViewCells` self-sizing is still not so widely adopted in the community. This might be partially explained by numerous non-obvious pitfalls which arise when trying to implement collection view cells with dynamic size and lack of tutorials which explain the approach step-by-step.

In current article let's implement `UICollectionView` with custom cells that size themselves dynamically to fit their content.

### Starter Project

**DONT FORGET TO INSERT CORRECT LINK TO STARTER PROJECT**

For this kind of tutorials you usually don't want to spend your time on boilerplate code and project setup, as it is something you've done hundreds of times before. To get straight to the point and ensure that we are on the same page, grab [this starter project](https://developer.apple.com/documentation/uikit/uicollectionviewflowlayout/1617709-estimateditemsize) and briefly glance through the files.

Here are the most important highlights:
1. `ViewController` is the core class in this tutorial where all the fun will be happening.
2. `Item` is a model class that backs our cells. `ViewController` has an array of `items` with placeholder texts which will drive collection view cells rendering.
   
{: .box-note}
*Wondering why this is it important to have models for collection view cells even for a small tutorial like this? Then you can read my recent article about [data-driven table view](({{ "/data-drive-table-views/" | absolute_url }})) where it is explained in detail.*
   
### Creating Custom Collection View Cell

I am sure you have created custom cells dozens of time before, so I will pinpoint only the most important parts for the tutorial. 

Let's create a new file and name it `CollectionCell.swift`. Open the file and paste this code. Nothing fancy, just a cell with a label as an outlet:

```swift
class CollectionCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}
```

Next, we setup a cell prototype in `Main.storyboard` and connect the outlet to the property.

1\. Set `CollectionCell` class.
<p align="center">
    <a href="{{ "img/collection-view-cells-dynamic-height/cell-setup-1.png" | absolute_url }}">
        <img src="/img/collection-view-cells-dynamic-height/cell-setup-1.png" alt="Dynamic Collection View Cells Sizing: Step by Step Tutorial"/>
    </a>
</p>

2\. Set reuse identifier to *"CollectionCell"*.
   
3\. Add a label and pin it to the edges of collection view cell.
<p align="center">
    <a href="{{ "img/collection-view-cells-dynamic-height/cell-setup-2.png" | absolute_url }}">
        <img src="/img/collection-view-cells-dynamic-height/cell-setup-2.png" alt="Dynamic Collection View Cells Sizing: Step by Step Tutorial"/>
    </a>
</p>

4\. Connect the label with the property `titleLabel`.
<p align="center">
    <a href="{{ "img/collection-view-cells-dynamic-height/cell-setup-3.png" | absolute_url }}">
        <img src="/img/collection-view-cells-dynamic-height/cell-setup-3.png" alt="Dynamic Collection View Cells Sizing: Step by Step Tutorial"/>
    </a>
</p>

### Configure UICollectionViewFlowLayout

Dynamic sizing of collection view cells is a feature of `UICollectionViewFlowLayout`, and you must opt in to use this layout for dynamic sizing to work. To opt in for dynamic cells sizing feature, we must set `estimatedItemSize` property to the automatic size. It can be done in 2 steps:

1\. Drag `UICollectionViewFlowLayout` from the storyboard to create a new property `collectionLayout`.  

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