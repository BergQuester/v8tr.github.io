---
layout: post
title: "What are Static and Dynamic Frameworks and Libraries in iOS?"
permalink: /static-dynamic-frameworks-and-libraries/
share-img: "/img/share.png"
---

When developing iOS apps you rarely implement everything from the ground-up, because operating system as well as open source community offers large amount of functionality ready-to-use. Such pieces of functionality are usually packed in a distributable form known as a library. In this article let's explore static and dynamic libraries and frameworks which are the two major types of building blocks in iOS and macOS projects.

### Introduction

Frameworks and libraries are everywhere: *UIKit*, *Foundation*, *WatchKit*, *GameKit*, you name it - all of these are from Apple standard library and chances high that you are using lots of them in your current project. I'd venture to guess that you are also familiar with *CocoaPods* and *Carthage* that help you manage third parties in *Xcode* projects.

Despite most of *iOS* and *macOS* developers deal with libraries and frameworks on daily basis and intuitively understand what they are, there is lack of understanding how they work under the hood and how they differ.

Throughout the article we'll answer that questions along with these ones:
- What is a framework?
- What is a library and how it differs from a framework?
- What types of libraries exist?
- What are dynamic and static frameworks and libraries?
- How frameworks and libraries affect your app startup time?

### What is a Library?

*Libraries* are files that define pieces of code and data that are not part of your *Xcode* target. 

The process of merging external libraries with app’s source code files is known as *linking*. The product of *linking* is a single executable file that can be run on a device, say iPhone or Mac.

{: .box-note}
Besides *linking*, every *Xcode* project undergoes 4 more phases. If you want to learn more about them, I suggest reading [Understanding Xcode Build System]({{ "/xcode-build-system/" | absolute_url }}).

*Libraries* fall into *two* categories based on how they were linked to an app:
- Static libraries `.a`
- Dynamic libraries `.dylib`
- Text Based Dylib Stubs `.tbd`

Let's explore each type in more details.

<!-- *Libraries* are files that define *symbols* that are not part of your *Xcode* target.

The notion of *symbol* is fundamental to understand what libraries and frameworks are.

In computer programming, a *symbol* is an identifier associated with a fragment of code or data. For example, every time you write `Array` in your code, *Swift* compiler substitutes it with a unique identifier known as a *symbol*.

Relatively to an *Xcode* target, symbols might be *internal*, i.e. defined inside it, and *external*. Continuing our `Array` example, it is considered an external symbol since it is borrowed from *Swift* framework.

The compiler stores *symbols* in a *symbol table* which is a data structure that makes it more convenient to hold a bunch of *symbols* and ensure their uniqueness.

{: .box-note}
If you want to learn more about *Swift* project compilation process, I suggest reading [Understanding Xcode Build System]({{ "/xcode-build-system/" | absolute_url }}).

Libraries can be one of three types:
- Static library `.a`
- Dynamic library `.dylib`
- Text Based Dylib Stubs `.tbd` -->

### Static Library

*Static libraries* are collections of *object files*. In its turn, *object file* is just a name for a file that comes out of a compiler and contains machine code.

Static libraries are ending with `.a` suffix and are created with archiver tool. If it sounds very similar to *ZIP* archive, then it's exactly what it is. You can think of a static library as an archive of multiple *object files*. 

