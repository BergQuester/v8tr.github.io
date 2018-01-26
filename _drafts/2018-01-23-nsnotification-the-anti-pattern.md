---
layout: post
title: "Notifications: pattern or anti-pattern?"
---

Title examples:  
Notifications: pattern or anti-pattern?  
NSNotification: the anti-pattern  
NSNotification: the anti-pattern demystified  
Notifications and NotificationCenter case study: pattern or anti-pattern?  

## Introduction

**If you have seen one application that heavily utilizes notifications API, you've seen all of them**. Every time you try to understand execution flow, you have to conduct live debugging with dozens of breakpoints. I know how you felt, making your way through the cobwebs of the lines of code. Have you ever asked yourself: who is to blame? Is it the author of the code or maybe its all about the notifications API? 

Lets finally clear up the misconceptions and answer the question: are the notifications considered to be a pattern or anti-pattern?

In this article we will cover the following topics:
* Pros and Cons of notifications
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

The steps are usually located in different files, classes and functions and to follow the flow of execution, you must keep all of them in mind. Most of the time it's impossible to do just by reading the code and you will have to conduct live debugging with dozens of breakpoints.

**Creates one-to-many and many-to-many relationships**

In a project that heavily utilizes notifications its inevitable to have notifications with multiple subscribers or publishers, or even both. This creates lots of one-to-many and many-to-many relationships in your object graph which are way more complicated to manage compared to one-to-one ones.

**Clients coupling**

Subscribers are indirectly coupled with each other through the notification's interface. The backwards force is applied by clients upon interfaces. Thus, some subscribers might demand changes in the notification's interface which will result in a cascade of changes in the rest of the subscribers.

**Violates encapsulation**

[Encapsulation][encapsulation-def] is a fundamental OOP principle and is defined as a language mechanism for restricting direct access to some of the object's components. Notifications often contain some data which results in a global knowledge of private data that becomes available for any subscriber.

**Non-deterministic behavior**

Changes high to end up with non-deterministic bugs due to synchronization issues, because `NotificationCenter` does not define an order of notifying subscribers.

**Leaves lots of room for mistake**
 
Subscribing / unsubscribing for notifications often needs to be tied to `ViewControllers` life cycle and is a very common source of bugs. What is more, adding first notification often leads to a so-called "notifications explosion", when dozens of others are added blazing fast.

## A look on the bright side

**Lowers coupling**

Some direct references to instances can be removed which reduces overall coupling between classes and modules.

**Fast on early stages**

Any class can register for notifications disregarding the existing objects graph. On early development stages it's usually faster than changing existing objects graph.

## The verdict: pattern or anti-pattern?

By this time must be obvious: will end up with spaghetti code and break SOLID principles.

**Rules of thumb**

1. Sometimes, when you deal with iOS standard frameworks, 3rd parties or legacy code, notifications are inevitable. Use [adapters][adapter-def] or [facades][facade-def] to wrap them up and do not let them leak outside.
2. Use alternative communication patterns:
    * Callbacks
    * Delegation
    * Target-action
    * Custom [observers][observe-def] with explicit contracts and deterministic order of notifying subscribers


## Wrapping up


All OOP design principles and patterns target single goal: decrease code complexity. Projects that heavily use notifications API posses the opposite: they INCREASE code complexity and leave plenty of room for mistake and abuse. This results in spaghetti code and the system begins to lack clarity even for original developer



[encapsulation-def]: https://en.wikipedia.org/wiki/Encapsulation_(computer_programming)
[adapter-def]: https://en.wikipedia.org/wiki/Adapter_pattern
[facade-def]: https://en.wikipedia.org/wiki/Facade_pattern
[observer-def]: https://en.wikipedia.org/wiki/Observer_pattern