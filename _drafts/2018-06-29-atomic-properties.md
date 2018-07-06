---
layout: post
title: Atomic Properties in Swift
permalink: /atomic-properties/
share-img: "/img/initialization-with-literals-share.png"
---

Swift has no language features for defining atomic properties. However, the lack of @synchronized or atomic modifier that we used to in Objective-C is compensated with the diversity of locking APIs available in Apple's frameworks. In this article let's take a look at different ways of designing atomic properties in Swift.

Before going straight to the code, make sure we understand the core concepts related to *concurrent programming* and *atomicity*.

### Concurrency and Multitasking

**Concurrency** refers to the ability of different parts of a program to be executed out-of-order or in partial order, without affecting the final outcome. 

This allows for **multitasking** which is a parallel execution of the concurrent units that significantly boosts performance of a program in multi-processor systems.

### Synchronization

In common sense, **synchronization** means making two things happen at the same time. 

In programming, **synchronization** has broader definition: it refers to relationships among events — any number of events, and any kind of relationship (before, during, after).

As programmers, we are often concerned with *synchronization constraints*, which are requirements pertaining to the order of events. Constraint example: *Events A and B must not happen at the same time*.

### What is Atomicity

An operation is **atomic** if it appears to the rest of the system to occur at a single instant without being interrupted. In other words, it will either complete or return to its original state.

*Atomicity* is a safety measure which enforces that operations do not complete in an unpredictable way when accessed by multiple threads or processes simultaneously.

On a software level, a common tool to enforce *atomicity* is *lock*.

### Locks

When dealing with iOS apps, we are always sandboxed to their *processes*. A process creates and manages *threads*, which are the main building blocks in multitasking iOS applications.

**Lock** is an abstract concept for threads synchronization. The main idea is to protect access to a given region of code at a time. There are multiple types of locks:
1. **Semaphore** - allows up to *N* threads to access a given region of code at a time.
2. **Mutex** - ensures that only one thread is active in a given region of code at a time. You can think of it as a *semaphore* with a *maximum count of 1*.
3. **Spinlock** - causes a thread trying to acquire a lock to wait in a loop while checking if the lock is available. It is efficient if waiting is rare, but wasteful if waiting is common.
4. **Read-write lock** - provides concurrent access for *read-only* operations, but exclusive access for *write* operations. Efficient when reading is common, but writing is rare.
5. **Recursive lock** - a *mutex* that can be acquired by the same thread many times.

### Overview of Apple Locking APIs

#### Lock

`NSLock` and its companion `NSRecursiveLock` are Objective-C lock classes. They correspond to *Mutex* and *Recursive Lock* and don't have their Swift counterparts. 

A lower-level C `pthread_mutex_t` is also available in Swift. It can be configures both as a mutex and a recursive lock.

#### Spin Lock

Since iOS 10 `OSSpinLock` has been deprecated and now there is no exact match to spin lock concept in Apple's frameworks. The recommendation is to use `os_unfair_lock` for this purpose. This function doesn't spin on contention, but instead waits in the kernel to be awoken by an unlock. Thus, it has lower CPU impact than the spin lock does, but makes starvation of waiters a possibility.

#### Read-write lock

`pthread_rwlock_t` is a low-level C read-write lock.

### Semaphore

`DispatchSemaphore` provides an implementation of a semaphore. It makes little sense to use semaphore for designing atomic properties in Swift, so it is listed here for completeness reasons.

### Implementing Atomic Property using Locks

After we have learned about concurrent programming and locks, we can implement our own atomic operation by means of Apple's locking APIs.

<script src="https://gist.github.com/V8tr/57c7c6a79b51185005862a40d246117d.js"></script>

### Implementing Atomic Property using queues

Besides locks, Swift has `DispatchQueue` and `OperationQueue` that also can be used to design an atomic property.

Both queues are used to manage the execution of work items and they can configured to achieve lock behavior. The examples are below.

<script src="https://gist.github.com/V8tr/3db48858a62ebc15796c032c8ff68b6f.js"></script>

### Wrapping Up


