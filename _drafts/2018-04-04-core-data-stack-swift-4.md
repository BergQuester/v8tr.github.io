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
- Save
- Fetch
- Delete
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
runs passed block on a newly created background context. Each time this method is called, a new background `NSManagedObjectContext` will be created.

### Initialize Core Data Stack

Let's begin with creating a Data Model schema in Xcode and add an entity `Item` with a single `name` attribute that will be used throughout this article.

<p align="center">
    <img src="{{ "/img/core_data_stack_3.png" | absolute_url }}" alt="Core Data stack Architecture - Model Schema"/>
</p>

With Data Model created we can initialize the Core Data stack and see how the components play together.

{% highlight swift linenos %}

let persistentContainer = NSPersistentContainer(name: "Model")

persistentContainer.loadPersistentStores { storeDescription, error in
    if let error = error {
        assertionFailure(error.localizedDescription)
    }
    print("Core Data stack has been initialized with description: \(storeDescription)")
}

{% endhighlight %}

Which prints to console: `Core Data stack has been initialized with description: <NSPersistentStoreDescription: 0x102a69b70> (type: SQLite, url: <...>/CoreData_Article/Model.sqlite)`. This means the Core Data stack has been fully initialized and can be used in our app. By default the stack uses SQLite persistent store, however it can be instructed to use other types of storage.

{: .box-note}
*Consider using `InMemory` persistent store for unit tests to ensure that the test data is properly cleaned up.*

### Access the Context

An instantiated container already has a view context ready for use:

```swift
let context = persistentContainer.viewContext
```

{: .box-note}
*Here and later we are using `persistentContainer.viewContext` that works on the main queue. Usage of view context for CPU-heavy computations will lead to freezes in your app. Consider using `newBackgroundContext` or `performBackgroundTask(_:)` to perform such tasks in a background.*

### Create Entity

Every `ManagedObject` must be associated with a context. Even though there is a way to instantiate a managed object without a context, it is not the intended pattern in the Core Data and I would not recommend to follow it.

A new `Item` instance can be created as follows:

```swift
let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context) as! Item
```

### Save

Newly created managed objects have all their properties set to `nil`. Before saving the item to the data base, we will set a name for it:

{% highlight swift linenos %}

item.name = "Some item"

do {
    try context.save()
    print("Item named '\(item.name!)' has been successfully saved.")
} catch {
    assertionFailure("Failed to save item: \(error)")
}

{% endhighlight %}

### Fetch

Core Data provides a way to construct complex search requests by means of `NSFetchRequest`. Let's define a fetch request that returns all saved items:

```swift
let itemsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
```

To execute the request it must be passed to a managed context.

{% highlight swift linenos %}

do {
    let fetchedItems = try context.fetch(itemsFetch) as! [Item]
    print("Fetched items: \(fetchedItems)")
} catch {
    assertionFailure("Failed to fetch items: \(error)")
}

{% endhighlight %}

This snippet prints:

```
Fetched items: [<Item: 0x101a59f40> (entity: Item; id: 0x40000b <x-coredata://C13322AF-CF64-4AC4-8DEB-24B3E250A0B3/Item/p1> ; data: {
    name = "Some item";
})]
```

Core Data does not guarantee any specific order for the fetch results. It is possible to define complex sorting and filtering criterias which is essential when working with Core Data. A more detailed look at this topic is outside of the current article's scope, so I recommend checking [`NSFetchRequest` docs][fetch-request-docs] as well as [Fetching Managed Objects by Apple][fetching-managed-objects-article].

### Delete

By now we have saved and fetched an `Item` instance. Deletion can be done as simple as follows:

```swift
context.delete(item)
```

### Rollback

You can also reset all changes up to the most recent save using the *rollback* method of the managed object context:

```swift
context.rollback()
```

Now the deleted item is back into the context.

### Undo

The undo operation comes in hand when you need to cancel edition of managed object field. Let's change the item's name and then undo that change:

{% highlight swift linenos %}

item.name = "Another name"

print(item.name!)

context.undoManager = UndoManager()
context.undo()

print(item.name!)

{% endhighlight %}

Which prints:

```
Another name
Some item
```

### Source Code

The code snippets from the article can be found in this [sample project][sample-project]. You might want to clone it and make some tweaks to get a better understanding of the discussed topics.

### Conclusion

When using the Core Data framework in your app, it is important to understand its architecture and how do the components interact with each other, despite the fact that `NSPersistentContainer` takes a considerable part of responsibility for Core Data stack management off the developers' shoulders.

Beginning from iOS 10 there is no need to write custom Core Data stack and it is highly recommended to use `NSPersistentContainer`. We have seen how it can be initialized and used in your app together with the key operations with managed objects, namely: *save, fetch, delete, rollback* and *undo*.

Even though there are plenty of other complex things Core Data has up on its sleeve, this article can make a nice foundation, so that you can use Core Data in your app right away and gradually move to the more complex stuff.

---

*I'd love to meet you in Twitter: [here](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you found it useful.*

---

[private-concurrency-type]: https://developer.apple.com/documentation/coredata/nsmanagedobjectcontextconcurrencytype/1506495-privatequeueconcurrencytype
[fetch-request-docs]: https://developer.apple.com/documentation/coredata/nsfetchrequest
[fetching-managed-objects-article]: https://developer.apple.com/library/content/documentation/DataManagement/Conceptual/CoreDataSnippets/Articles/fetching.html
[sample-project]: https://github.com/V8tr/CoreData_in_Swift4_Article
