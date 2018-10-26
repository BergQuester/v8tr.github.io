---
layout: post
title: "What are Static and Dynamic Frameworks and Libraries in iOS?"
permalink: /static-dynamic-frameworks-and-libraries/
share-img: "/img/share.png"
---

When developing iOS apps you rarely implement everything from the ground-up, because operating system as well as open source community offers large amount of functionality ready-to-use. Such pieces of functionality are usually packed in a distributable form which is known as a library. In this article let's explore static and dynamic libraries and frameworks which are the two major forms of such building blocks in iOS and macOS projects.

### Introduction

Frameworks and libraries are everywhere: *UIKit*, *Foundation*, *WatchKit*, *GameKit*, you name it - all of these are from Apple standard library and chances high that you are using dozens of them in your current project. I'd venture to guess that you are also familiar with *CocoaPods* and *Carthage* that help you manage third parties in your *Xcode* project.

Despite most of *iOS* and *macOS* developers deal with libraries and frameworks on daily basis and intuitively understand what they are, there is lack of understanding how they work under the hood and how they differ.

Throughout the article we'll answer that questions along with these ones:
- What is a framework?
- What is a library and how it differs from a framework?
- What are dynamic and static frameworks and libraries?
- How frameworks and libraries affect your app startup time?

### What is a Library?

*Libraries* are files that define *symbols* that are not part of your Xcode target.

In computer programming, a *symbol* is an identifier associated with a fragment of code or data. For example, each piece of code where you use `Array` will be replaced with a *symbol* from *Swift* framework by the compiler.

<!-- For example, each time you use an `Array` in your code, the compiler translates it to a symbol from *Foundation* framework which is not a part of your app. -->

The compiler stores *symbols* in a *symbol table* which is just a data structure suitable for holding a bunch of *symbols* along with their appearance in code.

{: .box-note}
If you want to learn more about *Swift* project compilation process, I suggest reading [Understanding Xcode Build System]({{ "/xcode-build-system/" | absolute_url }}).

Libraries can be one of three types:
- Static library `.a`
- Dynamic library `.dylib`
- Text Based Dylib Stubs `.tbd`

### Static Library

*Static libraries* are collections of *object files* that have already been built with `ar` tool. Object files are *Mach-O file* which is a special file format for iOS and macOS operating systems that is used for object files, executables and libraries. It is a stream of bytes grouped in some meaningful chunks that will run on the ARM processor of an iOS device or the Intel processor on a Mac.

So static archives are just collections of .o files that have been built with the AR tool or in some cases the lib the lib tool which is a wrapper for that.

And according to the AR [inaudible] page, the AR utility creates and maintains groups of files combined into an archive. Now that may sound a lot like a TAR file or a ZIP file, and that's exactly what it is. In fact, the .a format was the original archive format used by UNIX before more powerful tools came around. But the compilers of the time and the linkers of the time natively understood them, and they've just kept using them.

So it really is just an archive file. One thing worth noting is they also prenate dynamic linking so back in those days, all of the code would be consid-- would be distributed as archives. Because of that, you might not want to include all of the C library if you're using one function. So the behavior is if there's a symbol in a .o file, we would pull that whole .o file out of the archive.

But the other .o files would not be brought in. If you're referencing symbols between them, everything you need will be brought in. If you're using some sort of non-symbol behavior like a static initializer, or you're re-exporting them as part of your own dylib, you may need to explicitly use something like force load or all load to the linker to tell it bring in everything. Or these files, even though there's no linkage. So let's go through an example to try to tie this altogether.

### Dynamic Library

So we have dynamic libraries, and those are Mach-O files that expose code and data fragments for executables to use. Those are distributed as part of the system.

### Text Based Dylib Stubs

There are also TBD files, or text-based dylib stubs. So what are those? Well, when we made the SDKs for iOS and macOS, we had all these dylibs with all these great functions like MapKit and WebKit that you may want to use. But we don't want to ship the entire copy of those with the SDK because it would be large. Ant the compiler and linker don't need. It's only needed to run the program.

So instead we create what's called a stub dylib where we delete the bodies of all of the symbols and we just have the names. And then once we did that, we've made a textual representation of them that are easier for us to use.

Currently, they are only used for distributing the SDKs to reduce size.

So you may see them in your project, but you don't have to worry about them.

And they only contain symbols.

### Static Linking
- how affects app startup time

### Dynamic Linking
- how affects app startup time

### What is a Framework?

- how dynamic libraries are loaded at app launch time and how to us

### Types of Frameworks

### Why to Use Frameworks and Libraries

### App Startup Time
 
### Summary

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). I appreciate you sharing this article if you find it useful.*

---