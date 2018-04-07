---
layout: post
title: Core Data Stack in Swift 4
permalink: /core-data-stack-swift-4/
---

Content

- Introduction
- What is Core data - see https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/index.html#//apple_ref/doc/uid/TP40001075-CH2-SW1
- Core Data Architecture
- What is persistent container
- Setting up the stack
- Fetching Data
- Saving Data
- Wrapper around Core Data
- Conclusion

### Core Data Architecture

Before diving into the examples, we will first take a look at Core Data components to get a better understanding of its architecture. The parts of the Core Data stack are: `NSManagedObject`, `NSManagedObjectModel`, `NSPersistentStoreCoordinator` and `NSManagedObjectContext`.

These pieces attached together are often referred to as a Core Data stack.

<p align="center">
    <img src="{{ "/img/core_data_stack_1.svg" | absolute_url }}" alt="Core Data stack Architecture without NSPersistentContainer"/>
</p>

`NSManagedObject`'s are the model objects exposed by Core Data. 

`NSManagedObjectModel` is a database schema that describes our application's entities. You can think of it as a description of the data that is going to be accessed by the Core Data stack.

`NSPersistentStoreCoordinator` associates persistent storage and Managed Object Model. Mapping of the relational database rows into your application's objects is a nontrivial task and it is often taken for granted when working with Core Data. What is more, `NSPersistentStoreCoordinator` is used by `NSManagedObjectContext` when it comes to saving or fetching objects.

`NSManagedObjectContext` used to save, fetch and create managed objects and thus will be the most used Core Data stack component.

### Persistent Container

Beginning from iOS 10, the whole stack has been encapsulated into the `NSPersistentContainer` class which drastically simplifies the creation process of the Core Data stack as well as provides many convenience methods when working with its componenets.

<p align="center">
    <img src="{{ "/img/core_data_stack_2.svg" | absolute_url }}" alt="Core Data stack Architecture with NSPersistentContainer"/>
</p>

`NSPersistentContainer` exposes managed object model, the managed object context and the persistent store coordinator as well as provides many convenience methods when working them, especially when it comes to multithreaded applications.

Let's briefly go through the `NSPersistentContainer`'s interface:

#### Initialization

`init(name:)`  
initialize `NSPersistentContainer` with a given name. Make sure it matches with the name of your data model file.

---

`loadPersistentStores(completionHandler:)`   
asynchronously loads persistent stores and fires the completion handler once the stack is ready for use. Must be called after the persistent container has been initialized.

#### Working with Contexts

`newBackgroundContext()`  
creates a [private][private-concurrency-type] managed object context associated with `NSPersistentStoreCoordinator` directly.

---

`viewContext`  
a reference to the managed object context associated with the main queue. It is created automatically during the initialization process. This context is directly connected to `NSPersistentStoreCoordinator`, thus it might freeze your application when performing heavy operations.

---

`performBackgroundTask(_:)`  
runs passed block on a newly created background context. Yes, you got it right: each time this method is called, a new background `NSManagedObjectContext` will be created.

### Initialize Core Data Stack

Now we will create the Core Data stack and see the components play together.



### Conclusion 

Despite the fact `NSPersistentContainer` takes off a decent part of responsibility for Core Data stack management from developers, it is still extremely important to understand how do the individual components work.

[private-concurrency-type]: https://developer.apple.com/documentation/coredata/nsmanagedobjectcontextconcurrencytype/1506495-privatequeueconcurrencytype