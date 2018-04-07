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
runs passed block on a newly created background context. Yes, you got it right: each time this method is called, a new background `NSManagedObjectContext` will be created.

### Initialize Core Data Stack

At this point we do not have a managed object model, i.e. the data base schema, defined. Let's create a Data Model in Xcode called *"Model"* and add an entity `Item` that has a single attribute `name`.

<p align="center">
    <img src="{{ "/img/core_data_stack_3.png" | absolute_url }}" alt="Core Data stack Architecture - Model Schema"/>
</p>

Now we will initialize the Core Data stack and see how the components play together.

{% highlight swift linenos %}

let persistentContainer = NSPersistentContainer(name: "Model")

persistentContainer.loadPersistentStores { storeDescription, error in
    if let error = error {
        assertionFailure(error.localizedDescription)
    }
    print("Core Data stack has been initialized with description: \(storeDescription)")
}

{% endhighlight %}

Which prints to console: `Core Data stack has been initialized with description: <NSPersistentStoreDescription: 0x102a69b70> (type: SQLite, url: <...>/CoreData_Article/Model.sqlite)`. At this point Core Data stack is fully initialized and can be used in our app.

### Manipulate Entities

#### Create

A new `Item` instance can be created and inserted into the view context with a single line as follows:

{% highlight swift linenos %}

let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: persistentContainer.viewContext) as! Item

{% endhighlight %}

{: .box-note}
*Here and later we are using `persistentContainer.viewContext` that works on the main queue. Usage of view context for CPU-heavy computations will lead to freezes in your app. Consider using `newBackgroundContext` or `performBackgroundTask(_:)` to perform such tasks in a background.*

### Save

Let's set a name for the newly created item and then save it to the data base:

{% highlight swift linenos %}

item.name = "Some item"

do {
    try persistentContainer.viewContext.save()
    print("Item named '\(item.name!)' has been successfully saved.")
} catch {
    assertionFailure("Failed to save item: \(error)")
}

{% endhighlight %}

### Fetch

When it comes to fetching Core Data entities, the first thing you must do is define search criteria by means of `NSFetchRequest`s.

<!-- Every fetch operation is started with a creat -->

{% highlight swift linenos %}
let itemsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
{% endhighlight %}

When executed, the above fetch request will return all managed objects of `Item` type. Core Data does not guarantee any specific order for the fetch results, so you have to do this explicitly. 

Execute fetch request to query recently saved `Item` instance.

{% highlight swift linenos %}

do {
    let fetchedItems = try persistentContainer.viewContext.fetch(itemsFetch) as! [Item]
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

It is possible to define complex search criteria in fetch requests. 

Construction of complex fetch requests is outside of the current article's scope. For more complex fetch requests I recommend checking [`NSFetchRequest` docs][fetch-request-docs] as well as [Fetching Managed Objects][fetching-managed-objects-article] article by Apple.

#### Delete

By now we have saved and fetched an `Item` instance. Deletion can be done as simple as follows:

{% highlight swift linenos %}
persistentContainer.viewContext.delete(item)
{% endhighlight %}

### Conclusion 

Despite the fact `NSPersistentContainer` takes off a decent part of responsibility for Core Data stack management from developers, it is still extremely important to understand how do the individual components work.

The code snippets from the article can be found is a [sample project][sample-project].

[private-concurrency-type]: https://developer.apple.com/documentation/coredata/nsmanagedobjectcontextconcurrencytype/1506495-privatequeueconcurrencytype
[fetch-request-docs]: https://developer.apple.com/documentation/coredata/nsfetchrequest
[fetching-managed-objects-article]: https://developer.apple.com/library/content/documentation/DataManagement/Conceptual/CoreDataSnippets/Articles/fetching.html
[sample-project]: https://github.com/V8tr/CoreData_in_Swift4_Article