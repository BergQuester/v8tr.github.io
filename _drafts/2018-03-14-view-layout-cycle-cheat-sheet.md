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

`UIView` is an essential part of every iOS application’s UI and it’s extremely important to understand which steps it undergoes before being brought to the screen. Lack of this information will sooner or later lead to UI glitches or performance issues in your app. This article consolidates information about the steps that every `UIView` with Auto Layout enabled passes as a part of it’s presentation process in a brief and easy-to-remember way, so that it can be treated as a cheatsheet.

This article makes an assumption that you are familiar with Auto Layout. Otherwise, I suggest reading through [Auto Layout Guide][autolayout-guide] by Apple and then return to this article.

### View layout cycle

<p align="center">
    <img src="{{ "/img/autolayout_1.svg" | absolute_url }}" alt="UIView auto layout life cycle cheat sheet"/>
</p>

Every `UIView` with enabled Auto Layout passes 3 steps after initialization: update, layout and render. Let’s have a closer look at each of them.

#### Update step

This step is all about calculating view frame based on it's constrains. The details are next:

- Happens top-down: the system goes from super- to its subviews and calls `updateViewConstraints()` for each.
- Call `setNeedsUpdateConstraints` to schedules constraints update for the near future.
- Call `updateConstraintsIfNeeded` to perform all pending updates in place. Call together with `setNeedsUpdateConstraints` to force an immediate update. 
- Override `updateViewConstraints` to boost performance by batching constraints update. 
- When changing constaints, do this in place and call a combination of `setNeedsUpdateConstraints` and `updateConstraintsIfNeeded` afterwards.

For the most of the time there is no need to override `updateViewConstraints`. If you discover that constraints update phase is the bottleneck in your app's performance, make sure to check [updateViewConstraints](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621379-updateviewconstraints) docs before overriding it, as there are several important nuances.

#### Layout step

During this step the frames of each view are updated with the rectangles calculated in the previous phase. You will deal with this step most of the time and it's important to have a thorough understanding of the process.

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
    - If any constaints from current hierarchy are changed, an update step will be triggered followed by another layout step, potentially creating an infinite loop;

#### Rendering

This step is responsible for bringing pixels onto the screen. By default, `UIView` passes all the work to a backing `CALayer` that contains a pixel bitmap of current view state. 

- The step is independent of whether Auto Layout is enabled for a view or not.
- Override `drawRect` when doing custom OpenGL ES, Core Graphics and UIKit drawing.
- Do not override `drawRect` when making any other changes, like updaing background color, addings subviews etc., as it's handled automatically.
- By default `drawRect` method does nothing.
- Call `setNeedsDisplay` or `setNeedsDisplayInRect:` to invalidate part of the view and schedule drawing for the near drawing cycle.

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