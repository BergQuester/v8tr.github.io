---
layout: post
title: View layout cycle cheat sheet
permalink: /2018-03-14-view-layout-cycle-cheat-sheet/
---

- Introduction
- Diagram with explanation
- Each step in-depth
- Anatomy of constraint
- Dependency between steps
- Things to remember
- Wrapping up

Use https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/ModifyingConstraints.html#//apple_ref/doc/uid/TP40010853-CH29-SW2 for reference

####

`UIView` is an essential part of every iOS application’s UI. It’s extremely important to understand which steps it undergoes before being brought to the screen. Lack of this information will sooner or later lead to UI glitches or performance issues in your app. This article consolidates information about the cycle `UIView` passes as a part of it’s presentation process in a brief and easy-to-remember way, so that it can be treated as a cheat sheet on the matter.

This article assumes that you are familiar with AutoLayout. Otherwise, I suggest reading through [Auto Layout Guide][autolayout-guide] by Apple and then return to this article.

### View layout cycle

<p align="center">
    <img src="{{ "/img/autolayout_1.png" | absolute_url }}" alt="View auto layout passes"/>
</p>

After a `UIView` instance has been initialized, it passes 3 steps: update, layout and rendering. Let’s have a closer look at each of them.

#### Update step

The constraints of views and view controllers are calculated during this step. Here are the details of the process:

- Happens top-down: the system goes from superview to its subviews and calls `updateViewConstraints()` for each.
- `setNeedsUpdateConstraints()` schedules an update for the future. If there are no pending updates, the whole step is skipped.
- `updateConstraintsIfNeeded()` performs all pending updates in place. Call together with `setNeedsUpdateConstraints()` to force an immediate update. 
- View controllers undergo the very same process and have similar family of methods.

The only case when you'll need to override `updateViewConstraints` is to batch constraints update, but it's very unlikely to happen in your project, because for the most of the time there are better ways to improve UI performance. Make sure you read the docs of [updateViewConstraints](https://developer.apple.com/documentation/uikit/uiview/1622512-updateconstraints) before overriding it, as they contain important details.

#### Layout step

During this step the frames of each view are updated with the rectangles calculated in previous phase.

- Happens bottom-up: the system goes from subviews to subviewss calling `layoutSubviews` and `viewWillLayoutSubviews` for view controllers.
- When overriding,  invalidate the layout of views in your subtree  before you call the superclass’s implementatio
- Don’t invalidate the layout of any views outside your subtree. This could create a feedback loop.
- Don’t call setNeedsUpdateConstraints or setNeedsLayout, otherwise deadloop
- Call superviews method

You will deal with this step most of the time, so it's important to understand all deta

Rendering

- triggered with setNeedsDisplay or inRect
- Override drawRect only if need CoreGraphics, Open GL ES or other custom drawing
- Default implementation does nothing


## Wrapping up

If you found this article useful, please share it in your social network.

It contains many details which are are easy to forget and it's handful to keep them consolidated to be able to freshen your knowledge at a glance.


[autolayout-guide]: https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/
[introspection-def]: https://en.wikipedia.org/wiki/Type_introspection
[witness-table-def]: https://github.com/apple/swift/blob/master/docs/SIL.rst#witness-tables
[opaque-type-def]: https://developer.apple.com/library/content/documentation/CoreFoundation/Conceptual/CFDesignConcepts/Articles/OpaqueTypes.html
[toll-free-bridging-def]: https://developer.apple.com/library/content/documentation/CoreFoundation/Conceptual/CFDesignConcepts/Articles/tollFreeBridgedTypes.html
[dump-docs]: https://developer.apple.com/documentation/swift/1539127-dump
[json-serialization-gist]: https://gist.github.com/V8tr/3ab9ab1a550415fae5d61aa39d3a2185
[automatic-hashable-equatable-gist]: https://gist.github.com/V8tr/4507110d40e0b62fb09f1600bd992a96
[sourcery-repo]: https://github.com/krzysztofzablocki/Sourcery
[swiftgen-repo]: https://github.com/SwiftGen/SwiftGen