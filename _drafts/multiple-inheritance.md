### Programming Language is Just a Tool

Have you ever thought what is the starter point of your software design decisions? The answer on this question reveals the two basic ways of thinking that usually drive software design.

Thinking from programming language perspective: you assess each software task based on the toolset the programming language offers you. For example, one might think: "I know that Swift has generics language feature, then I'll keep using them as much as I could as a solution to all emerging tasks".

Thinking from the solution perspective: based on the knowledge of object-oriented programming concepts and good practices you come up with a software design that is not necessary supported by your current programming language out of the box. If needed you come up with a workaround or simulate the required features. For example, Swift does not support atomic properties by default, but still offers rich locking API which you can utilize to implement such. In [Atomic Properties in Swift](http://www.vadimbulavin.com/atomic-properties/) I discuss this particular case in more details.

As a professional software developer you must stick to the second way of thinking. The programming language must be just a tool.

<p align="center">
*The programming language must be just a tool.*
</p>

*Multiple inheritance* lends itself to the second way of thinking. So what is it exactly?

### Multiple Inheritance in Swift

*Multiple inheritance* is an object-oriented concept in which a class can inherit behavior and attributes from more than one parent class. It is a way of sharing code between multiple classes.

*Multiple inheritance* is a standard feature of some programming languages, like C++. Swift supports multiple inheritance of interfaces and single inheritance of implementations.

This means, that in Swift a class might inherit from multiple protocols and only one other class. Value types, such as struct and enum, can inherit only from multiple protocols.

<p align="center">
*Swift support multiple inheritance of interfaces and single inheritance of implementations.*
</p>

### Implementing Multiple Inheritance in Swift

Swift offers two ways of implementing multiple inheritance: default protocols implementations and mixins. Here is where the boundary between the inheritance and compositions begins to eradicate.

### Mixin

### Implementing Stateless Mixin

#### Flasher

#### LoadingAnimatable

### Implementing Statefull Mixin

### Diamond Problem

### Wrapping Up

