---
layout: post
title: View layout cycle cheat sheet
permalink: /2018-03-14-view-layout-cycle-cheat-sheet/
---

To build effective UI in iOS apps it's extremely important to understand the cycle `UIView` passes before being brought to the screen. Lots of UI bugs and performance issues come from the lack of this knowledge. This article will be useful 


It contains many details which are are easy to forget and it's handful to keep them consolidated to be able to freshen your knowledge at a glance.

This article assumes that you are familiar with AutoLayout. Otherwise, I suggest reading through [Auto Layout Guide][autolayout-guide] by Apple and then coming back to this article.

## View layout cycle




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