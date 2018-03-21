---
layout: post
title: UIView Auto Layout life cycle
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

`UIView` is an essential part of every iOS application’s UI and it’s extremely important to understand which steps it undergoes before being brought to the screen. Lack of this information will sooner or later lead to UI glitches or performance issues in your app. This article consolidates information about the steps that every `UIView` with Auto Layout enabled passes as a part of it’s presentation process in a brief and easy-to-remember way, so that it can be treated as a cheatsheet on the matter.

This article makes an assumption that you are familiar with Auto Layout. Otherwise, I suggest reading through [Auto Layout Guide][autolayout-guide] by Apple and then return to this article.

### View layout cycle

<p align="center">
    <img src="{{ "/img/autolayout_1.png" | absolute_url }}" alt="UIView auto layout life cycle cheat sheet"/>
</p>

Every `UIView` instance that uses Auto Layout passes 3 steps after initialization: update, layout and rendering. Let’s have a closer look at each of them.

#### Update step

This step is all about calculating view frame based on it's constrains. The details are next:

- Happens top-down: the system goes from super- to its subviews and calls `updateViewConstraints()` for each.
- Call `setNeedsUpdateConstraints` to schedules constraints update for the next cycle.
- Call `updateConstraintsIfNeeded` to perform all pending updates in place. Call together with `setNeedsUpdateConstraints` to force an immediate update. 
- Override `updateViewConstraints` when you need to boost performance by batching constraints update. However, it is very rarely the case and for the most of the time you will update constraints in place and call a combination of `setNeedsUpdateConstraints()` and `updateConstraintsIfNeeded()` afterwards.

#### Layout step

During this step the frames of each view are updated with the rectangles calculated in the previous phase. You will deal with this step most of the time and it's important to have a thorough understanding of the process.

- Happens bottom-up: the system goes from super- to subviews calling `layoutSubviews()` for each.
- Override `layoutSubviews` method when constraints are not enough to express view's layout or you are calculating frames programmatically.
- Call `setNeedsLayout` to schedule layout for the next cycle.
- Call `layoutIfNeeded` to force the view to update its layout immediately.
- When overriding `layoutSubviews`:
    - Make sure to call `super.layoutSubviews()`;
    - Don't call `setNeedsLayout` or `setNeedsUpdateConstraints`, otherwise an infinite loop will be created;
    - Don't modify constraints of views outside your view's hierarchy.

#### Rendering

- triggered with setNeedsDisplay or inRect
- Override drawRect only if need CoreGraphics, Open GL ES or other custom drawing
- Default implementation does nothing

#### What about UIViewControllers



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