1. Introduction

NSNotifcation lovers - I have bad news for you.

In this article we will cover the following topics:
* Why NSNotification considered to be an anti-pattern
* Valid usages of NSNotification
* Alternatives to NSNotification

2. Let's talk about why you should avoid using NSNotification

2.1 Spaghetti code. Complicates data flow tracking  
    * Reason: usage and emission are very far in code => hard to track  
2.2 Неявная связь между модулями  
2.3 Violates Interface segregation principle  
2.4 Easy to abuse: start with one, very likely to explode in number  
2.5 If extra data needs to be passed with notification => violates encapsulation. Every client of notification can use this data. Global knowledge of private data.  
2.6 One-to-many relationships are hard to manage and should be avoided wherever possible.  

3. Valid use cases of NSNotification

* Standard frameworks (keyboard, device orientation)
* Custom modules. Create your own modules that interact with client by means of notifications. Must be well-documented and tested. Should be located in your code on correct abstraction level and not abused.

4. Alternatives

* Callbacks
* Delegation
* Implement own observer with explicit contract
* Command pattern

5. Wrapping up

Will end up with spaghetti code and break SOLID principles.