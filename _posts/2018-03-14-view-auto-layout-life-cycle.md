---
layout: post
title: UIView Auto Layout life cycle
permalink: /view-auto-layout-life-cycle/
---

Auto Layout is among the most important topics when it comes to iOS development in general. It is extremely important to understand Auto Layout life cycle during development to save time and avoid naive mistakes. Lack of this information will sooner or later lead to UI glitches and performance issues in your app. This article consolidates information about the steps that every `UIView` with Auto Layout enabled undergoes before being presented on a screen.

This article makes an assumption that you are familiar with Auto Layout basics. Otherwise, I suggest reading through the Apple's [Auto Layout Guide][autolayout-guide] and then returning back.

### View layout cycle

<p align="center">
    <img src="{{ "/img/autolayout_1.svg" | absolute_url }}" alt="UIView Auto Layout life cycle - Auto Layout Steps"/>
</p>

Every `UIView` with enabled Auto Layout passes 3 steps after initialization: update, layout and render. These steps do not occur in a one-way direction. It's possible for one step to trigger another which will cause all subsequent phases to process again.

### Update step

This step is all about calculating view frame based on its constrains. The details are next:

- Happens top-down: the system goes from super- to its subviews and calls `updateViewConstraints()` for each.
- Call `setNeedsUpdateConstraints` to schedules constraints update for the near future.
- Call `updateConstraintsIfNeeded` to perform all pending updates in place. Call together with `setNeedsUpdateConstraints` to force an immediate update. 
- Override `updateViewConstraints` to boost performance by batching constraints update. 

For the most of the time there is no need to override `updateViewConstraints`. If you discover that current step is the bottleneck in your app's performance, make sure to check [updateViewConstraints](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621379-updateviewconstraints) docs before overriding it, as there are several important nuances. 

As a rule of thumb, do not make premature optimizations like batching updates. Change constraints in place followed by a combination of `setNeedsUpdateConstraints` and `updateConstraintsIfNeeded` calls.

### Layout step

During this step, frames of each view are updated with the rectangles calculated in the previous phase.

- Happens bottom-up: the system goes from super- to subviews calling `layoutSubviews` for each.
- Override `layoutSubviews` method when:
    - Constraints are not enough to express view's layout;
    - Frames are calculated programmatically;
- Call `setNeedsLayout` to schedule layout for the near future.
- Call `layoutIfNeeded` to force the view to update it's layout immediately.
- When overriding `layoutSubviews`:
    - Make sure to call `super.layoutSubviews()`;
    - Don't call `setNeedsLayout` or `setNeedsUpdateConstraints`, otherwise an infinite loop will be created;
    - Don't modify constraints of other views outside current hierarchy;
    - If any constraints from current hierarchy are changed, an update step will be triggered followed by another layout step, potentially creating an infinite loop;

<p></p>

### Rendering

This step is responsible for bringing pixels onto the screen. By default, `UIView` passes all the work to a backing `CALayer` that contains a pixel bitmap of the current view state. 

- The step is independent of whether Auto Layout is enabled for a view or not.
- Override `drawRect` when doing custom OpenGL ES, Core Graphics and UIKit drawing.
- Do not override `drawRect` when making any other than above changes, like updating background color, adding subviews etc., as they are handled automatically.
- By default `drawRect` method does nothing.
- Call `setNeedsDisplay` or `setNeedsDisplayInRect:` to invalidate part of the view and schedule drawing for the next drawing cycle.

Most of the time you can compose UI from different views and layers and don't need to override `drawRect`.

### What about UIViewControllers

Methods from steps 1 and 2 have their counterparts for the view controllers:
- Update phase: `updateViewConstraints`.
- Layout phase: `viewWillLayoutSubviews` / `viewDidLayoutSubviews`.

### Intrinsic Content Size

**Intrinsic content size** is a natural size of a view based on its content. For example, an image view's intrinsic content size is the size of it's image. Few things about it: 

- It's a good practice to override `intrinsicContentSize` for custom views returning an appropriate size for their content.
- If a view has an intrinsic size only for one dimension, you should still override `intrinsicContentSize` and return `UIViewNoIntrinsicMetric` for the unknown dimension.

In general, by following the above best practices, you will end up with simplified layout and reduced number of constraints.

### Alignment Rectangle

Alignment rectangles are used by auto layout engine to position views, thus separating their frame from the content being layed out. 

- By default, view's alignment rect equals to its frame modified by `alignmentRectInsets`.
- To get a better control over it, override `alignmentRect(forFrame:)` and `frame(forAlignmentRect:)`.

It is worth mentioning that the intrinsic content size refers to the alignment rectangle rather than the frame.

<p align="center">
    <img src="{{ "/img/alignment_rect_1.svg" | absolute_url }}" alt="UIView Auto Layout life cycle - Alignment rectangles, Intrinsic Content Size"/>
</p>

Consider the two views above that are centered in the same way by means of Auto Layout. The left is an image view who's image has a drop shadow effect. It's alignment rectangle is equal to it's frame, thus the shadow is taken into account during positioning. Conversely, the right one has shadow added by means of UIKit and it's alignment rectangle does not include shadow making it look visually correct. 

Let's have a closer look at their alignment rectangles represented by the dashed lines:

<p align="center">
    <img src="{{ "/img/alignment_rect_2.svg" | absolute_url }}" alt="UIView Auto Layout life cycle - Alignment rectangles, Intrinsic Content Size"/>
</p>

As you can see, the shadow is a part of the left view's alignment rectangle. Alternatively, it's not the part of the right view's one.

From the above image it must be clear how alignment rectangle and intrinsic content size affect view positioning during the Auto Layout process.

### Wrapping up

In the current article we briefly went through the three steps every `UIView` with Auto Layout enabled undergoes before being presented on the screen, namely: *constraints update*, *layout* and *render* (or display). Additionally, we discussed what are *intrinsic content size* and *alignment rectangle* and how they relate.

The points we covered in the current article make absolute minimum you should know on the subject. These details are easy to forget when you are not working with them for a long time, so it is handful to keep them consolidated to be able to freshen your knowledge at a glance.

[autolayout-guide]: https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/