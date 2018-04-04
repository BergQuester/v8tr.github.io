---
layout: post
title: Core Data Stack in Swift 4
permalink: /core-data-stack-swift-4/
---

Content

- Introduction
- What is Core data - see https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/index.html#//apple_ref/doc/uid/TP40001075-CH2-SW1
- Core Data Architecture
- Setting up the stack
- What is persistent container
- Fetching Data
- Saving Data
- Wrapper around Core Data
- Conclusion

Let's briefly go through the Core Data Architectural Components.

### Core Data Architecture

<p align="center">
    <img src="{{ "/img/core_data_stack_1.svg" | absolute_url }}" alt="Core Data stack Architecture"/>
</p>

Despite the fact `NSPersistentContainer` takes off a decent part of responsibility for Core Data stack management from developers, it is still extremely important to understand how do the individual components work.

`NSManagedObject`'s are the model objects exposed by Core Data. 

`NSManagedObjectModel` is a database schema that describes our application's entities. You can think of it as a description of the data that is going to be accessed by the Core Data stack.

`NSPersistentStoreCoordinator` associates persistent storage and Managed Object Model. Mapping of the relational database rows into your application's objects is a nontrivial task and it is often taken for granted when working with Core Data. What is more, `NSPersistentStoreCoordinator` is used by `NSManagedObjectContext` when it comes to saving or fetching objects.

`NSManagedObjectContext` used to save, fetch and create managed objects and thus will be the most used Core Data stack component.

### NSPersistentContainer

<p align="center">
    <img src="{{ "/img/core_data_stack_2.svg" | absolute_url }}" alt="Core Data stack Architecture"/>
</p>

Beginning from iOS 10 the whole stack has been encapsulated into the `NSPersistentContainer` class which drastically simplifies the creation process of the Core Data stack. 

`NSPersistentContainer` exposes managed object model, the managed object context and the persistent store coordinator as well as provides many convenience methods when working them, especially when it comes to multithreaded applications.

### Initialize Core Data Stack

