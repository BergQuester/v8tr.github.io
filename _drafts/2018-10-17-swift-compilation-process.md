---
layout: post
title: "Understanding Swift Compilation Process"
permalink: /swift-compilation-process/
share-img: "/img/swift-compilation-process/share.png"
---

### Introduction

**Compiler** is a program that maps a source program in one language - in our case Swift - into a semantically equivalent target program in another language, in our case the machine code.

In its turn, compiler is a part of a bigger scheme named *language processing system*, main goal of which is to produce an executable program. For the majority of programming languages, including Swift, it consists out of 4 pieces:

<!-- Compiler is a part of a bigger scheme of producing an executable program, called a *language processing system*. For the majority of programming languages, including Swift, it consists out of 4 pieces: -->

- Preprocessor
- Compiler
- Assembler
- Linker / Loader

<p align="center">
    <a href="{{ "/img/swift-compilation-process/language-processing-system.svg" | absolute_url }}">
        <img src="/img/swift-compilation-process/language-processing-system.svg" width="260" alt="Understanding Swift Compilation Process - Language processing system"/>
    </a>
</p>

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). I would highly appreciate you sharing this article if you find it useful.*

---

[starter-repo]: https://github.com/V8tr/CollectionViewGridLayout-Starter
[final-repo]: https://github.com/V8tr/CollectionViewGridLayout-Final