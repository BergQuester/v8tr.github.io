---
layout: post
title: UIView Auto Layout life cycle
permalink: /view-auto-layout-life-cycle/
share-img: "/img/auto-layout-life-cycle-share.png"
---

Auto Layout is among the most important topics when it comes to iOS development in general. It is extremely important to understand Auto Layout life cycle to save time and avoid naive mistakes. Lack of this information will sooner or later lead to UI glitches and performance issues in your app. This article consolidates information about the steps that every `UIView` with Auto Layout enabled undergoes before being presented on a screen.

This article makes an assumption that you are familiar with Auto Layout basics. Otherwise, I suggest reading through the Apple's [Auto Layout Guide][autolayout-guide] and then returning back.

### Steps overview

<p align="center">
    <img src="{{ "/img/autolayout_1.svg" | absolute_url }}" alt="UIView Auto Layout life cycle - Auto Layout Steps"/>
</p>

Every `UIView` with enabled Auto Layout passes 3 steps after initialization: update, layout and render. These steps do not occur in a one-way direction. It's possible for a step to trigger any previous one or even force the whole cycle to repeat.

### Update step

This step is all about calculating view frame based on its constrains. The system traverses view hierarchy **top-down**, i.e. from *super-* to *subviews*, and calls `updateConstraints()` for each view.

Although this process happens automatically, sometimes you will need to trigger it manually. For example, you might need to immediately recalculate constraints in response to some event in your app or a change in its internal state.

`setNeedsUpdateConstraints` invalidates the constraints and schedules an update for the next cycle. `updateConstraintsIfNeeded` triggers `updateConstraints` in place, if the constrains were previously invalidated.

Apple actually suggests against overriding `updateConstraints` in [Mysteries of Auto Layout WWDC session](https://developer.apple.com/videos/wwdc/2015/?id=219), unless you discover that changing the constraints in place is too slow. Then you will batch constraints update in `updateConstraints`.

### Layout step

During this step, frames of each view are updated with the rectangles calculated in the *Update* phase. It happens **bottom-up**, i.e. the system traverses views from *sub-* to *superviews* and calls `layoutSubviews` for each.

`layoutSubviews` is the most common method to be overridden from the whole Auto Layout life cycle. You will do this when:
- Constraints are not enough to express view's layout.
- Frames are calculated programmatically.

There are two supplementary methods in this step: `setNeedsLayout` invalidate view's layout and `layoutIfNeeded` calls `layoutSubviews` in place, if the layout was previously invalidated. They have exact same meaning as `setNeedsUpdateConstraints` and `updateConstraintsIfNeeded` do in *Update* step.

When overriding `layoutSubviews`:
- Make sure to call `super.layoutSubviews()`.
- Don't call `setNeedsLayout` or `setNeedsUpdateConstraints`, otherwise an infinite loop will be created.
- Don't modify constraints of the views outside of the current hierarchy.
- Be careful changing constraints of views from the current hierarchy. It will trigger an *Update* step followed by another *Layout* step, potentially creating an infinite loop.

<p></p>

### Rendering

This step is responsible for bringing pixels onto the screen. By default, `UIView` passes all the work to a backing `CALayer` that contains a pixel bitmap of the current view state. This step is independent of whether Auto Layout is enabled for a view or not.

The key method here is `drawRect`. Unless you are doing custom *OpenGL ES*, *Core Graphics* or *UIKit* drawing, there is no need to override this method. 

All changes like background color, adding subviews etc. are drawn automatically. Most of the time you can compose UI from different views and layersб and don't need to override `drawRect`.

### What about UIViewControllers

Methods from steps 1 and 2 have their counterparts for the view controllers:
- Update phase: `updateViewConstraints`.
- Layout phase: `viewWillLayoutSubviews` / `viewDidLayoutSubviews`.

Method `viewDidLayoutSubviews` is the most important among all. It is called to notify view controller that its view has finished the *Layout* step, i.e. it's bounds have changed. This is an opportunity to make changes to a view after it has laid out its subviews, but before it becomes visible on the screen.

### Intrinsic Content Size

**Intrinsic content size** is a natural size of a view based on its content. For example, an image view's intrinsic content size is a size of it's image. 

Here are two tricks that will help you to simplify the layout and reduce the number of constraints:
- It's a good practice to override `intrinsicContentSize` for custom views, returning an appropriate size for their content.
- If a view has an intrinsic size only for one dimension, you should still override `intrinsicContentSize` and return `UIViewNoIntrinsicMetric` for the unknown dimension.

### Alignment Rectangle

Alignment rectangles are used by the *Auto Layout* engine to position views, thus separating their frames from the content being layed out. It's important to note that the *intrinsic content size* refers to the *alignment rectangle* rather than the *frame*.

By default, view's *alignment rectangle* equals to its *frame* modified by `alignmentRectInsets`. To get a better control over the *alignment rectangle*, you can override `alignmentRect(forFrame:)` and `frame(forAlignmentRect:)`. These two methods must be an inverse of each other.

Let's see how *alignment rectangle* affects Auto Layout positioning by example.

<p align="center">
    <img src="{{ "/img/alignment_rect_1.svg" | absolute_url }}" alt="UIView Auto Layout life cycle - Alignment rectangles, Intrinsic Content Size"/>
</p>

The circles above are both image views that are centered in the same way by means of Auto Layout. The only difference is how the shadow is added to the circle. The shadow of the left circle is a part of its image, i.e. the **image has a drop shadow effect**. The right view has a **shadow added by means of UIKit** and its image contains only a circle.

<p align="center">
    <img src="{{ "/img/alignment_rect_2.svg" | absolute_url }}" alt="UIView Auto Layout life cycle - Alignment rectangles, Intrinsic Content Size"/>
</p>

The key to understanding their positioning is the difference in *alignment rectangles*. Since shadow is a part of the left view's image, it is also a part of its *alignment rectangle*. Thus, the center of *alignment rectangle* does not match with the circle center.

Conversely, the right view has a shadow added by means of UIKit. Its *alignment rectangle* does not include the shadow, which means that the circle center and the *alignment rectangle* center are equal.

### Wrapping up

We covered the most important aspect of the three steps every `UIView` with Auto Layout enabled undergoes, before being presented on the screen. Namely: *constraints update*, *layout* and *render* (or display). Additionally, we discussed what are *intrinsic content size* and *alignment rectangle* and how they relate.

The topics we discussed are absolute minimum you should know about the Auto Layout life cycle. These details are easy to forget when not working with Auto Layout for some time, so it is handful to keep them consolidated to freshen your knowledge at a glance.

[autolayout-guide]: https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/