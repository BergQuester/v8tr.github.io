---
layout: post
title: "Sticky Grid Collection View: Tutorial"
permalink: /sticky-grid-collection-view/
share-img: "/img/sticky-grid-collection-view-share.png"
---

In this article you will learn how to implement collection view that has grid layout, supports both vertical and horizontal scrolling and has sticky rows and columns using Swift.

### Introduction

Collection view lends itself to managing ordered data items and displaying them using configurable layouts. It is arguably the most flexible control in iOS: tables, grids, pages, you name it — literally any user interface control can be implemented using collection views. 

Such a high level of customization is achieved primarily by decoupling presentation, positioning and event-handling responsibilities. Here are the key actors along with their roles:

- `UICollectionViewDataSource` — is responsible for providing the data and views to be rendered by the collection view.
- `UICollectionViewDelegate` — allows to control selection events.
- `UICollectionViewLayout` — determines positioning of cells and supplementary elements.

To design a grid with arbitrary number of sticky rows and columns we should focus our efforts on presentation which is the responsibility of `UICollectionViewLayout`.

### Understanding UICollectionViewLayout

Before diving into code, we must clearly understand how the collection view layout works and which customization options does it offer.

`UICollectionViewLayout` is an abstract class responsible for items and supplementary views placement inside the collection view bounds. Collection view consults with its layout before presenting elements on the screen, that allows to come up with literally any kind of placement. 

By default, collection view comes with `UICollectionViewFlowLayout` that organizes items into a grid. The flow layout uses `UICollectionViewDelegateFlowLayout` protocol to coordinate the size of elements and spacing between them. Our implementation will rely on the methods from this protocol to be as much extensible as possible.

<!-- An object that manages an ordered collection of data items and presents them using customizable layouts.

One way of customizing it is by means of a number of `delegate` and `dataSource` methods. However your options are not limited with it. To make one step further you can provide your own collection view layout.

`UICollectionViewLayout` defines positioning of cells and supplementary elements inside collection view bounds. Collection view always consults with its layout before presenting elements on the screen, that gives you just enough opportunities to come up with literally any kind of placement. By default, collection view uses `UICollectionViewFlowLayout` that organizes items into a grid. -->

### Getting Started

Throughout the tutorial we will build a reusable solution on top of `UICollectionViewFlowLayout` that does next things:
- Supports vertical and horizontal scrolling simultaneously.
- Positions cells into a grid.
- Has configurable number of sticky rows and columns.
- Is easy to use via storyboards, xibs or programmatically.

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
    <a href="{{ "/img/sticky-grid-collection-view/horizontal-and-vertical-scrolling.gif" | absolute_url }}">
        <img src="/img/sticky-grid-collection-view/horizontal-and-vertical-scrolling.gif" width="350" alt="Sticky Grid Collection View: Tutorial - Collection view with both vertical and horizontal scrolling"/>
    </a>
</p>

Collection view is smart about scrolling and adapts automatically to its content size. Although we have reached our the goal of simultaneous horizontal and vertical scroll, the cells placement does not seem to be correct.

### Positioning Cells into Grid

The next step is to properly position cells within collection view content size. For this purpose we need to override `layoutAttributesForElements(in:)` that returns an array of `UICollectionViewLayoutAttributes` which is the layout attributes for all of the cells and views in the specified rectangle.

{% highlight swift linenos %}

private var allAttributes: [[UICollectionViewLayoutAttributes]] = []

override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var layoutAttributes = [UICollectionViewLayoutAttributes]()

    for rowAttrs in allAttributes {
        for itemAttrs in rowAttrs where rect.intersects(itemAttrs.frame) {
            layoutAttributes.append(itemAttrs)
        }
    }

    return layoutAttributes
}

{% endhighlight %}

The method iterates through the `allAttributes` property and checks which attributes fall within the specified rectangle. This calculation will be repeated each time the collection view bounds are changed and has huge influence over the performance. Instead of repeating calculations again and again, we do it once and then cache into `allAttributes`. It is a two-dimensional array that contains attributes for the whole grid. You can access an arbitrary cell like this:

```swift
let cellAttributes = allAttributes[row][column]
```

The right place to setup attributes is `prepare()` which is called each time the collection view layout is invalidated.

{% highlight swift linenos %}

override func prepare() {
    setupAttributes()
}

private func setupAttributes() {
    // 1
    allAttributes = []

    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 0

    // 2
    for row in 0..<rowsCount {
        // 3
        var rowAttrs: [UICollectionViewLayoutAttributes] = []
        xOffset = 0

        // 4
        for col in 0..<columnsCount(in: row) {
            // 5
            let itemSize = size(forRow: row, column: col)
            let indexPath = IndexPath(row: row, column: col)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height).integral

            rowAttrs.append(attributes)

            xOffset += itemSize.width
        }

        // 6
        yOffset += rowAttrs.last?.frame.height ?? 0.0
        allAttributes.append(rowAttrs)
    }
}

{% endhighlight %}

For now let's ignore compiler's warnings to understand how the method works.

1. Remove all previously calculated attributes as they might be no longer relevant and initialize offset variables.
2. Iterate over all rows within a grid. When working with a grid, it is easier to think about cells in terms of rows in columns rather than items and sections. For this purpose we will implement `rowsCount` and `columnsCount(in:)` later.
3. Make preparations for the new row. Each row must begin with *0* position, thus we need to reset `xOffset`. Attributes of each row are stored in `rowAttrs` array.
4. Iterate over all columns within a row.
5. Calculate a frame of a cell. We are accumulating `xOffset` and `yOffset` to position the cell correctly within the grid. The size is received from the new method `size(forRow:,column:)` that will be implemented later.
6. Lastly, we append row attributes to `allAttributes` that contains attributes for the whole grid.

