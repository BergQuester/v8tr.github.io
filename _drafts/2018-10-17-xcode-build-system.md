---
layout: post
title: "Understanding Xcode Build System"
permalink: /xcode-build-system/
share-img: ""
---

Every Swift program undergoes a number of transformations before it can be run on a real device. This process is usually handled by an Xcode Build System. In this article we'll take a look at how parts of Xcode Build System play together.

### Problem Statement

Any computer system is double-sided: it has *software* and *hardware* part.

*Hardware* is physical part of a computer, such as the monitor or keyboard. *Hardware* is usually controlled by *software* which is collection of instructions that tells hardware how to work. Since software orchestrates the process and hardware actually does the work, neither can be used on its own.

As software engineers, our primary focus is software part. However, hardware does not directly understand code written in Swift. It only accepts instructions in the form of electronic charge that contains two levels, named *'Logic 0'* and *'Logic 1'*, also known as *bytecode*.

*Here comes the question*: "how is the Swift code transformed into bytecode that hardware can tolerate"? The answer is *language processing system*. 

### Language Processing System

*Language processing system* is a collection of programs that lend themselves to producing an executable program out of a set of instructions written in arbitrary source language. It allows programmers to use higher-level languages instead of writing bytecode which greatly reduces programming complexity.

The language processing system that we are using in iOS or macOS development is named **Xcode Build System**.

### What is Xcode Build System

The main goal of Xcode Build System is to orchestrate execution of various tasks that will eventually produce an executable program. 

Xcode runs thousands of tools and passes dozens of arguments between them, handles their order of execution, parallelism and much much more. This is definitely not what you want to be dealing with manually when writing your next Swift project.

The majority of language processing systems, including *Xcode Build*, consist out of 5 parts:

- Preprocessor
- Compiler
- Assembler
- Linker
- Loader
 
These pieces play together in a way depicted on the diagram below:

<p align="center">
    <a href="{{ "/img/xcode-build-system/language-processing-system.svg" | absolute_url }}">
        <img src="/img/xcode-build-system/language-processing-system.svg" width="350" alt="Understanding Swift Compilation Process - Language processing system"/>
    </a>
</p>

Let's briefly take a look at each of these steps.

### Preprocessing

The purpose of preprocessing step is to transform your program in a way that it can be fed to a compiler. It replaces macros with their definitions, discovers dependencies and resolves preprocessor directives.

The sad truth is that Swift compiler does not have preprocessor. It means that we are not allowed to define macros in our Swift project. Nonetheless Xcode Build System partially compensates it and does preprocessing by means of *Active Compilation Conditions* that can be set in your project build settings.

<!-- #### Dependencies Graph -->

<!-- Under the hood Xcode extensively uses [llbuild](https://github.com/apple/swift-llbuild) which is an open-source low-level build system. Xcode feeds Swift, Objective-C, C and C++ to llbuild and the latter resolves inclusion for them and creates dependencies graph. Along with the graph, it generates metadata in llbuild-native format that is used on further stages of language processing system. -->

<!-- Under the hood Xcode extensively uses [llbuild](https://github.com/apple/swift-llbuild) that accepts Swift, Objective-C, C and C++ files and resolves dependencies inclusion for them by creating a directed graph.

*llbuild* is a low-level build system, used by Xcode. Along with dependencies graph, it creates metadata in llbuild-native format that is used on further stages of language processing system. -->

### Compiler

**Compiler** is a program that maps a source program in one language into a semantically equivalent target program in another language. In other words it transformation Swift into machine code without losing the former's meaning.

Compiler consists our of 2 main parts: *front end* and *back end*.

The **front end** part splits the source program into separate pieces without any semantic or type information and enforces a grammatical structure on them. Then the compiler uses this structure to produce an intermediate representation of the source program, named Swift Intermediate Language (SIL). It is used for further analysis and optimization of Swift code. It also manages the symbol table that collects information about the source program.

It is not possible to generate machine code directly from Swift Intermediate Language, thus SIL undergoes one more transformation into LLVM Intermediate Representation.

During the **back end** phase, LLVM transforms LLVM Intermediate Representation into assembly code.

### Assembler

Assembler translates assembly code into relocatable machine code and produces object file as its output.

Machine code is a numeric language that represents a set of instructions that can be executed directly by CPU. It is named relocatable, because no matter where that object file is in the address space, the instructions will be executed relatively to the file's position in memory.

<!-- the addresses are relative and 

The addresses of instructions of relocatable machine code is relative, 

Assembler is a program that produces object files out of assembly code. Object file contains machine level instructions, information about hardware registers etc. The instructions are known as known relocatable machine code

Assembler is a program that converts assembly code into machine code. The output of assembly is object file.

The output of  relocatable machine code out of assembly code. -->

### Linker

Linker is a computer program that links and merges various object files together in order to make an executable file. All these files might have been compiled by separate assemblers. The major task of a linker is to search and locate referenced module/routines in a program and to determine the memory location where these codes will be loaded, making the program instruction to have absolute references.

It is the job of the linker to take multiple object files and compound them into a single address space with absolute addressing.



### Summary

It is difficult to overestimate the importance that language processing systems play in software engineering.

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). I would highly appreciate you sharing this article if you find it useful.*

---

[starter-repo]: https://github.com/V8tr/CollectionViewGridLayout-Starter
[final-repo]: https://github.com/V8tr/CollectionViewGridLayout-Final