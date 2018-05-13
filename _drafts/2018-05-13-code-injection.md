---
layout: post
title: Code Injection as Alternative to Method Swizzling
permalink: /code-injection/
share-img: "/img/core_data_in_swift_4_share_img.png"
---

### Problem Statement

Analytics and logging are integral part of the vast majority of iOS apps. The common solution to these tasks is to write singletones and call them from the view controller life cycle method. Like so:

{% highlight swift linenos %}

override func viewDidLoad() {
    super.viewDidLoad()

    Tracking.pageViewed(self)
    Logger.log("User profile screen opened")
}

{% endhighlight %}

This code repeats dozens of times in different view controllers, increasing overall complexity of your code, making it less reusable, rigid and fragile. Each time you make a change in your view controller code, you have a chance of breaking analytics and logging features in your app.

Here is when code injection comes to the rescue.

### Theoretical Background

Before heading straight to the code, let's make sure we understand the theoretical background behind it.

**Code Injection** is a variation of the **method swizzling** technique. It is based on Objective-C runtime which a library that provides support for the dynamic properties of the Objective-C language. Even pure Swift app is executed inside the Objective-C runtime, providing not only Swift & Objective-C interoperatiblity, but a number of runtime features that allow us write dynamic code even in such statically typed language as Swift.

In Objective-C one does not call a method on object instances, instead one sends a message. In Objective-C each instance has a single type whose definition contains the methods. Upon message being received, the dispatcher looks up the corresponding method in the message-to-method map for the type and then invokes the method. This variation of dynamic dispatch is called **message dispatch**.



### Code Injection

