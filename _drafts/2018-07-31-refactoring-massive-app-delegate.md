---
layout: post
title: Refactoring Massive App Delegate
permalink: /refactoring-massive-app-delegate/
share-img: "/img/benchmarking-locking-apis-share.png"
---

Topics:

### Problem Statement

According to Apple, App Delegate is capable of doing following actions: https://developer.apple.com/documentation/uikit/uiapplicationdelegate.

By investigating couple of dozens [open-source iOS apps](https://github.com/dkhamsing/open-source-ios-apps) I composed a list of responsibilities that are often put to App Delegate. I am sure each of us either wrote such code or had a luck to support a project with similar massive App Delegate.
- Initializes Core Data Stack
- Manages Core Data migrations
- Manages UserDefaults: setups first launch flags, caches data, backups data
- Initializes 3rd parties
- handles Home scree quick actions
- handles custom actions from notifications
- configures UIAppearance
- Handles local and push notifications
- Manages badge counter
- Observes notifications from app
- Manages network session expiration
- Manages background tasks
- Performs business logic to select initial view controller
- Creates UI stack: tab bar, selects different UI for iPhone/iPad
- Performs root view controller changes and animations
- Plays audio
- Manages analytics
- Logs data to console
- Manages device orientation
- Conforms to various delegate protocols, especially from 3rd parties
- Monitors network connectivity status
- Prompts rating alerts
- Prompts force update alerts

I am sure the list is not limited to the aforementioned.

Such bloated app delegates fall under the definitions of Blob anti-pattern and spaghetti code. Obviously, supporting, expanding and testing it is very complex and often near to impossible. For example, looking at Telegram's `AppDelegate` source code inspires so much terror https://github.com/peter-iakovlev/Telegram/blob/public/Telegraph/TGAppDelegate.mm in me.

Let's call such classes *Massive App Delegates* to follow a renown term *Massive View Controllers* that describes a very similar problem related to view controllers.

### Give Me the Solution

After we agreed that the problem of *Massive App Delegate* exists and is highly important, let's take look at possible solutions.

I am suggesting X recipes of refactoring the bloated app delegate.

### Recipe 1: The Command Design Pattern

The **command** pattern describes objects, called *commands*, that represents a single action or event. Such object encapsulates all parameters required to trigger itself, thus the caller of a command does not posses any knowledge about what it does and who is the responder.

First off, define several startup commands:

<script src="https://gist.github.com/V8tr/044dc47776cfd0ae628f3fcea16d718e.js"></script>

Now let's create and call the above commands from `AppDelegate`.

<script src="https://gist.github.com/V8tr/402f4663e34bd4810274e33e3a7e05ad.js"></script>

`StartupCommandsBuilder` encapsulates the details about how the commands are created. It can be easily extended with new commands and properties without adding any new code to `AppDelegate`.

### Recipe 2: The Mediator Design Pattern

**Mediator** object encapsulates the interaction policies in a hidden and unconstraining way. Objects being manipulated by mediator have no idea it exists. It sits quietly behind the scenes and imposes its policies without their permission or knowledge. 

If you want to learn more about mediator, I recommend checking [Mediator pattern by Search History example]({{ "/2018-02-09-mediator-search-history/" | absolute_url }}).

Let's define `AppLifecycleMediator` that propagates `UIApplication` life cycle events to underlying listeners.

<script src="https://gist.github.com/V8tr/3edc83fa1a457a9f6bb54cb1b0f9d2b7.js"></script>

Now it can be added to `AppDelegate` with 1 line of code.

<script src="https://gist.github.com/V8tr/f2a45c4bc2cd443a43019851df44cc11.js"></script>

The mediator automatically subscribes to all events without any explicit calls to it. Furthermore, it can be easily extended with new listeners without making any changes to `AppDelegate`.

### Recipe 3: The Coordinator Design Pattern

See https://github.com/TrustWallet/trust-wallet-ios

### Summary

We agreed that most of AppDelegates are unreasonably huge, overcomplicated and have too much responsibilities.

I am sure that the list of recipes is far from exhaustive. I am encouraging you to add your ideas in comments.

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---