---
layout: post
title: "Structure of Swift Language Processing System"
permalink: /swift-language-processing-system/
share-img: "/img/swift-language-processing-system/share.png"
---

Before a Swift program can be executed, it first must be translated into a form that can be understood by a target device. In this article we will learn which transformations a Swift program undergoes before it can be run on your machine.

### Introduction

Any computer system is double-sided: it has *software* and *hardware* part.

*Hardware* is physical part of a computer, such as the monitor or keyboard. *Hardware* is usually controlled by *software* which is collection of instructions that tells hardware how to work. Since software orchestrates the process, while hardware actually does the work, neither can be used on its own.

As iOS engineers, our primary focus is software part. However, hardware understands instructions in the form of electronic charge that contains two levels, named *'Logic 0'* and *'Logic 1'*. This is also known as *bytecode*.

Here comes the question: how is the Swift code transformed into bytecode that hardware understands?

### Language Processing System

The answer is *language processing system*. *Language processing system* is a collection of programs that lend themselves to producing an executable program out of a set of instructions written in arbitrary source language.

*Language processing systems* allow programmers to use higher-level languages instead of writing bytecode which greatly reduces programming complexity.

### Structure of Language Processing Systems

In Swift as well as the majority of other programming languages, the processing system consists out of 5 parts:

- Preprocessor
- Compiler
- Assembler
- Linker
- Loader
 
These pieces play together in way depicted on a diagram below:

<p align="center">
    <a href="{{ "/img/swift-language-processing-system/language-processing-system.svg" | absolute_url }}">
        <img src="/img/swift-language-processing-system/language-processing-system.svg" width="350" alt="Understanding Swift Compilation Process - Language processing system"/>
    </a>
</p>

The order of execution is orchestrated by Xcode - the primary IDE being used by iOS and macOS developers. Throughout the article we will have a look at each of these steps the way Xcode executes them.

### Preprocessor

In terms of Xcode this step is called **Build**. Whatever the name is, the main goal of preprocessor or build step is to transform your program in a way that it can be fed to a compiler. It replaces macros with their definitions, discovers dependencies and resolves preprocessor directives.

#### Preprocessor directives 

The sad truth is that Swift compiler does not have a preprocessor. However this phase is partially compensated by Xcode build system by use of *Active Compilation Conditions*. In Xcode build settings custom preprocessor commands can be defined by means of `SWIFT_ACTIVE_COMPILATION_CONDITIONS`. Xcode will then pass them passed to `swiftc` as a conditional compilation directives.

The preprocessor directives can be used in Swift project as follows:

{% highlight swift linenos %}

#if MY_CONDITION
  let apiKey = "SOME_API_KEY"
#else
  let apiKey = "ANOTHER_API_KEY"
#endif

print("apiKey equals to \(apiKey)")

{% endhighlight %}

Here is what happens when we run `swiftc` with `MY_CONDITION` as input:

```
xcrun swiftc -D MY_CONDITION main.swift

// Prints "apiKey equals to SOME_API_KEY"
```

#### Macros

The lack of preprocessor means that in Swift we are unable to use C-style macro, like we did in Objective-C:

```C
#define ANIMATION_DURATION 0.5 // Does not compile in Swift
```

#### Dependencies Graph

Under the hood Xcode extensively uses [llbuild](https://github.com/apple/swift-llbuild) which is an open-source low-level build system. Xcode feeds Swift, Objective-C, C and C++ to llbuild and the latter resolves inclusion for them and creates dependencies graph. Along with the graph, it generates metadata in llbuild-native format that is used on further stages of language processing system.

<!-- Under the hood Xcode extensively uses [llbuild](https://github.com/apple/swift-llbuild) that accepts Swift, Objective-C, C and C++ files and resolves dependencies inclusion for them by creating a directed graph.

*llbuild* is a low-level build system, used by Xcode. Along with dependencies graph, it creates metadata in llbuild-native format that is used on further stages of language processing system. -->

### Compiler

**Compiler** is a program that maps a source program in one language - in our case Swift - into a semantically equivalent target program in another language, in our case the machine code.

In its turn, compiler is a part of a bigger scheme named *language processing system*, main goal of which is to produce an executable program. For the majority of programming languages, including Swift, it consists out of 4 pieces:

<!-- Compiler is a part of a bigger scheme of producing an executable program, called a *language processing system*. For the majority of programming languages, including Swift, it consists out of 4 pieces: -->

- Preprocessor
- Compiler
- Assembler
- Linker / Loader

The parts of the language processing system are connected in 



### Summary

It is difficult to overestimate the importance that language processing systems play in software engineering.

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). I would highly appreciate you sharing this article if you find it useful.*

---

[starter-repo]: https://github.com/V8tr/CollectionViewGridLayout-Starter
[final-repo]: https://github.com/V8tr/CollectionViewGridLayout-Final