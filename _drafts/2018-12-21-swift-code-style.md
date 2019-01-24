---
layout: post
title: "Swift Code Style"
permalink: /swift-code-style/
share-img: "/img/data-drive-table-views-share.png"
---

### Problem Statement

When joining a new project or reading an open source code, you must have noticed that some projects are uniformly organized and well-structured, while others are messy and tangled? If we summarize the factors that yields such effect over the code base, we come across the notion of *code convention*.

Let's discover:
- What are the purposes of code conventions?
- Why their adoption can result in huge benefits for your project?
- And which Swift code styles to use?

### Defining Swift Code Convention

*Code convention* is a set of dos and don'ts which describe files organization, programming practices, design patterns, architectural approach, etc. It can be a formal set of rules that is followed by a team, organization or individual, or be as informal as a habit of applying certain coding practices.

*Code style* is a subset of *code convention* that govern file formatting, such as indentation, position of commas, braces, capitalization etc. Historically, in *Swift* community the distinction between the two is not made and the common term *Swift code style* is used. We will also use these terms interchangeably.

Examples of coding style rules:
- *File naming*: a file that contains a single type must have the same name as the type does.
- *Line length limit*: a single line of code should not exceed 160 characters.
- *Naming*: variables are `lowerCamelCase`.

### Why to Use Swift Code Style

Every Swift developer knows that the language has huge potential, which in its turn can bring lots of complexity, make code tangled and hard to read and maintain. Therefore, the core goal of *Swift code style* is to reduce this complexity by describing good and bad practices of writing Swift code.

Why making code easier to read is so important?

According to [Robert C. Martin](https://www.goodreads.com/quotes/835238-indeed-the-ratio-of-time-spent-reading-versus-writing-is), *the time we spend reading the code is over **10x** more than writing it*. Furthermore, we are constantly reading existing code to write the new one. 

Another research from [Facts and Fallacies of Software Engineering](https://www.oreilly.com/library/view/facts-and-fallacies/0321117425/) states that **40%–80%** of the total program cost goes to maintenance.

Let's summarize benefits that *Swift code style* yields:
- Helps to understand project structure.
- Improves code readability.
- Makes maintenance easier.
- Speeds up onboarding for new team members.
- Gives possibility to master best programming practices.
- Becomes a communication tool between programmers around the globe.

Due to such a huge impact, uniform code styles are usually adopted by IT organizations and programming language communities and might serve as a communication tool between programmers.

Designing a code style is a non-trivial task and requires lots of time and efforts. Luckily, as Swift developers we don't have to reinvent the wheel and can utilize the existing solutions. Let's explore the most prominent Swift coding styles which offer a great way to learn best language practices and are candidates to become a standard for your next project.

### Exploring Swift Code Styles

The definition of *good code style* is subjective and my personal recommendation is to elaborate on the *Swift style guides* from the below list and shape them according to your project needs.

Personally, I have used each of the code styles below at least in one production project and must admit that there much to learn from each of them.

#### 1. Swift.org 

Link: https://swift.org/documentation/api-design-guidelines/

This guide is the absolute minimum each Swift developer must read and follow. It focuses on foundational aspects of the Swift API design and is adopted by all system frameworks. Not only it will make your code look organic in conjunction with system API, but also make it easier to read and understand standard Cocoa frameworks.

On its own, Swift.org code style is not enough to provide a comprehensive set of rules, but it will make a great addition to the style guides listed below.

#### 2. Ray Wenderlich's Guide

Link: https://github.com/raywenderlich/swift-style-guide

The team behind *raywenderlich.com* is well-known in iOS community and does not need a special introduction. Same as Ray's articles are, the guide is written in a clear and understandable manner and is especially suitable for Swift newcomers

This guide undoubtedly riches the stated goals of being clear, consistent and brief. Each rule it followed by a comprehensive explanation, reasoning and a set of examples.

What I love about this guide, is that goes far beyond Swift syntax and code formatting and explains such good programming practices as avoidance of unused code, minimization of imports, explains the difference between value and reference types, the concepts of lazy initialization, access control, early returns.

#### 3. LinkedIn https://github.com/linkedin/swift-style-guide

#### 4. Google https://google.github.io/swift/#line-wrapping

Good style is subjective and should be left on your and your team's consideration.

### Static Analyzer

Not enough to document or verbally agree.

Allows for static analyzers based on accepted rules.

### Summary

Thus, every effort that improves readability contributes to programming productivity a lot and we always want to be as much productive as possible.

---

*If you enjoyed reading this article, tweet it forward and subscribe: [@V8tr](https://twitter.com/{{ site.author.twitter }}).*

---