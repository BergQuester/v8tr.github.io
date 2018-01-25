# Notifications: pattern or anti-pattern?
# NSNotification: the anti-pattern
# NSNotification: the anti-pattern demystified

Similar articles:
https://davidnix.io/post/stop-using-nsnotificationcenter/
https://objcsharp.wordpress.com/2013/08/28/why-nsnotificationcenter-is-bad/


## Introduction

I know how you felt, making your way through the cobwebs of notification-driven data and business logic flows. What did you think about the author of these lines of code at that moment? Or maybe it was your code? 

Lets finally clear it up.



In this article we will cover the following topics:
* Why NSNotification considered to be an anti-pattern
* Valid usages of NSNotification
* Alternatives to NSNotification

2. Let's talk about why you should avoid using NSNotification

2.1 Spaghetti code. Complicates data flow tracking  
    * Reason: usage and emission are very far in code => hard to track  
    * Building a system with many services each directly subscribing to events from other services can make it very hard to understand what the system actually does. Finding the overall process can be quite difficult without going through the code in each service.
2.2 Неявные интерфейсы между модулями => Косвенная зависимость модулей через интерфейс нотификации  
2.3 Easy to be used wrong
    * Inverstion of control violation
2.4 If extra data needs to be passed with notification => violates incapsulation. Every client of notification can use this data. Global knowledge of private data.  
2.5 One-to-many relationships are hard to manage and should be replaced with one-to-one relationships wherever possible.  
2.6 Changes high to end up with non-deterministic bugs due to synchronization issues
2.7 Side-effect when event is fired and you have multiple listeners attached to it


3. Valid use cases of NSNotification

* Inter-module communication  
    * Standard iOS frameworks (keyboard, device orientation)
    * Custom modules that communicate with their clients by means of notifications, ex: notify about network connection changes

4. Alternatives

* Callbacks
* Delegation
* Implement own observer with explicit contract
* Command pattern

5. Wrapping up

Will end up with spaghetti code and break SOLID principles.