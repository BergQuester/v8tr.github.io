---
layout: post
title: "Sticky Grid Collection View: Tutorial"
permalink: /sticky-grid-collection-view/
share-img: "/img/sticky-grid-collection-view-share.png"
---

In this article you will learn how to implement collection view grid with sticky rows and columns using Swift.

### Introduction

Collection view is arguably the most flexible control in iOS and macOS development. One way of customizing it is by means of a number of `delegate` and `dataSource` methods. However your options are not limited with it. To make one step further you can provide your own collection view layout.

`UICollectionViewLayout` defines positioning of cells and supplementary elements inside collection view bounds. Collection view always consults with its layout before presenting elements on the screen, that gives you just enough opportunities to come up with literally any kind of placement. By default, collection view uses `UICollectionViewFlowLayout` that organizes items into a grid. 

Throughout this tutorial we will build a reusable solution on top of `UICollectionViewFlowLayout` that has sticky rows and columns and supports both horizontal and vertical scrolling.

### Getting Started

Let's begin with [downloading the starter project][starter-repo] for this article. It will save you some time on writing boilerplate code and make sure we are on the same page before beginning this tutorial. When you run it, you will see a simple collection with 100x100 cells, each showing its index path.

<p align="center">
    <a href="{{ "/img/sticky-grid-collection-view/starter.png" | absolute_url }}">
        <img src="/img/sticky-grid-collection-view/starter.png" alt="Sticky Grid Collection View: Tutorial - Starter Project"/>
    </a>
</p>



---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---

[starter-repo]: https://github.com/V8tr/UITableViewCellAnimation-Article-Starter