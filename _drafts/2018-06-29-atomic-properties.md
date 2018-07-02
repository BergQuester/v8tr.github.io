---
layout: post
title: Design and Benchmark Atomic Properties in Swift
permalink: /initialization-with-literals/
share-img: "/img/initialization-with-literals-share.png"
---

Swift has no language features for defining atomic properties. However, the lack of @synchronized or atomic modifier that we used to in Objective-C is compensated with the diversity of locking APIs available in Apple's frameworks. In this article let's take a look at different ways of designing an atomic property and benchmark their performance.

- Definition of Lock
- Apple APIs
- Atomic properties

a. Before going straight to the code, lets look through the core concepts that will be used in the article.

b. When working with concurrent code, there are several concepts you must be aware of.

### Concurrency and Multitasking

**Concurrency** refers to the ability of different parts of a program to be executed out-of-order or in partial order, without affecting the final outcome. 

This allows for **multitasking** which is a parallel execution of the concurrent units that significantly boosts performance of a program in multi-processor systems.

### Synchronization

In common sense, **synchronization** means making two things happen at the same time. 

In programming, **synchronization** has broader definition: it refers to relationships among events — any number of events, and any kind of relationship (before, during, after).

As programmers, we are often concerned with *synchronization constraints*, which are requirements pertaining to the order of events. Constraint example: *Events A and B must not happen at the same time*.

### Locks

When dealing with iOS apps, we are always sandboxed to their *processes*. A process creates and manages *threads*, which are the main building blocks in multitasking applications.

**A lock** is an abstract concept for threads synchronization. The main idea is to protect access to a given region of code at a time. There are multiple types of locks:
1. **Semaphore** - allows up to *N* threads to access a given region of code at a time.
2. **Mutex** - ensures that only one thread is active in a given region of code at a time. You can think of it as a *semaphore* with a *maximum count of 1*.
3. **Spinlock** - causes a thread trying to acquire a lock to wait in a loop while checking if the lock is available. It is efficient if waiting is rare, but wasteful if waiting is common.
4. **Reader/writer lock** - provides concurrent access for *read-only* operations, but exclusive access for *write* operations.
5. **Recursive lock** - a *mutex* that can be acquired by the same thread many times.

Now we can design atomic property using the above synchronization objects.

### NSLock

`NSLock` and its companion `NSRecursiveLock` are Objective-C lock classes. 