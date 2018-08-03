---
layout: post
title: Refactoring Massive App Delegate
permalink: /refactoring-massive-app-delegate/
share-img: "/img/massive_app_delegate_share.png"
---

App delegate is the heart of your app. The common tendency is that it keeps growing as the development goes, gradually sprouting with new features and responsibilities, being called here and there and eventually turning your app into spaghetti code.

The cost of breaking the smallest thing in your app delegate is extremely high due to the huge influence it has over your app. Thus, keeping this class clean and concise is crucial.

It this article let's have a look at different methods of how app delegates can be made thin, expandable and testable.

### Problem Statement

The app delegate is the root object of your app. It ensures the app interacts properly with the system and with other apps. It's very common for app delegate to have dozens of responsibilities which is makes it difficult to change, expand and test.

Even [Apple encourages](https://developer.apple.com/documentation/uikit/uiapplicationdelegate) you to put at least 3 responsibilities in your `AppDelegate`.

By investigating a couple of dozens of [most popular open-source iOS apps](https://github.com/dkhamsing/open-source-ios-apps) I composed a list of responsibilities that are often put to app delegates. I am sure each of us either wrote such code or had a luck to support a project with similar mess.
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

Such bloated app delegates fall under the definitions of Blob anti-pattern and spaghetti code. Obviously, supporting, expanding and testing it is very complex and often near to impossible. For example, looking at [Telegram's AppDelegate's source code](https://github.com/peter-iakovlev/Telegram/blob/public/Telegraph/TGAppDelegate.mm) inspires so much terror in me.

Let's call such classes *Massive App Delegates* to follow a renown term *Massive View Controller* that describes very similar view controller symptoms.

### Solution

After we agreed that the problem of *Massive App Delegate* exists and is highly important, let's take look at possible solutions.

I am suggesting 3 recipes of refactoring the bloated app delegate.

Each recipe must satisfy next criteria:
- Follows single responsibility principle.
- Easy to expand.
- Easy to test.

### Recipe #1: Command Design Pattern

The **command** pattern describes objects, called *commands*, that represent a single action or event. Such objects encapsulate all parameters required to trigger themselves, thus the caller of a command does not posses any knowledge about what it does and who is the responder.

First off, define several startup commands:

<script src="https://gist.github.com/V8tr/044dc47776cfd0ae628f3fcea16d718e.js"></script>

Now let's create and call the above commands from `AppDelegate`.

<script src="https://gist.github.com/V8tr/402f4663e34bd4810274e33e3a7e05ad.js"></script>

`StartupCommandsBuilder` encapsulates the details about how the commands are created. It can be easily extended with new commands and properties without adding any new code to `AppDelegate`.

It satisfies the criteria we defined:
- Each command has single responsibility.
- It is easy to add new commands without changing `AppDelegate`'s code.
- Commands can be easily tested in isolation.

### Recipe #2: Composite Design Pattern

**Composite** design pattern allows to treat hierarchies of objects as if it were a single instance. A prominent example in iOS is `UIView` with its subviews.

We define a composite app delegate that propagates all methods to leaf app delegates.

<script src="https://gist.github.com/V8tr/a21302fae67f8a9236a3a704eb0e31bd.js"></script>

Next, implement concrete `AppDelegate`s.

<script src="https://gist.github.com/V8tr/8c3803be69b8ba3bccffab377cf51c7e.js"></script>

Now our main `AppDelegate` should pass all method calls to the composite.

<script src="https://gist.github.com/V8tr/0bfa78ea06aa522b0b5e72328d83d4fc.js"></script>

It satisfies the criteria we defined at the beginning:
- Each sub-app-delegate has single responsibility.
- It is easy to add new `AppDelegate`s without changing the main ones code.
- App delegates can be easily tested in isolation.

### Recipe #3: Mediator Design Pattern

**Mediator** object encapsulates the interaction policies in a hidden and unconstraining way. Objects being manipulated by mediator have no idea it exists. It sits quietly behind the scenes and imposes its policies without their permission or knowledge. 

If you want to learn more about mediator, I recommend checking [Mediator Pattern Case Study]({{ "/mediator-pattern-case-study/" | absolute_url }}).

Let's define `AppLifecycleMediator` that propagates `UIApplication` life cycle events to underlying listeners.

<script src="https://gist.github.com/V8tr/3edc83fa1a457a9f6bb54cb1b0f9d2b7.js"></script>

Now it can be added to `AppDelegate` with 1 line of code.

<script src="https://gist.github.com/V8tr/f2a45c4bc2cd443a43019851df44cc11.js"></script>

The mediator automatically subscribes to all events. `AppDelegate` only needs to initialize it once and let it do its work.

It satisfies the criteria we defined at the beginning:
- Each listener has single responsibility.
- It is easy to add new listeners without changing `AppDelegate`'s code.
- Each listener as well as the mediator itself can be easily tested in isolation.

### Summary

We agreed that most of `AppDelegate`s are unreasonably big, overcomplicated and have too much responsibilities. We called such classes *Massive App Delegates*.

By applying software design patterns, *Massive App Delegate* can be split into several classes each of which has single responsibility and can be tested in isolation. 

Such code is loosely coupled with other parts of your app and thus cannot break them. It can be easily changed, extracted and reused in different apps.

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---