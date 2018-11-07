---
layout: post
title: "Static and Dynamic Libraries and Frameworks in iOS"
permalink: /static-dynamic-frameworks-and-libraries/
share-img: "/img/static-dynamic-frameworks-and-libraries-share.png"
---

When developing iOS apps you rarely implement everything from the ground-up, because operating system as well as open source community offers large amount of functionality ready-to-use. Such pieces of functionality are usually packed in a distributable form known as a library. In this article let's explore static and dynamic libraries and frameworks which are the two major types of building blocks in iOS and macOS projects.

### Introduction

Frameworks and libraries are everywhere: *UIKit*, *Foundation*, *WatchKit*, *GameKit*, you name it — all of these are from Apple standard library and chances high that you are using lots of them in your current project. I'd venture to guess that you are also familiar with *CocoaPods* and *Carthage* that help you manage third parties in *Xcode* projects.

Despite most of *iOS* and *macOS* developers deal with libraries and frameworks on daily basis and intuitively understand what they are, there is lack of understanding how they work under the hood and how they differ.

Throughout the article we'll answer that questions along with these ones:
- What are libraries and frameworks?
- What types of frameworks and libraries exist?
- Which kind of libraries should you use in your project?
- How frameworks and libraries affect your app startup time?

### What is a Library?

*Libraries* are files that define pieces of code and data that are not a part of your *Xcode* target. 

The process of merging external libraries with app’s source code files is known as *linking*. The product of *linking* is a single executable file that can be run on a device, say iPhone or Mac.

{: .box-note}
Besides *linking*, every *Xcode* project undergoes 4 more phases to produce an executable application. In [Understanding Xcode Build System]({{ "/xcode-build-system/" | absolute_url }}) I will walk you through these steps.

*Libraries* fall into *two* categories based on how they are linked to the app:
- Static libraries — `.a`
- Dynamic libraries — `.dylib`

Additionally, a special kind of libraries exists:
- Text Based `.dylib` stubs — `.tbd`

Let's explore each type in more details.

### What is a Framework?

*Framework* is a package that can contain resources such as dynamic libraries, strings, headers, images, storyboards etc. With small changes to its structure, it can even contain other frameworks. Such aggregate is known as *umbrella framework*.

*Frameworks* are also bundles ending with `.framework` extension. They can be accessed by `NSBundle / Bundle` class from code and, unlike most bundle files, can be browsed in the file system that makes it easier for developers to inspect its contents. *Frameworks* have *versioned bundle format* which allows to store multiple copies of code and headers to support older program version. You can learn about bundles structure in [Bundle Programming Guide by Apple](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFBundles/BundleTypes/BundleTypes.html#//apple_ref/doc/uid/10000123i-CH101-SW1).

### Static Library

*Static libraries* are collections of *object files*. In its turn, *object file* is just a name for a file that comes out of a compiler and contains machine code.

Static libraries are ending with `.a` suffix and are created with an *archiver* tool. If it sounds very similar to a *ZIP* archive, then it's exactly what it is. You can think of a static library as an archive of multiple *object files*. 

{: .box-note}
`.a` is an old format originally used by UNIX and its `ar` tool. If you want to give it a deep dive, I suggest reading [the man page](https://linux.die.net/man/1/ar).

*Object files* have *Mach-O* format which is a special file format for iOS and macOS operating systems. It is basically a binary stream with the following chunks:
- *Header*: Specifies the target architecture of the file. Since one *Mach-O* contains code and data for one architecture, code intended for `x86-64` will not run on `arm64`.
- *Load commands*: Specify the logical structure of the file, like the location of the *symbol table*.
- *Raw segment data*: Contains raw code and data.

An attentive eye might have noticed that *Mach-O* files support single architecture. Then how can a *Swift* app with lots of static libraries run on all devices and even the simulator?

The answer is `lipo` tool. It allows to package multiple single architecture libraries into a universal one, called *fat binary*, or vice-versa. Here you can [read more about `lipo`](https://ss64.com/osx/lipo.html).

### Dynamic Library

*Dynamic libraries*, as opposed to the static ones, rather than being copied into single monolithic executable, are loaded into memory when they are actually needed. This could happen either at load time or at runtime. 

*Dynamic libraries* are usually shared between applications, therefore the system needs to store only one copy of the library and let different processes access it. As a result, invoking code and data from *dynamic libraries* happens slower than from the *static* ones.

All iOS and macOS system libraries are dynamic. Hence our apps will benefit from the future improvements that Apple makes to standard library frameworks without creating and shipping new builds.

### Text Based Dylib Stubs

When we link system libraries, such as *UIKit* or *Foundation*, we don't want to copy their entirety into the app, because it would be too large. Linker is also strict about this and does not accept shared `.dylib` libraries to be linked against, but only `.tbd` ones. So what are those?

*Text-based `.dylib` stub, or `.tbd`,* is a text file that contains the names of the methods without their bodies, declared in a *dynamic library* . It results in a significantly lower size of `.tbd` compared to a matching *.dylib*. Along with method names, it contains location of the corresponding `.dylib`, architecture, platform and some other metadata. Here is how a typical `.tbd` looks when opened in text editor:

```plaintext
--- !tapi-tbd-v3
archs:           [ x86_64 ]
uuids:           [ 'x86_64: 6FFAC142-415D-3AF0-BC09-336302F11934' ]
platform:        macosx
install-name:    /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libQuadrature.dylib
objc-constraint: none
exports:         
  - archs:           [ x86_64 ]
    allowable-clients: [ vecLib ]
    symbols:         [ _quadrature_integrate ]
...
```

### Comparing Static vs. Dynamic Libraries

Let's summarize pros and cons of static and dynamic libraries.

---

#### Static Libraries

✓ *Pros:*
- *Static libraries* are guaranteed to be present in the app and have correct version.
- No need to keep an app up to date with library updates.
- Better performance of library calls.
  
✕ *Cons:*
- Inflated app size.
- Launch time degrades because of bloated app executable.
- Must copy whole library even if using single function.
  
---

#### Dynamic Libraries

✓ *Pros:*
- Can benefit from library improvements without app re-compile. Especially useful with system libraries.
- Takes less disk space, since it is shared between applications.
- Faster startup time, as it is loaded on-demand during runtime.
- Loaded by pieces: no need to load whole library if using single function.
  
✕ *Cons:*
- Can potentially break the program if anything changes in the library.
- Slower calls to library functions, as it is located outside application executable.

---
 
### Summary

Libraries and frameworks are basic building blocks for creating *iOS* and *macOS* programs.

Libraries are collections of code and data, while *frameworks* are hierarchial directories with different kinds of files, including other *libraries* and *frameworks*. 

Based on how libraries are linked, they can be *static* or *dynamic*. Each kind of linking comes with its pros and cons. Understanding them will help you to make the right choice between *static* and *dynamic* libraries for your project.

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). I appreciate you sharing this article if you find it useful.*

---