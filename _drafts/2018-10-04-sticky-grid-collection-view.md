---
layout: post
title: "Sticky Grid Collection View: Tutorial"
permalink: /sticky-grid-collection-view/
share-img: "/img/sticky-grid-collection-view-share.png"
---

In this article you will learn how to implement custom collection view with grid layout and sticky rows and columns using Swift.

### Introduction

Collection view lends itself to managing ordered data items and displaying them using configurable layouts. It is arguably the most flexible control in iOS: tables, grids, pages, you name it - literally any user interface control can be implemented using collection views. 

Such a high level of customization is achieved primarily by decoupling presentation, positioning and event-handling responsibilities. Here are the key actors along with their roles:

- `UICollectionViewDataSource` is responsible for providing the data and views to be rendered by the collection view.
- `UICollectionViewDelegate` allows to control selection events.
- `UICollectionViewLayout` determines positioning of cells and supplementary elements.

To design a grid with arbitrary number of sticky rows and columns we should focus our efforts on presentation which is the responsibility of `UICollectionViewLayout`.

### Understanding UICollectionViewLayout

Before diving into code, we must clearly understand how the collection view layout works and which customization options does it offer.

`UICollectionViewLayout` is an abstract class responsible for items and supplementary views placement inside the collection view bounds. Collection view consults with its layout before presenting elements on the screen, that allows to come up with literally any kind of placement. By default, collection view comes with `UICollectionViewFlowLayout` that organizes items into a grid. 

The flow layout already supports horizontal and vertical scrolling, thus to fulfil our goal we need to subclass it and provide custom placement of sticky rows and columns and let the layout do the rest.

Another thing to know about the flow layout is that it uses `UICollectionViewDelegateFlowLayout` protocol to coordinate the size of elements and spacing between them. Our implementation will rely on the methods from this protocol to be as much extensible as possible.

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

Throughout the tutorial we will build a reusable solution on top of `UICollectionViewFlowLayout` that does next things:
- Supports vertical and horizontal scrolling.
- Positions cells into a grid.
- Has configurable number of sticky rows and columns.
- Is easy to plug into storyboards, xibs or can be added programmatically.

After we specified our goals, we are ready to get started. Each subsequent section will fulfil one goal from the list and move us one step closer to the final solution.

Let's begin with [downloading the starter project][starter-repo]. It will save you some time on writing boilerplate code and also make sure we are on the same page. When you run it, you see a simple collection view with 10000 cells - 100 sections, 100 items per section - each showing its index path.

<p align="center">
    <a href="{{ "/img/sticky-grid-collection-view/starter.png" | absolute_url }}">
        <img src="/img/sticky-grid-collection-view/starter.png" width="400" alt="Sticky Grid Collection View: Tutorial - Starter Project"/>
    </a>
</p>

Here are some important highlights to pinpoint in starter project:
- `ViewController` — the only view controller we will be dealing with in this tutorial. It is configured in `Main.storyboard` with a collection view and layout added as outlets.
- `StickyGridCollectionViewLayout` — an empty subclass of the flow layout.
- `CollectionViewCell` — a simple collection view cell subclass with a title label.

Another thing to notice is that the collection view is already using our custom layout that is set in interface builder. This is also reflected in view controller's `gridLayout` property of type `StickyGridCollectionViewLayout`.

Here is how it looks in interface builder:

<p align="center">
    <a href="{{ "/img/sticky-grid-collection-view/starter-storyboard-grid-layout.png" | absolute_url }}">
        <img src="/img/sticky-grid-collection-view/starter-storyboard-grid-layout.png" alt="Sticky Grid Collection View: Tutorial - Starter Project Setup"/>
    </a>
</p>

### Adding Horizontal and Vertical Scrolling

By default, flow layout supports either horizontal or vertical scrolling. In our case 3 cells fit the screen horizontally which results in a grid with 3333 rows and 3 columns. 

Imagine that we want to have a square grid of `100 x 100` items. Considering that the size of each item is 100px, that would be `10000 x 10000 px`. Let's reflect this in our `StickyGridCollectionViewLayout` and override the property `collectionViewContentSize: CGSize`:

{% highlight swift linenos %}

override var collectionViewContentSize: CGSize {
	return CGSize(width: 10_000, height: 10_000)
}

{% endhighlight %}

Now run the project and play with the scroll. It results in next behavior:

<p align="center">
    <a href="{{ "/img/sticky-grid-collection-view/bigger-content-size.gif" | absolute_url }}">
        <img src="/img/sticky-grid-collection-view/bigger-content-size.gif" width="400" alt="Sticky Grid Collection View: Tutorial - Override collection view content size demo"/>
    </a>
</p>

Collection view is smart about scrolling and adapts automatically to its content size. Although we have reached our the goal of adding both horizontal and vertical scroll, the cells placement needs to be adjusted as well.



---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---

[starter-repo]: https://github.com/V8tr/UITableViewCellAnimation-Article-Starter