---
layout: post
title: "Missing Guide on Swift Code Style"
permalink: /swift-code-style/
share-img: "/img/swift-code-style-share.png"
---

When joining a new project or reading an open source code, you must have noticed that some projects are uniformly organized and well-structured, while others are messy and tangled? If we summarize the factors that yields such effect over the code base, we come across the notion of *code convention*.

Let's discover:
- What are code conventions?
- How their adoption can result in huge benefits for your project?
- What is SwiftLint?
- And which Swift code styles to pick?

### Defining Swift Code Convention

*Code convention* is a set of dos and don'ts which describe files organization, programming practices, design patterns, architectural approach, etc. It can be a formal set of rules that is followed by a team, organization or individual, or be as informal as a habit of applying certain coding practices.

*Code style* is a subset of *code convention* that govern file formatting, such as indentation, position of commas, braces, capitalization etc. In *Swift* community the distinction between the two is usually not made and the common term *Swift code style* or sometimes *Swift style guide* is used.

Here is how coding conventions might look like:
- *File naming*: a file that contains a single type must have the same name as the type does.
- *Line length limit*: a single line of code should not exceed 160 characters.
- *Naming*: variables are `lowerCamelCase`.

### Why to Use Swift Code Style

Every Swift developer knows that the language has huge potential, which in its turn can bring lots of complexity, make code tangled and hard to read and maintain. Therefore, the core goal of *Swift code style* is to reduce this complexity by describing good and bad practices of writing Swift code.

Why making code easier to read is so important?

According to [Robert C. Martin](https://www.goodreads.com/quotes/835238-indeed-the-ratio-of-time-spent-reading-versus-writing-is), *the time we spend reading the code is over **10x** more than writing it*. Furthermore, we are constantly reading existing code in order to write the new one. 

Another research from [Facts and Fallacies of Software Engineering](https://www.oreilly.com/library/view/facts-and-fallacies/0321117425/) states that **40%–80%** of the total program cost goes to maintenance.

Let's summarize benefits that *Swift style guide* yields:
- Helps to understand project structure.
- Improves code readability.
- Makes maintenance easier.
- Speeds up onboarding for new team members.
- Gives possibility to master best programming practices.
- Becomes a communication tool between programmers in the community.

Due to such a huge impact, *coding conventions* are usually adopted by IT organizations and even whole programming communities.

Designing a code style from scratch is a non-trivial task and requires consolidated efforts. Luckily, as Swift developers we don't have to reinvent the wheel and can utilize multiple existing *Swift style guides*.

Let's explore the most prominent Swift coding styles in more detail.

### Exploring Swift Code Styles

The definition of *good code style* is subjective and my personal recommendation is to elaborate on multiple styles and shape them according to your project needs. The below list is here to help.

#### 1. Swift.org 

This guide is a standard by default in Swift community. It consolidates the absolute minimum set of rules which every Swift developer must understand and follow. 

The guide focuses on foundational aspects of Swift API design which is followed by all system frameworks. Not only it will make your code look organic in conjunction with system APIs, but also make it easier to read and understand Cocoa frameworks.

On its own, *Swift.org* code style is not enough to provide a comprehensive set of rules, but it makes a great addition to the other guides listed below.

Link: [Swift.org code style](https://swift.org/documentation/api-design-guidelines/)

#### 2. Google

You don't normally come across 'Google' and 'Swift' in one sentence, but not this time. Google undoubtedly understands the importance of code conventions and creates conventions for every major open-source projects, as stated in [Google Style Guides](http://google.github.io/styleguide/). My guess is that we should thank [TensorFlow](https://www.tensorflow.org/swift/) for this Swift guide.

This Swift code style impresses with its comprehensiveness. It covers so many aspect that simply listing them here would make this article twice as long.

What is really valuable about this guide is that *every* point is well founded by listing good programming practices which are often foundational to all languages. *Programming Practices* section, which I highly recommend to read whether you are looking for a Swift guide or not, really shines in this aspect.

After reading and understanding this guide you will find yourself a better programmer in general as well as add a bunch of Swift tricks into your pocket.

Link: [Google Swift code style](https://google.github.io/swift)

#### 3. Ray Wenderlich

The team behind *raywenderlich.com* is well-known in iOS community and does not need a special introduction. Same as Ray's articles do, the guide is written in a clear and understandable manner and is especially suitable for Swift newcomers

This guide undoubtedly reaches the stated goals of being clear, consistent and brief. Each rule is followed by a complete explanation, reasoning and a set of examples with dos and don'ts.

What I love about this guide, is that goes beyond Swift syntax and code formatting and explains good programming practices, such as avoidance of unused code, explains the difference between value and reference types, the concepts of lazy initialization, access control, early returns and much more.

At the time I am writing this article, it already has 137 closed pull requests which demonstrates that the guide is heavily supported by community.

Link: [Ray Wenderlich Swift code style](https://github.com/raywenderlich/swift-style-guide)

#### 4. LinkedIn

LinkedIn does great job at open sourcing their internal components and Swift ones are not an exception. Their *Swift style guide* has existed for over 3 years and incorporated lots of improvement from both open source community and LinkedIn team. 

LinkedIn Swift guide is brief, concise and well-structured. Short theoretical explanations are often provided to better understand the reasoning behind certain rules. The examples are always self-explanatory and clearly demonstrate the point.

The guide primarily focuses on code formatting and I highly recommend to use it in combination with other Swift code styles from this list.

Link: [LinkedIn Swift code style](https://github.com/linkedin/swift-style-guide)

### Swift Code Linter SwiftLint

We are all humans and deliberately or not, we all make mistakes. Thus, it is not enough to document or verbally agree on *Swift coding conventions*. To minimized the number of mistakes, the rules must be enforced by an automated tool, known as *linter*.

*Linter* is a static code analyzer that finds programming errors, bugs, formatting errors, and potentially harmful constructs. 

*SwiftLint* is the most widely used Swift code analyzer which can be configured based on custom rules. If you are not using it already, I highly recommend checking [SwiftLint](https://github.com/realm/SwiftLint) and start using it in your Swift projects as soon as possible.

The most important thing to understand about *SwiftLint* is that it does not enforce a 'single true style', but helps to be consistent within a project.

### Summary

Uniform code conventions contribute to programming productivity a lot and we always want to be as productive as possible. 

The list with most notable Swift coding styles is a great source of Swift best practices and a starting point to elaborate on your own set of conventions.

Good Swift code style is subjective and should be left upon you and your team's consideration. Once it is approved and documented, such style becomes a standard and must be consistent across the project to improve readability which results in numerous benefits.

SwiftLint is a widely adopted tool in Swift community which helps to enforce coding conventions. It helps to avoid human mistakes early and can be a valuable additions to your project's tools stack.

---

*If you enjoyed reading this article, tweet it forward and subscribe: [@V8tr](https://twitter.com/{{ site.author.twitter }}).*

---