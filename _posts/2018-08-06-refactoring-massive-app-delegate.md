---
layout: post
title: Refactoring Massive App Delegate
permalink: /refactoring-massive-app-delegate/
share-img: "/img/massive_app_delegate_share.png"
---

App delegate connects your app and the system and is usually considered to be the core of every iOS project. The common tendency is that it keeps growing as the development goes, gradually sprouting with new features and responsibilities, being called here and there and eventually turning into spaghetti code.

The cost of breaking anything inside the app delegate is extremely high due to the influence it has over your app. Undoubtedly, keeping this class clean and concise is crucial for the healthy iOS project.

In this article let's have a look at different methods of how app delegates can be made concise, reusable and testable.

### Problem Statement

The app delegate is the root object of your app. It ensures the app interacts properly with the system and with other apps. It's very common for app delegate to have dozens of responsibilities which is makes it difficult to change, expand and test.

Even [Apple encourages](https://developer.apple.com/documentation/uikit/uiapplicationdelegate) you to put at least 3 responsibilities in your `AppDelegate`.

By investigating a couple of dozens of [most popular open-source iOS apps](https://github.com/dkhamsing/open-source-ios-apps) I composed a list of responsibilities that are often put into app delegates. I am sure each of us either wrote such code or had a luck to support a project with similar mess.
- Initialize numerous third-party libraries
- Initialize Core Data stack and manage migrations
- Configure app state for unit or UI tests
- Manage `UserDefaults`: setups first launch flags, save and load data
- Handle Home screen quick actions
- Manage notifications: request permissions, store token, handle custom actions, propagate notifications to the rest of the app
- Configure `UIAppearance`
- Manage app badge counter
- Manage background tasks
- Manage UI stack configuration: pick initial view controller, perform root view controller transitions
- Play audio
- Manage analytics
- Print debug logs
- Manage device orientation
- Conform to various delegate protocols, especially from third parties
- Prompt alerts

I am sure the list is not limited to the aforementioned.

Such bloated app delegates fall under the definitions of the Blob anti-pattern and spaghetti code. Obviously, supporting, expanding and testing such class is very complex and error-prone. For example, looking at [Telegram's AppDelegate's source code](https://github.com/peter-iakovlev/Telegram/blob/public/Telegraph/TGAppDelegate.mm) inspires so much terror in me.

Let's call such classes **Massive App Delegates** to follow a renown term *Massive View Controller* that describes very similar view controller symptoms.

### Solution

After we agreed that the problem of *Massive App Delegate* exists and is highly important, let's take look at possible solutions or how I call them 'recipes'.

Each recipe must satisfy next criteria:
- Follow [single responsibility principle](https://en.wikipedia.org/wiki/Single_responsibility_principle).
- Easy to expand.
- Easy to test.

### Recipe #1: Command Design Pattern

The **command** pattern describes objects, called *commands*, that represent a single action or event. Such objects encapsulate all parameters required to trigger themselves, thus the caller of a command does not posses any knowledge about what the command does and who is the responder.

For each app delegate responsibility we define a command. The name of the command suggests its designation.

<script src="https://gist.github.com/V8tr/044dc47776cfd0ae628f3fcea16d718e.js"></script>

Next we define `StartupCommandsBuilder` that encapsulates the details about how the commands are created. `AppDelegate` calls the builder to initialize commands and then triggers them.

<script src="https://gist.github.com/V8tr/402f4663e34bd4810274e33e3a7e05ad.js"></script>

New commands can be added directly to the builder without any changed to `AppDelegate`.

Our solution satisfies the defined criteria:
- Each command has single responsibility.
- It is easy to add new commands without changing `AppDelegate`'s code.
- Commands can be easily tested in isolation.

### Recipe #2: Composite Design Pattern

**Composite** design pattern allows to treat hierarchies of objects as if it were a single instance. A prominent example in iOS is `UIView` with its subviews.

The main idea is to have a composite and leaf app delegates each having one responsibility, where the composite propagates all methods to the leafs.

<script src="https://gist.github.com/V8tr/a21302fae67f8a9236a3a704eb0e31bd.js"></script>

Next, implement leaf `AppDelegate`s that do the actual work.

<script src="https://gist.github.com/V8tr/8c3803be69b8ba3bccffab377cf51c7e.js"></script>

We define `AppDelegateFactory` that encapsulates the creation logic. Our main `AppDelegate` creates the composite delegates via the factory and passes to them all the method calls.

<script src="https://gist.github.com/V8tr/0bfa78ea06aa522b0b5e72328d83d4fc.js"></script>

It satisfies the criteria we defined at the beginning:
- Each sub-app-delegate has single responsibility.
- It is easy to add new `AppDelegate`s without changing the main ones code.
- App delegates can be easily tested in isolation.

### Recipe #3: Mediator Design Pattern

**Mediator** object encapsulates the interaction policies in a hidden and unconstraining way. Objects being manipulated by mediator have no idea it exists. It sits quietly behind the scenes and imposes its policies without their permission or knowledge.

If you want to learn more about this pattern, I recommend checking [Mediator Pattern Case Study]({{ "/mediator-pattern-case-study/" | absolute_url }}).

Let's define `AppLifecycleMediator` that propagates `UIApplication` life cycle events to underlying listeners. The listeners must conform to `AppLifecycleListener` protocol that can be expanded with new methods if needed.

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

Such code is easy to change, as it will not result in a cascade of changes all over your app. It is very flexible and can extracted and reused in future.

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---