{: .box-note}
`.a` is an old format originally used by UNIX and its `ar` tool. If you want to give it a deep dive, I suggest reading [the man page](https://linux.die.net/man/1/ar).

*Object files* have *Mach-O* format which is a special file format for iOS and macOS operating systems. It is basically a binary stream with the following chunks:
- *Header*: Specifies the target architecture of the file. Since one *Mach-O* contains code and data for one architecture, code intended for `x86-64` will not run on `arm64`.
- *Load commands*: Specify the logical structure of the file, like the location of the *symbol table*.
- *Raw segment data*: Contains raw code and data.

An attentive eye might have noticed that *Mach-O* files support single architecture. Then how can a Swift app with lots of static libraries run on all devices and even the simulator?

The answer is `lipo` tool. It allows to package multiple single architecture libraries into a universal one, called *fat binary*, or vice-versa. Here you can [read more about `lipo`](https://ss64.com/osx/lipo.html).

### Dynamic Library

*Dynamic libraries*, as opposed to the static ones, rather than being copied into single monolithic executable, are loaded into memory when they are actually needed. This could happen either at load time or at runtime. 

*Dynamic libraries* are usually shared between applications, therefore the system needs to make only one copy of the library.

All iOS and macOS system libraries are dynamic, so that our apps are not bounded to specific copies of them and can benefit from the the improvements that Apple makes without shipping the new build.

After discovering what *static library* and *dynamic library* is, let's see how they actually get incorporated into your app.

### Comparing Static vs. Dynamic Libraries

Each type of library comes with own pros and cons.

Static Libraries Pros and Cons:

<table>
<tr>
    <td>Pros</td>
    <td>Cons</td>
</tr>
<tr>
    <td>
        <ul>
            <li>Libraries are guaranteed to be present in the app and have correct version.</li>
            <li>No need to keep an app up to date with library updates.</li>
            <li>Better performance of library calls.</li>
        </ul>  
    </td>
    <td>
        <ul>
            <li>Inflated app size.</li>
            <li>Launch time degrades. It takes longer to launch app that has large executable file inflated by static libraries.</li>
            <li>Must copy whole library even if using single function.</li>
        </ul>  
    </td>
</tr>
</table>                                                                                                                                                  |

<!-- Static Pros:
- Libraries are guaranteed to be present in the app and have correct version.
- No need to keep an app up to date with library updates.
- Better performance of library calls.
  
Static Cons:
- Inflated app size.
- Launch time degrades. It takes longer to launch app that has large executable file inflated by static libraries.
- Must copy whole library even if using single function.
  
Dynamic Pros:
- Can benefit from library improvements without app re-compile. Especially useful in case of system libraries.
- Takes less disk space, since it shares between applications.
- Faster startup time, as it is loaded on demand during runtime.
- Loaded by pieces: no need to load whole library if using just small piece.
  
Dynamic Cons:
- Can potentially break the program if anything changes in the library.
- Slower calls to library functions, as it is located outside application executable. -->

<!-- So it really is just an archive file. One thing worth noting is they also prenate dynamic linking so back in those days, all of the code would be consid-- would be distributed as archives. Because of that, you might not want to include all of the C library if you're using one function. So the behavior is if there's a symbol in a .o file, we would pull that whole .o file out of the archive.

But the other .o files would not be brought in. If you're referencing symbols between them, everything you need will be brought in. If you're using some sort of non-symbol behavior like a static initializer, or you're re-exporting them as part of your own dylib, you may need to explicitly use something like force load or all load to the linker to tell it bring in everything. Or these files, even though there's no linkage. So let's go through an example to try to tie this altogether. -->

- how affects app startup time

### What is a Framework?

### Text Based Dylib Stubs

There are also TBD files, or text-based dylib stubs. So what are those? Well, when we made the SDKs for iOS and macOS, we had all these dylibs with all these great functions like MapKit and WebKit that you may want to use. But we don't want to ship the entire copy of those with the SDK because it would be large. Ant the compiler and linker don't need. It's only needed to run the program.

So instead we create what's called a stub dylib where we delete the bodies of all of the symbols and we just have the names. And then once we did that, we've made a textual representation of them that are easier for us to use.

Currently, they are only used for distributing the SDKs to reduce size.

So you may see them in your project, but you don't have to worry about them.

And they only contain symbols.
 
### Summary

Each type of linking comes with its pros and cons. Understanding them will help you to make the right choice between static and dynamic libraries for your app.


---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). I appreciate you sharing this article if you find it useful.*

---