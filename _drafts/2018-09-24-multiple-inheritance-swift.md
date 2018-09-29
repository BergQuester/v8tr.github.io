---
layout: post
title: "Multiple Inheritance in Swift"
permalink: /multiple-inheritance-swift/
share-img: "/img/multiple-inheritance-swift-share.png"
---

Although Swift does not support multiple inheritance, it offers rich API that gives possibility to simulate it. Let's take an in-depth look at multiple inheritance and its implementation in Swift.

<!-- ### Programming Language is Just a Tool -->

<!-- Speaking of programming as a way of thinking, have you even thought what drives your software design decisions? The answer on this question reveals the two basic approaches that are naturally the starter points of all programming decisions.

**Thinking from programming language perspective** - each problem is assessed based on the toolkit the programming language offers. The example of this way of thinking: "I am good at Swift generics, I'll keep using them as a solution to all emerging tasks". 

It is thinking like a hammer: everything becomes a nail to be hammered in, irrespective of how inappropriate it is.

**Thinking from the problems and their solutions perspective** - following this way of thinking, you translate the solution into the program. All programming languages have their pros and cons, thus such solution might not be perfect. Following this way of thinking, programming language becomes just a tool.

For example, Swift does not support atomic properties by default, but still offers rich locking API which you can utilize to implement such. In [Atomic Properties in Swift](http://www.vadimbulavin.com/atomic-properties/) I discuss this particular case in more details.

When put this way, it becomes obvious that the second way of thinking is much more productive, while the first should be omitted.

**Thinking from the problems and their solutions perspective** requires knowledge of basic programming idioms. *Multiple inheritance*, which is the subject of present article, is among such idioms. -->

### What is Multiple Inheritance

*Multiple inheritance* is an object-oriented concept in which a class can inherit behavior and attributes from more than one parent class. 

Along with single inheritance and composition, *multiple inheritance* offers another way of sharing code between classes that can be very beneficial if used correctly. 

Through the rest of the article we'll elaborate on its proper usage as well as provide its Swift implementation.

### Multiple Inheritance in Swift

Although *multiple inheritance* is a standard feature of some programming languages, like C++, it is not the case for Swift. In Swift a class can conform to multiple protocols, but inherit from only one class. Value types, such as struct and enum, can conform to multiple protocols only.

{: .box-note}
*Swift supports only multiple inheritance of protocols.*

*Protocols with default implementations* give us just enough flexibility to approach multiple inheritance very closely. Here is how it looks:

{% highlight swift linenos %}

protocol HelloPrinter {
    func sayHello()
}

extension HelloPrinter {
    func sayHello() {
        print("Hello")
    }
}

{% endhighlight %}

Now when you create a new type conforming to that protocol, it gets the implementation of `sayHello` for free:

{% highlight swift linenos %}

struct MyStruct: HelloPrinter {}

let myStruct = MyStruct()
myStruct.print() // Prints "Hello"

{% endhighlight %}

However, conforming to a bunch of protocols with default implementations is not enough to call it multiple inheritance. More importantly, our protocols must satisfy the notion of *mixin*.

### What is a Mixin

A *mixin* is a class that contains methods for use by other classes without having to be the parent class of those other classes.

The idea behind *mixins* is simple: we would like to specify an extension without pre-determining what exactly it can extend. This is equivalent to specifying a subclass while leaving its superclass as a parameter to be determined later.

*Mixins* are generally not intended to be instantiated and used on their own. They provide standalone behavior that is supposed to be added to other types.

Here are the key points to understand about *mixins*. A *mixin*:
- Can contain both behavior and state.
- Is not supposed to be initialized.
- Is highly specialized and narrow in its functionality.
- Is not intended to be subclassed by other *mixins*.

With the help of *mixins* we can approach multiple inheritance implementation in Swift very closely.

### Implementing a Mixin in Swift

Animating and applying visual decorations to `UIView` are among the frequent tasks that iOS developers encounter. To demonstrate the practical use of multiple inheritance, we define several *mixins* and make `UIView` inherit from them, without introducing any subclasses or helpers.

{% highlight swift linenos %}

// MARK: - Blinkable

protocol Blinkable {
    func blink()
}

extension Blinkable where Self: UIView {
    func blink() {
        alpha = 1

        UIView.animate(
            withDuration: 0.5,
            delay: 0.25,
            options: [.repeat, .autoreverse],
            animations: {
                self.alpha = 0
        })
    }
}

// MARK: - Scalable

protocol Scalable {
    func scale()
}

extension Scalable where Self: UIView {
    func scale() {
        transform = .identity

        UIView.animate(
            withDuration: 0.5,
            delay: 0.25,
            options: [.repeat, .autoreverse],
            animations: {
                self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        })
    }
}

// MARK: - CornersRoundable

protocol CornersRoundable {
    func roundCorners()
}

extension CornersRoundable where Self: UIView {
    func roundCorners() {
        layer.cornerRadius = bounds.width * 0.1
        layer.masksToBounds = true
    }
}

{% endhighlight %}

Next we make `UIView` conform to all these protocols.

```swift
extension UIView: Scalable, Blinkable, CornersRoundable {}
```

Each view and it's subclass are getting methods from mixins for free.

{% highlight swift linenos %}

aView.blink()
aView.scale()
aView.roundCorners()

{% endhighlight %}

And the visuals look like this:

<p align="center">
    <a href="{{ "/img/multiple-inheritance-mixin-demo.gif" | absolute_url }}">
        <img src="/img/multiple-inheritance-mixin-demo.gif" alt="Multiple Inheritance and Mixins in Swift - Mixin Demo"/>
    </a>
</p>

### The Diamond Problem

The Diamond Problem is best described with next diagram.

<p align="center">
    <a href="{{ "/img/diamond-problem.svg" | absolute_url }}">
        <img src="/img/diamond-problem.svg" alt="Multiple Inheritance and Mixins in Swift - The Diamond Problem"/>
    </a>
</p>

### Advanced Mixins - Stateful

### Wrapping Up

Here is where the boundary between the inheritance and compositions begins to eradicate. Mixins are the basis for a compositional inheritance.


---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---

[starter-repo]: https://github.com/V8tr/UITableViewCellAnimation-Article-Starter