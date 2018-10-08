---
layout: post
title: "Sticky Grid Collection View: Tutorial"
permalink: /sticky-grid-collection-view/
share-img: "/img/sticky-grid-collection-view-share.png"
---

In this article you will learn how to implement collection view grid with sticky rows and columns using Swift.

### Introduction

Collection view lends itself to managing ordered data items and displaying them using configurable layouts. It is arguably the most flexible control in iOS: tables, grids, pages, you name it - literally any control can be implemented using collection views. Such a high level of customization is achieved primarily by decoupling presentation, positioning and event-handling responsibilities.

- `UICollectionViewDataSource` is responsible for providing the data and views to be rendered by the collection view.
- `UICollectionViewDelegate` allows to control selection events.
- `UICollectionViewLayout` determines positioning of cells and supplementary elements.

To design a grid with arbitrary number of sticky rows and columns that can be scrolled both vertically and horizontally, our primary focus should be presentation which is the responsibility of `UICollectionViewLayout`.

### Understanding UICollectionViewLayout

Before diving into code, we must clearly understand how the collection view layout works and which customization options does it offer.

`UICollectionViewLayout` is an abstract class responsible for items and supplementary views placement inside the collection view bounds. Collection view consults with its layout before presenting elements on the screen, that allows to come up with literally any kind of placement. By default, collection view comes with `UICollectionViewFlowLayout` that organizes items into a grid. 

The flow layout already supports horizontal and vertical scrolling, thus to fulfil our goal we need to subclass it and provide custom placement of sticky rows and columns and let the layout do the rest.

Another thing to know about the flow layout is that it uses `UICollectionViewDelegateFlowLayout` protocol to coordinate the size of elements and spacing between them. Our implementation will rely on the methods from this protocol.

Now we are ready to specify the goals for our control named `StickyGridCollectionViewLayout`. Throughout this tutorial we will build a reusable solution on top of `UICollectionViewFlowLayout` with following features:
- Position cells into a grid.
- Variable number of sticky rows and columns.
- Easy to plug in from storyboard, xib or programmatically.
- Support vertical and horizontal scrolling.

<!-- An object that manages an ordered collection of data items and presents them using customizable layouts.


Collection view is arguably the most flexible control in iOS and macOS development. You can implement literally anything by means of collection views. Decoupling presentation and positioning is what makes collection views so customizable.

UICollectionViewDelegate and 

Standard ways of customization include `delegate` and `dataSource` methods and tweak

One way of customizing it is by means of a number of `delegate` and `dataSource` methods. However your options are not limited with it. To make one step further you can provide your own collection view layout.

`UICollectionViewLayout` defines positioning of cells and supplementary elements inside collection view bounds. Collection view always consults with its layout before presenting elements on the screen, that gives you just enough opportunities to come up with literally any kind of placement. By default, collection view uses `UICollectionViewFlowLayout` that organizes items into a grid. 

Throughout this tutorial we will build a reusable solution on top of `UICollectionViewFlowLayout`. It will have the following features:
- Position cells into a grid.
- Configurable number of sticky rows and columns.
- Easy to plug in from storyboard, xib or programmatically.
- Support vertical and horizontal scrolling. -->

### Getting Started

Let's begin with [downloading the starter project][starter-repo] for this article. It will save you some time on writing boilerplate code and also make sure we are on the same page before beginning this tutorial. When you run it, you see a grid of 100 cells, each showing its index path.

<p align="center">
    <a href="{{ "/img/sticky-grid-collection-view/starter.png" | absolute_url }}">
        <img src="/img/sticky-grid-collection-view/starter.png" alt="Sticky Grid Collection View: Tutorial - Starter Project"/>
    </a>
</p>

At this point you must realize that one of our goals is actually fulfilled without any actions from our side. 

The only view controller that will be used in the article is configured in `Main.storyboard` and 


Along the way, we will need 

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---

[starter-repo]: https://github.com/V8tr/UITableViewCellAnimation-Article-Starter