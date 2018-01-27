---
layout: post
title: "Notifications: pattern or anti-pattern?"
permalink: /2018-01-27-notifications-pattern-or-anti-pattern/
---

Notifications are well-known communication pattern used in one or another way almost in every program. Standard Cocoa frameworks widely utilize notifications to communicate with their clients. Does it necessary mean that its a good technique? Lets clear up the misconceptions and answer the question: are the notifications considered to be a pattern or anti-pattern?

### Cons of `Notifications` and `NotificationCenter`

You are making your way through the cobwebs of hundreds lines of code. You set dozens of breakpoints and your head is overflowing because of focusing on too many things simultaneously. Does it sound familiar to you? If you have seen one application that heavily utilizes `Notifications` API, you've seen them all. Lets identify the core `Notifications` problems which lead to such consequences.

**Hard to understand what the system actually does**

Every notification-based flow consists of the following steps:  

1. Publish
2. Subscribe
3. Handle
4. Unsubscribe

The steps are usually located in different files, classes and functions and to follow the flow of execution, you must keep all of them in your mind simultaneously. Most of the time it's impossible to do just by reading the code and you will have to set lots of breakpoints and conduct live debugging.

**Creates one-to-many and many-to-many relationships**

In a project that heavily utilizes `Notifications` its inevitable to have multiple subscribers or publishers, or even both, for a single `Notification`. This creates lots of one-to-many and many-to-many relationships in your object graph which are way more complicated to manage compared to one-to-one ones.

**Subscribers coupling**

Subscribers are indirectly coupled with each other through the `Notification`'s interface. The backwards force is applied by clients upon interfaces. Thus, some subscribers might demand changes in the `Notification`'s interface which will result in a cascade of changes in the rest of the subscribers.

**Breaks encapsulation**

`Notifications` often carry some extra information which results in a global knowledge of private data available for any subscriber.

**Non-deterministic behavior**

Chances high to end up with non-deterministic bugs due to synchronization issues, because `NotificationCenter` does not define an order of notifying subscribers.

**Leaves lots of room for mistake**
 
Subscribing / unsubscribing for `Notifications` often needs to be tied to `ViewControllers` life cycle and is a very common source of bugs. What is more, adding first `Notification` often leads to a so-called "notifications explosion", when dozens of others are added blazing fast.

### A look on the bright side

Lets discuss advantages of `Notifications` and see what outweights.

**Lowers coupling**

Many direct references can be removed from the object graph which reduces overall coupling between classes and modules.

**Fast on early stages**

`Notifications` pass data globally from any place of the program disregarding the existing object graph. On early development stages it's usually faster than modifying the existing graph and chaining calls.

## Verdict: pattern or anti-pattern?

By this time it must be clear that notifications are anti-pattern and should be avoided for the majority of the cases. Lets see what options do we have in regard to notifications usage.

1. Use alternative communication patterns:
    * Callbacks
    * Delegates
    * Target-actions
    * Custom [observers][observer-def] with explicit contracts and deterministic order of notifying subscribers
2. Sometimes, when you deal with iOS standard frameworks, 3rd parties or legacy code, `Notifications` are inevitable. Use [adapters][adapter-def] and [facades][facade-def] to wrap them up and do not let them leak outside.

### Wrapping up

All OOP design principles and patterns target single goal: deal with code complexity. `Notifications` most of the time lend themselves to the opposite. Projects that heavily use `Notification` and `NotificationCenter` API usually end up having spaghetti code that lacks clarity even for original developers.

Follow the suggested rules of thumb if you have to deal with `Notifications`. Consider alternative communication patterns for your application, because for the majority of the cases the best choice is to simply opt out of notifications usage.

[adapter-def]: https://en.wikipedia.org/wiki/Adapter_pattern
[facade-def]: https://en.wikipedia.org/wiki/Facade_pattern
[observer-def]: https://en.wikipedia.org/wiki/Observer_pattern