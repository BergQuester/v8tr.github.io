---
layout: post
title: "Notifications and NotificationCenter: pattern or anti-pattern?"
permalink: /2018-01-27-notifications-pattern-or-anti-pattern/
---

You are making your way through the cobwebs of hundreds lines of code. You set dozens of breakpoints and your head is overflowing because of focusing on too many things simultaneously. Does it sound familiar to you? If you have seen one application that heavily utilizes notifications API, you've seen them all.

Have you ever asked yourself: who is to blame? Is it the author of the code or maybe its all about the notifications API? 

Lets finally clear up the misconceptions and answer the question: are the notifications considered to be a pattern or anti-pattern?

In this article the following topics will be covered:
* Pros and Cons of `Notification` and `NotificationCenter` API
* Rules of thumb when working with notifications
* Alternative techniques
* The verdict: pattern or anti-pattern?

## Cons of `Notifications` and `NotificationCenter`

**Hard to understand what the system actually does**

Every notification-based flow consists of the following steps:

1. Emit
2. Subscribe
3. Handle
4. Unsubscribe

The steps are usually located in different files, classes and functions and to follow the flow of execution, you must keep all of them in your mind simultaneously. Most of the time it's impossible to do just by reading the code and you will have to conduct live debugging with dozens of breakpoints.

**Creates one-to-many and many-to-many relationships**

In a project that heavily utilizes notifications its inevitable to have notifications with multiple subscribers or publishers, or even both. This creates lots of one-to-many and many-to-many relationships in your object graph which are way more complicated to manage compared to one-to-one ones.

**Subscribers coupling**

Subscribers are indirectly coupled with each other through the notification's interface. The backwards force is applied by clients upon interfaces. Thus, some subscribers might demand changes in the notification's interface which will result in a cascade of changes in the rest of the subscribers.

**Breaks encapsulation**

Notifications often contain some data which results in a global knowledge of private data that becomes available for any subscriber.

**Non-deterministic behavior**

Chances high to end up with non-deterministic bugs due to synchronization issues, because `NotificationCenter` does not define an order of notifying subscribers.

**Leaves lots of room for mistake**
 
Subscribing / unsubscribing for notifications often needs to be tied to `ViewControllers` life cycle and is a very common source of bugs. What is more, adding first notification often leads to a so-called "notifications explosion", when dozens of others are added blazing fast.

## A look on the bright side

**Lowers coupling**

Some direct references to instances can be removed which reduces overall coupling between classes and modules.

**Fast on early stages**

Any class can register for notifications disregarding the existing objects graph. On early development stages it's usually faster than modifying the existing graph.

## Verdict: pattern or anti-pattern?

By this time it must be clear that notifications are anti-pattern and should be avoided for the majority of the cases. Lets see what options do we have in regard to notifications usage.

**Rules of thumb**

1. Use alternative communication patterns:
    * Callbacks
    * Delegates
    * Target-actions
    * Custom [observers][observer-def] with explicit contracts and deterministic order of notifying subscribers
2. Sometimes, when you deal with iOS standard frameworks, 3rd parties or legacy code, notifications are inevitable. Use [adapters][adapter-def] and [facades][facade-def] to wrap them up and do not let them leak outside.

## Wrapping up


All OOP design principles and patterns target single goal: decrease code complexity. Notifications lend themselves to the opposite. Projects that heavily use `Notification` and `NotificationCenter` API usually end up having spaghetti code that lacks clarity even for original developers. Such projects are hard to manage and maintane.

Follow the suggested rules of thumb if you have to deal with notifications. Consider alternative communication patterns for your application, because for the majority of the cases the best choice is to simply opt out of notifications usage.

[adapter-def]: https://en.wikipedia.org/wiki/Adapter_pattern
[facade-def]: https://en.wikipedia.org/wiki/Facade_pattern
[observer-def]: https://en.wikipedia.org/wiki/Observer_pattern