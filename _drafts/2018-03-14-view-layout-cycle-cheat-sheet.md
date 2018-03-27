---
layout: post
title: UIView Auto Layout life cycle
permalink: /2018-03-14-view-layout-cycle-cheat-sheet/
---

- Introduction
- Diagram with explanation
- Each step in-depth
- Alignment Rect
- Intrinsic content size
- Wrapping up

`UIView` is an essential part of every iOS application’s UI and it’s extremely important to understand which steps it undergoes before being brought to the screen. Lack of this information will sooner or later lead to UI glitches and performance issues in your app. This article consolidates information about the steps that every `UIView` with Auto Layout enabled undergoes during its presentation process.

This article makes an assumption that you are familiar with Auto Layout. Otherwise, I suggest reading through [Auto Layout Guide][autolayout-guide] by Apple and then returning back.

### View layout cycle

<p align="center">
    <img src="{{ "/img/autolayout_1.svg" | absolute_url }}" alt="UIView auto layout life cycle cheat sheet"/>
</p>

Every `UIView` with enabled Auto Layout passes 3 steps after initialization: update, layout and render. These steps do not occur in a one-way direction. It's possible for one step to trigger another which will cause all subsequent phases to process again.

### Update step

This step is all about calculating view frame based on its constrains. The details are next:

- Happens top-down: the system goes from super- to its subviews and calls `updateViewConstraints()` for each.
- Call `setNeedsUpdateConstraints` to schedules constraints update for the near future.
- Call `updateConstraintsIfNeeded` to perform all pending updates in place. Call together with `setNeedsUpdateConstraints` to force an immediate update. 
- Override `updateViewConstraints` to boost performance by batching constraints update. 
- When changing constraints, do this in place and call a combination of `setNeedsUpdateConstraints` and `updateConstraintsIfNeeded` afterwards.

For the most of the time there is no need to override `updateViewConstraints`. If you discover that current step is the bottleneck in your app's performance, make sure to check [updateViewConstraints](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621379-updateviewconstraints) docs before overriding it, as there are several important nuances.

### Layout step

During this step the frames of each view are updated with the rectangles calculated in the previous phase.

- Happens bottom-up: the system goes from super- to subviews calling `layoutSubviews` for each.
- Override `layoutSubviews` method when:
    - Constraints are not enough to express view's layout;
    - Frames are calculated programmatically;
- Call `setNeedsLayout` to schedule layout for the near future.
- Call `layoutIfNeeded` to force the view to update its layout immediately.
- When overriding `layoutSubviews`:
    - Make sure to call `super.layoutSubviews()`;
    - Don't call `setNeedsLayout` or `setNeedsUpdateConstraints`, otherwise an infinite loop will be created;
    - Don't modify constraints of views outside your view's hierarchy;
    - If any constraints from current hierarchy are changed, an update step will be triggered followed by another layout step, potentially creating an infinite loop;

<p></p>

### Rendering

This step is responsible for bringing pixels onto the screen. By default, `UIView` passes all the work to a backing `CALayer` that contains a pixel bitmap of current view state. 

- The step is independent of whether Auto Layout is enabled for a view or not.
- Override `drawRect` when doing custom OpenGL ES, Core Graphics and UIKit drawing.
- Do not override `drawRect` when making any other than above changes, like updating background color, adding subviews etc., as they are handled automatically.
- By default `drawRect` method does nothing.
- Call `setNeedsDisplay` or `setNeedsDisplayInRect:` to invalidate part of the view and schedule drawing for the next drawing cycle.

Most of the time you can compose UI from different views and layers and don't need to override `drawRect`.

### What about UIViewControllers

Methods from steps 1 and 2 have their view controllers counterparts:
- Update phase: `updateViewConstraints`.  
- Layout phase: `viewWillLayoutSubviews` / `viewDidLayoutSubviews`.  

### Intrinsic Content Size

**Intrinsic content size** is a natural size of a view based on its content. For example, an image views's intrinsic content size is the size of it's image. Few things about it: 

- It's a good practice to override `intrinsicContentSize` on a custom views returning an appropriate size for its content.
- If the view has an intrinsic size only for one dimension, you should still override it and return `UIViewNoIntrinsicMetric` for the other one.

In general, by following the above best practices, you will end up with simplified layout and reduced number of constraints.

### Alignment Rect

Alignment rects are used by auto layout engine to position views, thus separating view's frame from the content being layed out. 

- By default, alignment rect equals to the frame modified by `alignmentRectInsets`.
- To get a better control over it, override `alignmentRect(forFrame:)` and `frame(forAlignmentRect:)`.
- Example from http://www.informit.com/articles/article.aspx?p=2151265&seqNum=9


The constraint-based layout system uses alignment rectangles to align views, rather than their frame. This allows custom views to be aligned based on the location of their content while still having a frame that encompasses any ornamentation they need to draw around their content, such as shadows or reflections.

### Wrapping up

If you found this article useful, please share it in your social network.

It contains many details which are are easy to forget and it is handful to keep them consolidated to be able to freshen your knowledge at a glance.

[autolayout-guide]: https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/