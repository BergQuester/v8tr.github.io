---
layout: post
title: "Multiple Inheritance in Swift"
permalink: /multiple-inheritance-swift/
share-img: "/img/multiple-inheritance-swift-share.png"
---

Although Swift language does not completely support multiple inheritance, it offers rich API that allows to come up with a very close design. Let's take a look at what multiple inheritance exactly is and how it can be implemented by means of Swift language features.

### Programming language is only a tool

As a software engineer, you solve new and new tasks each day. When you encounter a task, do you first think of concrete language APIs or rather an overall design and then .

---

As a software engineer, when you encounter certain programming problems, your design 

As a software engineer, you must approach any problem not from the level of particular programming language syntax, but from the solution that certain problem best fits best.

Any programming language must be only a tool 

---

There is a number of programming languages out there. Programming languages come and go. The foundational principles that form the basis of software engineering don't.

As a software engineer, when encounter new task, you should not think from the perspective of current programming language. You use the abstractions 

When designing software 

When designing software, you should not approach the solution from the programming language level. You should come up with most suitable solution and 

When working on software engineering problems, the solution you come up with must be

---

### Programming Language is Just a Tool

Have you ever thought what is the starter point of your software design decisions? The answer on this question reveals the two basic ways of thinking that usually drive software design.

Thinking from programming language perspective: you assess each software task based on the toolset the programming language offers you. For example, one might think: "I know that Swift has generics language feature, then I'll keep using them as much as I could as a solution to all emerging tasks".

Thinking from the solution perspective: based on the knowledge of object-oriented programming concepts and good practices you come up with a software design that is not necessary supported by your current programming language out of the box. If needed you come up with a workaround or simulate the required features. For example, Swift does not support atomic properties by default, but still offers rich locking API which you can utilize to implement such. In [Atomic Properties in Swift](http://www.vadimbulavin.com/atomic-properties/) I discuss this particular case in more details.

As a professional software developer you must stick to the second way of thinking. The programming language must be just a tool.

*Multiple inheritance* lends itself to the second way of thinking. So what is it exactly?

### Multiple Inheritance in Swift

*Multiple inheritance* is an object-oriented concept in which a class can inherit behavior and attributes from more than one parent class. It is a way of sharing code between multiple classes.

*Multiple inheritance* is a standard feature of some programming languages, like C++. Swift supports multiple inheritance of interfaces and single inheritance of implementations.

In Swift a class can inherit from multiple protocols but just one class. Value types, such as struct and enum, can inherit only from multiple protocols.

<p align="center">
<i>Swift support multiple inheritance of interfaces but single inheritance of implementations.</i>
</p>

### What is Mixin

### Multiple Inheritance as Composition of Mixins

### Implementing Multiple Inheritance in Swift

Here is where the boundary between the inheritance and compositions begins to eradicate. Mixins are the basis for a compositional inheritance
mechanism.

The core language mechanism to allow us implement multiple inheritance is protocol extensions. By using such 

### Mixin

A *mixin* is a class that contains methods for use by other classes without having to be the parent class of other classes.



The idea is simple: we would like to specify an extension without pre-determining what exactly it can extend.

A mixin is an abstract subclass that may be used to specialize the behavior of a variety of parent classes. It often does this by defining new methods that perform some actions and
then call the corresponding parent methods.

In other words, a *mixin* provides methods with a certain behavior that is *not intended* to be used on its own, but rather to be added to other classes.

Thus, the main purpose of *mixin* is to dynamically add a set of methods into an object. 

The definition of *mixin* can be reduced to next key points that:
- contains methods
- contains state
- not supposed to be initialized
- narrow in functionality
- not intended to be extended

Sounds like we can simulate multiple inheritance pretty close by means of *mixins*.

### Implementing Stateless Mixin

#### Flasher

#### LoadingAnimatable

### Implementing Statefull Mixin

### Diamond Problem

### Wrapping Up

### Implementing a Mixin

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---

[starter-repo]: https://github.com/V8tr/UITableViewCellAnimation-Article-Starter