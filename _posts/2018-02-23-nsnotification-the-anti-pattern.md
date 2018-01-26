# Notifications: pattern or anti-pattern?
# NSNotification: the anti-pattern
# NSNotification: the anti-pattern demystified
# Notifications and NotificationCenter case study: pattern or anti-pattern?

Similar articles:
https://davidnix.io/post/stop-using-nsnotificationcenter/
https://objcsharp.wordpress.com/2013/08/28/why-nsnotificationcenter-is-bad/


## Introduction

If you have seen one application that heavily utilizes notifications API, you've seen all of them. Every time you try to understand the flow of data and logic, you have to conduct live debugging with tons of breakpoints. I know how you felt, making your way through the cobwebs of data and logic flows. Have you ever asked yourself: is it the authors of the code to blame or maybe its all about the notifications API? 

Lets finally clear up the misconceptions and answer the question: are the notifications considered to be a pattern or anti-pattern?

In this article we will cover the following topics:
* Cons of Notifications and NotificationCenter API
* Pros
* Notifications use cases
* Alternatives to NSNotification
* The verdict: Pattern or anti-pattern?
* Wrapping up

## Cons of Notifications and NotificationCenter API

#### Code complexity

Every notification-based flow consists of these steps:

1. Emit
2. Subscribe
3. Handle
4. Unsubscribe

The steps are usually located in different files, classes and functions and to follow the flow of execution, you must keep all of them in mind. This results in following major problems:

1. Hard to understand what system actually does

Its always difficult to follow such an intricate flow of execution and at the same time keep in mind lots of units of code. Its almost impossible to do by just reading the code, thus most of the time you will conduct live debugging with dozens of breakpoints.

2. Creates one-to-many and many-to-many relationships in object graph

In a project that heavily utilizes notifications its inevitable to have notifications with multiple subscribers or emitters, or even both. This creates lots of one-to-many and many-to-many relationships in your object graph which are way more complicated to manage compared to one-to-one ones.

3. Clients coupling

Clients of a notification they depend on its interface and thus are indirectly coupled with each other through it. The backwards force is applied by clients upon interfaces. Thus, some clients might demand changes in notification's interface which will result in a cascade of changes in the rest of the clients.

4. Violates encapsulation

[Encapsulation][encapsulation-def] is a fundamental OOP principle and is defined as a language mechanism for restricting direct access to some of the object's components. Notifications often contain some data which becomes available to any subscriber in global scope. Global knowledge of private data.

5. Non-deterministic

Changes high to end up with non-deterministic bugs due to synchronization issues, because NotificationCenter does not define an order of notifying subscribers.

6. Leaves lots of room for mistake

    * Easy to make mistakes when subscribing / unsubscribing
    * Easily leads to "notifications explosion" - after adding first notification, dozens of others are added blazing fast

#### Rules of thumb

1. Sometimes, when you deal with iOS standard frameworks, 3rd parties or legacy code, notifications are inevitable. Use [adapters][adapter-def] or [facades][facade-def] to wrap them up and do not let them leak outside.
2. Use alternative communication patterns:
    * Callbacks
    * Delegation
    * Implement custom [observer][observe-def] with explicit contract and deterministic order of notifying subscribers
    * Target-action

* Inter-module communication  
    * Standard iOS frameworks (keyboard, device orientation)
    * Custom modules that communicate with their clients by means of notifications, ex: notify about network connection changes

## Wrapping up

Will end up with spaghetti code and break SOLID principles.

All OOP design principles and patterns target single goal: decrease code complexity. Projects that heavily use notifications API posses the opposite: they INCREASE code complexity and leave plenty of room for mistake and abuse. This results in spaghetting code and the system begins to lack clarity even for original developer

[encapsulation-def]: https://en.wikipedia.org/wiki/Encapsulation_(computer_programming)
[adapter-def]: https://en.wikipedia.org/wiki/Adapter_pattern
[facade-def]: https://en.wikipedia.org/wiki/Facade_pattern
[observer-def]: https://en.wikipedia.org/wiki/Observer_pattern