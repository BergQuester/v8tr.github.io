---
layout: post
title: "Structure of Swift Language Processing System"
permalink: /swift-language-processing-system/
share-img: "/img/swift-language-processing-system/share.png"
---

Before a Swift program can be executed, it first must be translated into a form that can be understood by a target device. In this article we will learn which transformations a Swift program undergoes before it can be run on your machine.

### Introduction

Any computer system is double-sided: it has *software* and *hardware* parts. Hardware is physical part of a computer, such as the monitor or keyboard.

Hardware is usually controlled by software which is collection of instructions that tells hardware how to work. Since software orchestrates the process, while hardware actually does the work, neither can be used on its own.

As iOS engineers, our primary focus is software part. However, hardware understands instructions in the form of electronic charge that contains two levels, named *Logic 0* and *'Logic 1'*. 

Here comes the question: how is the Swift code that we write transformed into ones and zeros that hardware understands?

### Language Processing System

The answer is *language processing system*. *Language processing system* is a collection of programs that lend themselves to producing an executable program out of the set of instructions written in arbitrary source language.

Language processing systems allow programmers to use higher-level languages instead of writing bytecode which greatly reduces programming complexity.

### Compiler

**Compiler** is a program that maps a source program in one language - in our case Swift - into a semantically equivalent target program in another language, in our case the machine code.

In its turn, compiler is a part of a bigger scheme named *language processing system*, main goal of which is to produce an executable program. For the majority of programming languages, including Swift, it consists out of 4 pieces:

<!-- Compiler is a part of a bigger scheme of producing an executable program, called a *language processing system*. For the majority of programming languages, including Swift, it consists out of 4 pieces: -->

- Preprocessor
- Compiler
- Assembler
- Linker / Loader

The parts of the language processing system are connected in 

<p align="center">
    <a href="{{ "/img/swift-language-processing-system/language-processing-system.svg" | absolute_url }}">
        <img src="/img/swift-language-processing-system/language-processing-system.svg" width="260" alt="Understanding Swift Compilation Process - Language processing system"/>
    </a>
</p>

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). I would highly appreciate you sharing this article if you find it useful.*

---

[starter-repo]: https://github.com/V8tr/CollectionViewGridLayout-Starter
[final-repo]: https://github.com/V8tr/CollectionViewGridLayout-Final