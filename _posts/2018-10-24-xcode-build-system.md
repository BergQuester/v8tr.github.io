---
layout: post
title: "Understanding Xcode Build System"
permalink: /xcode-build-system/
share-img: "/img/xcode-build-system/share.png"
---

Every Swift program undergoes a number of transformations before it can be run on a real device. This process is usually handled by an Xcode Build System. In this article we'll take a look at each part of Xcode Build System.

### Problem Statement

Any computer system is double-sided: it has *software* and *hardware* part.

*Hardware* is the physical part of a computer, such as the monitor or keyboard. *Hardware* is usually controlled by *software* which is a collection of instructions that tells hardware how to work. Since software orchestrates the process and hardware actually does the work, neither can be used on its own.

As software engineers, our primary focus is software part. However, hardware does not directly understand code written in Swift. It only accepts instructions in the form of electric charge that contains two levels, named *'Logic 0'* and *'Logic 1'*.

*Here comes the question*: "how is the Swift code transformed into a form that hardware can tolerate"? The answer is *language processing system*. 

### Language Processing System

*Language processing system* is a collection of programs that lend themselves to producing an executable program out of a set of instructions written in arbitrary source language. It allows programmers to use higher-level languages instead of writing machine code which greatly reduces programming complexity.

The language processing system that we are daily using in iOS or macOS development is named **Xcode Build System**.

### Xcode Build System

The main goal of *Xcode Build System* is to orchestrate execution of various tasks that will eventually produce an executable program. 

Xcode runs a number of tools and passes dozens of arguments between them, handles their order of execution, parallelism and much much more. This is definitely not what you want to be dealing with manually when writing your next Swift project.

The majority of language processing systems, including *Xcode Build Sytem*, consist out of 5 parts:

- Preprocessor
- Compiler
- Assembler
- Linker
- Loader
 
These pieces play together in a way depicted on the diagram below:

<p align="center">
    <a href="{{ "/img/xcode-build-system/language-processing-system.svg" | absolute_url }}">
        <img src="/img/xcode-build-system/language-processing-system.svg" width="350" alt="Understanding Xcode Build System - Language processing system"/>
    </a>
</p>

Let's take a closer look at each of these steps.

### Preprocessing

The purpose of preprocessing step is to transform your program in a way that it can be fed to a compiler. It replaces macros with their definitions, discovers dependencies and resolves preprocessor directives.

Considering that *Swift* compiler does not have a preprocessor, we are not allowed to define macros in our *Swift* projects. Nonetheless *Xcode Build System* partially compensates it and does preprocessing by means of *Active Compilation Conditions* that can be set in your project build settings.

*Xcode* resolves dependencies by means of lower-level build system *llbuild*. It is open source and you can find additional information on [swift-llbuild Github page](https://github.com/apple/swift-llbuild).

### Compiler

*Compiler* is a program that maps a source program in one language into a semantically equivalent target program in another language. In other words, it transforms *Swift*, *Objective-C* and *C/C++* code into machine code without losing the former's meaning.

*Xcode* uses two different compilers: one for Swift and the other for *Objective-C*, *Objective-C++* and *C/C++* files.

`clang` is Apple's official compiler for the *C* languages family. It is open-sourced here: [swift-clang](https://github.com/apple/swift-clang).

`swiftc` is a *Swift* compiler executable which is used by *Xcode* to compile and run *Swift* source code. I'd venture to guess that you have already visited this link at least once: it is located in [Swift language repository](https://github.com/apple/swift).

*Compiler* phase is depicted on below diagram:

<p align="center">
    <a href="{{ "/img/xcode-build-system/xcode-compiler.svg" | absolute_url }}">
        <img src="/img/xcode-build-system/xcode-compiler.svg" width="350" alt="Understanding Xcode Build System - Xcode uses two compilers: clang and swiftc"/>
    </a>
</p>

Compiler consists out of 2 main parts: *front end* and *back end*.

The *front end* part splits the source program into separate pieces without any semantic or type information and enforces a grammatical structure on them. Then the *compiler* uses this structure to produce an *intermediate representation* of the source program. It also creates and manages the *symbol table* that collects information about the source program.

{: .box-note}
*Symbol is name for a fragment of code or data.*

The *symbol table* stores names of variables, functions, classes, you name it, where each *symbol* is mapped to a certain piece of data.

In case of *Swift compiler*, intermediate representation is named *Swift Intermediate Language (SIL)*. It is used for further analysis and optimization of the code. It is not possible to generate machine code directly from *Swift Intermediate Language*, thus *SIL* undergoes one more transformation into *LLVM Intermediate Representation*.

During the *back end* phase, the intermediate representation is transformed into assembly code.

### Assembler

*Assembler* translates human-readable assembly code into *relocatable machine code*. It produces *Mach-O files* which are basically a collection of code and data.

The *machine code* and *Mach-O file* terms from the above definition require further explanation.

*Machine code* is a numeric language that represents a set of instructions that can be executed directly by CPU. It is named relocatable, because no matter where that object file is in the address space, the instructions will be executed relatively to that space.

*Mach-O file* is a special file format for iOS and macOS operating systems that is used for object files, executables and libraries. It is a stream of bytes grouped in some meaningful chunks that will run on the ARM processor of an iOS device or the Intel processor on a Mac.

### Linker

*Linker* is a computer program that merges various object files and libraries together in order to make a single *Mach-O* executable file that can be run on iOS or macOS system. *Linker* takes two kinds of files as its input. These are object files that come out of *assembler* phase and libraries of several types (`.dylib`, `.tbd` and `.a`).

An attentive reader might have noticed that both *assembler* and *linker* produce *Mach-O* files as their outputs. There must be some difference between them, right?

The object files coming out of assembly phase are not finished yet. Some of them contain missing pieces that reference other object files or libraries. For example, if you were using `printf` in your code, it is the *linker* that glues this symbol together with *libc* library where `printf` function is implemented. It uses the *symbol table* created during the *compiler* phase to resolve references across different object files and libraries.

{: .box-note}
You might have already stumbled upon *"undefined symbol"* error when building your *Swift* project in *Xcode* which has the aforementioned nature.

### Loader

Lastly, *loader* which is a part of operating system, brings a program into memory and executes it. Loader allocates memory space required to run the program and initializes registers to initial state.

### Summary

It is difficult to underestimate the importance of *language processing systems* in software engineering. Instead of writing binary code of ones and zeros that hardware understands, we are free to pick almost any higher-level programming language, say *Swift* or *Objective-C*. The language processing system will do the rest to produce an executable program that can be run on iPhone, Mac or any other end device.

As iOS and macOS developers we are using *Xcode Build System* on our daily basis. The main components of it are: *preprocessor*, *compiler*, *assembler*, *linker* and *loader*. *Xcode* uses different compilers for *Swift* and *Objective-C* languages, which are `swiftc` and `clang` correspondingly.

Understanding *Xcode* compilation process is foundational knowledge and is highly relevant for both beginners and seasoned developers.

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). I appreciate you sharing this article if you find it useful.*

---