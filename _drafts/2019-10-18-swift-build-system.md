---
layout: post
title: "Understanding Swift Build System"
permalink: /swift-build-system/
share-img: "/img/swift-preprocessing/share.png"
---

Every Swift program undergoes a number of steps before it can be run on your device. Let's take a look at one of such steps named build.

### Introduction

As Swift developers we often take for granted the enormous amount of work that Xcode does for us to execute our code on an end machine. Under the hood Xcode runs and coordinates thousands of commands, and orchestrates thousands of files of various types, such as Swift, Objective-C, C and C++. Throughout this article we will learn what exactly happens under the hood of one of such steps named *build system*.

### Xcode Build System

Xcode build system is a tool that prepares a program to be fed to a compiler. Xcode runs a number of tasks during this phase:
- Preprocessing
- Resolve tasks execution order
- Discover internal and external dependencies
- Build files dependency graph
- Change detection
- Task signatures

Throughout this article we will go through the each step.

### Preprocessing

Although Swift compiler does not support preprocessing directly, it is partially compensated by use of *Active Compilation Conditions*. Custom preprocessor commands can be defined in Xcode build settings by means of `SWIFT_ACTIVE_COMPILATION_CONDITIONS`. Xcode passes these conditions to `swiftc` compiler as a conditional compilation directives.

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

The lack of preprocessor means that in Swift we are unable to use C-style macro, like we did in Objective-C:

```C
#define ANIMATION_DURATION 0.5 // Does not compile in Swift
```

#### Dependencies Graph

Under the hood Xcode extensively uses [llbuild](https://github.com/apple/swift-llbuild) which is an open-source low-level build system. Since llbuild is language-agnostic, it handles all types of files Xcode project can potentially have, such as Swift, Objective-C, C/C++, .plist, you name it. Taking these files as an input, llbuild generates metadata in llbuild-native format that is used on further stages of build process.

Based on that metadata, llbuild accomplishes a series of important tasks:
- Builds dependencies graph.

resolves inclusion for them and creates dependencies graph. Along with the graph, it generates metadata in llbuild-native format that is used on further stages of language processing system.

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