---
layout: post
title: Code Injection in Swift
permalink: /code-injection-swift/
share-img: "/img/code_injection_share.png"
---

Code Injection in Swift is a technique of adding custom pieces of code to methods without modifying a line of code of their enclosing types. It is an alternative to inheritance, where a common behavior is extracted to a superclass, but reusable and nonintrusive.

### Problem Statement

First, lets define a problem area that can be addressed by code injection. 

I bet the code snippet below seem familiar to you.

{% highlight swift linenos %}

override func viewDidLoad() {
    super.viewDidLoad()

    Tracking.pageViewed(self)
    Logger.log("User profile screen opened")
}

{% endhighlight %}

Analytics and logging are integral part of the vast majority of iOS apps. The common solution to these tasks is to write singletones and call them from the view controller life cycle methods. But the article is not about singletones 😉.

This biggest problem here is that this code repeats dozens of times in your app, crawling in different view controllers, increasing overall complexity of your code, making it less reusable, more rigid and fragile. Each time you make a change in your view controller code, you have a chance of breaking analytics and logging features in your app.

By means of *code injection*, the above snippet can be extracted from all view controllers, generalized and added in a single place, without introducing any breaking changes to your existing app. Sounds exciting, doesn't it? 😉

### Theoretical Background

The theoretical background behind *code injection* in Swift is not trivial, so let's make sure we understand it before heading straight to the code.

**Code Injection** is a variation of the **method swizzling** technique. It is based on **Objective-C runtime** which a library that provides support for the dynamic properties of the Objective-C language. Even pure Swift app is executed inside the Objective-C runtime, providing not only Swift & Objective-C interoperatiblity, but a number of runtime features that allow us write dynamic code even in such statically typed language as Swift.

### Message Dispatch

In Objective-C instead of calling a method on object instances, one sends a message to an object. Each class and object in Objective-C includes these two essential elements:
* A pointer to the superclass.
* A class dispatch table. This table is a message-to-method map for the type.

Upon message being received, the compiler looks up the corresponding method in the dispatch table and then invokes the method. This variation of dynamic dispatch is called **message dispatch**.

**Code injection** as well as **method swizzling** is based on the *message dispatch* explained above. This opens the door to make changes to a dispatch table at app execution time and inject custom code to the methods associated with it by means of the *runtime library*.

### Code Injection

After learning about message dispatch and Objective-C runtime, lets finally write some code.

The below snippet defines a `ViewDidLoadInjector` that inserts a custom closure to all `viewDidLoad` methods for a given view controller types.

{% highlight swift linenos %}

import ObjectiveC.runtime
import UIKit

class ViewDidLoadInjector {

    typealias ViewDidLoadRef = @convention(c)(UIViewController, Selector) -> Void

    private static let viewDidLoadSelector = #selector(UIViewController.viewDidLoad)

    static func inject(into supportedClasses: [UIViewController.Type], injection: @escaping (UIViewController) -> Void) {
        guard let originalMethod = class_getInstanceMethod(UIViewController.self, viewDidLoadSelector) else {
            fatalError("\(viewDidLoadSelector) must be implemented")
        }

        var originalIMP: IMP? = nil

        let swizzledViewDidLoadBlock: @convention(block) (UIViewController) -> Void = { receiver in
            if let originalIMP = originalIMP {
                let castedIMP = unsafeBitCast(originalIMP, to: ViewDidLoadRef.self)
                castedIMP(receiver, viewDidLoadSelector)
            }

            if ViewDidLoadInjector.canInject(to: receiver, supportedClasses: supportedClasses) {
                injection(receiver)
            }
        }

        let swizzledIMP = imp_implementationWithBlock(unsafeBitCast(swizzledViewDidLoadBlock, to: AnyObject.self))
        originalIMP = method_setImplementation(originalMethod, swizzledIMP)
    }

    private static func canInject(to receiver: Any, supportedClasses: [UIViewController.Type]) -> Bool {
        let supportedClassesIDs = supportedClasses.map { ObjectIdentifier($0) }
        let receiverType = type(of: receiver)
        return supportedClassesIDs.contains(ObjectIdentifier(receiverType))
    }
}

{% endhighlight %}

Now lets do the actual injection. Note that we are passing `InjectedViewController` type, so it will work only for its instances:

{% highlight swift linenos %}

class InjectedViewController: UIViewController {}

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        ViewDidLoadInjector.inject(into: [InjectedViewController.self]) { print("Injected to \($0)") }
        return true
    }
}

{% endhighlight %}

Each time `viewDidLoad` method is called on any `InjectedViewController` instance, a message will be printed:

```
Injected to <__lldb_expr_13.InjectedViewController: 0x7fc25d400020>
```

Any other view controller types can be passed to the injector. And, of course, instead of printing to console, we might have added analytics, logging or any other features.

### Limitations

The biggest limitation is that this code cannot be closed against changes of the method it is being injected to. In other words, if you need to do the similar for the `viewWillAppear` method, you will have to duplicate the most of the code from `ViewDidLoadInjector`.

### Source Code

Full source code can be found [here](https://github.com/V8tr/Code-Injection-Swift). Download it to make some tweaks and see how it plays in action.

### Wrapping Up

The key concepts lying in the basis of *Code injection in Swift* are *message dispatch* and *Objective-C runtime*.

*Code injection* is an alternative to inheritance, when a common behavior instead of being extracted to a base class, is injected to all methods of the hierarchy. As is often the case, it comes with its own limitations, which you have to evaluate against your project goals. 

*Code injection* opens the door to nonintrusive refactoring and can be easily reused across your Swift projects, allowing you to plug in common behavior to hierarchies of classes without changing a line of their code.

---

*I'd love to meet you in Twitter: [here](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---