After we understand the logic flow of the `setupAttributes()` method, we are ready to implement several helpers that are causing compiler warnings.

{% highlight swift linenos %}

// MARK: - Sizing
	
private var rowsCount: Int {
    return collectionView!.numberOfSections
}

private func columnsCount(in row: Int) -> Int {
    return collectionView!.numberOfItems(inSection: row)
}

private func size(forRow row: Int, column: Int) -> CGSize {
    guard let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout,
        let size = delegate.collectionView?(collectionView!, layout: self, sizeForItemAt: IndexPath(row: row, column: column)) else {
        assertionFailure("Implement collectionView(_,layout:,sizeForItemAt: in UICollectionViewDelegateFlowLayout")
        return .zero
    }

    return size
}

{% endhighlight %}

Methods `rowsCount` and `columnsCount(in:)` make the conversion from sections and items into rows and columns. We can safely force unwrap `collectionView` here, because the collection view always has a layout object set. The opposite is also true because we are not going to use the layout without the collection view.

The method `size(forRow:,column:)` does not calculate the size, but asks flow layout delegate to provide one. It is mandatory for `UICollectionViewDelegateFlowLayout` to implement this method and we enforce it with an assertion.

The only thing that is left is small utility method that converts row and column back to `IndexPath`:

{% highlight swift linenos %}

private extension IndexPath {
	init(row: Int, column: Int) {
		self = IndexPath(item: column, section: row)
	}
}

{% endhighlight %}

Now you can run the app to see the result:

<p align="center">
    <a href="{{ "/img/sticky-grid-collection-view/grid-positioning.gif" | absolute_url }}">
        <img src="/img/sticky-grid-collection-view/grid-positioning.gif" width="350" alt="Sticky Grid Collection View: Tutorial - Collection view cells grid positioning"/>
    </a>
</p>

Let's move on to adding sticky rows and columns to our collection view layout.

### Adding Sticky Rows and Columns to Collection View

Firstly, we add two new properties reflecting the number of sticky rows and columns to our collection view layout.

{% highlight swift linenos %}

var stickyRowsCount = 0 {
    didSet {
        invalidateLayout()
    }
}

var stickyColumnsCount = 0 {
    didSet {
        invalidateLayout()
    }
}

{% endhighlight %}

You must have noticed that each time the number of sticky rows or columns is changed, we invalidate the layout to trigger `preload()` and recalculate all the attributed.

Next we want to adjust sticky items positions each time the collection view is scrolled. To do so we need to do two things: invalidate the layout for bounds changes and recalculate sticky cells placement.

{% highlight swift linenos %}

override func prepare() {
    setupAttributes()
    // 1
    updateStickyItemsPositions()
}

// 2
override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
}

{% endhighlight %}

1. Here we add the new method that updates sticky items positions. We'll implement it later.
2. Returning `true` in `shouldInvalidateLayout(forBoundsChange:)` would trigger `preload()` method whenever the collection view is scrolled.

The method `updateStickyItemsPositions()` does the actual placement of sticky rows and columns.

{% highlight swift linenos %}

private func updateStickyItemsPositions() {
    // 1
    for row in 0..<rowsCount {
        for col in 0..<columnsCount(in: row) {
            // 2
            let attributes = allAttributes[row][col]

            // 3
            if row < stickyRowsCount {
                var frame = attributes.frame
                frame.origin.y += collectionView!.contentOffset.y
                attributes.frame = frame
            }

            if col < stickyColumnsCount {
                var frame = attributes.frame
                frame.origin.x += collectionView!.contentOffset.x
                attributes.frame = frame
            }

            // 4
            attributes.zIndex = zIndex(forRow: row, column: col)
        }
    }
}

{% endhighlight %}

Here is step by step explanation of the logic flow.
1. Iterate over all rows and columns in the grid.
2. Here an assumption is made that attributes have already been cached in `allAttributes`, thus the order in which the methods are called within `prepare()` is highly important. 
3. Positions of sticky items are updated with collection view offset. By doing this we pin sticky items to the edges of the collection view. 
4. Besides updating the positions, we must ensure that sticky items are always placed above the rest of the cells. The new helper method `zIndex(forRow:column:)` will be implement for this purpose.

*Z-index (or Z-order)* is a common attribute in programming APIs that defines the stack order of specific element within UI hierarchy. When two elements overlap, their Z-index determined which one appears on the top of the other. In our case, we distinguish 3 kinds of Z-orders: 
1. Sticky cells that are intersection of sticky rows and columns — are always on the top.
2. The rest of sticky cells — are in the middle.
3. Regular collection view cells — are at the bottom.

`zIndex` method implementation reflects this:

{% highlight swift linenos %}

private func zIndex(forRow row: Int, column col: Int) -> Int {
    if row < stickyRowsCount && col < stickyColumnsCount {
        return ZOrder.staticStikyItem
    } else if row < stickyRowsCount || col < stickyColumnsCount {
        return ZOrder.stickyItem
    } else {
        return ZOrder.commonItem
    }
}

// MARK: - ZOrder

private enum ZOrder {
    static let commonItem = 0
	static let stickyItem = 1
	static let staticStikyItem = 2
}

{% endhighlight %}

Lastly, we want to set the actual number of sticky items from *ViewController*:



---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---

[starter-repo]: https://github.com/V8tr/UITableViewCellAnimation-Article-Starter