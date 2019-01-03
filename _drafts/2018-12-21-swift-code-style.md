---
layout: post
title: "Swift Code Style"
permalink: /swift-code-style/
share-img: "/img/data-drive-table-views-share.png"
---

- Problem statement
- Definition
- 

### Problem Statement

When joining a new project or reading an open source code, you must have noticed that some projects are uniformly organized and well-structured, while others are messy and tangled? If we summarize the factors that yields such effect over the code base, we come across the notion of *code convention*.

What is the purpose of *Swift code style* and how can your project benefit from it?

### Defining Swift Code Style

*Code convention* is a set of dos and don'ts which describe files organization, programming practices, design patterns, architectural approach, etc. It can be formalized as a set of rules that is followed by a team, organization or individual, or be as informal as a habit of applying certain coding practices.

*Code style* is a subset of *code convention* that govern file formatting, such as indentation, position of commas, braces, capitalization etc. Historically, in *Swift* community the distinction between the two is not made and the common term *Swift code style* is used. We will also use these terms interchangeably.

The conventions serve a number of goals:
- Help to understand project structure.
- Improve code readability.
- Make maintenance easier.
- Faster onboard new team members.
- Gives possibility to master best programming practices.
- Communication tool between programmers around the globe.

### Why to Use Swift Code Style

According to [Robert C. Martin](https://www.goodreads.com/quotes/835238-indeed-the-ratio-of-time-spent-reading-versus-writing-is), *the time we spend reading the code is over **10x** more than writing it*. Furthermore, we are constantly reading existing code to write the new one. Another research from [Facts and Fallacies of Software Engineering](https://www.oreilly.com/library/view/facts-and-fallacies/0321117425/) states that 40%–80% of the total program cost goes to maintenance. 

Thus, every effort that improves readability contributes to programming productivity a lot and we always want to be as much productive as possible.

Due to such a huge impact, uniform code styles are usually adopted by IT organizations and programming language communities and might serve as a communication tool between programmers.

Designing a code style is a non-trivial task and requires lots of time and efforts. Luckily, as Swift developers we don't have to reinvent the wheel and can utilize the existing solutions. Let's explore the most prominent Swift coding styles which offer a great way to learn Swift best practices and are candidates to become a standard for your next Swift project.

### Exploring Swift Code Styles

Keep in mind that the definition of *good code style* is subjective. My personal recommendation is to elaborate on the Swift code styles from the below list and if needed come up with some adjustments based on your own consideration.

The below list is ordered based on my preference. Personally, I have used each of these Swift code styles and can safely recommend each of them.

#### 1. Swift.org https://swift.org/documentation/api-design-guidelines/

Mandatory for every Swift developer to read, this guide focuses on foundational aspects of Swift API design. You will discover all Apple APIs following this guideline and it will help your code look organically in conjunction with system APIs. 

On its own, Swift.org code style is not enough to provide a comprehensive set of rules, but it will make a great addition to the style guides listed below.

#### 2. Ray https://github.com/raywenderlich/swift-style-guide

Written by a highly professional team which focuses on publishing content for a large community, folks at raywenderlich.com definitely know how to make code appear crystal clear to the reader.

According to the guide, its main goals are clarity, consistency and brevity, and undoubtedly all of them are reached.

What I love about this guide, is that goes beyond Swift syntax and explain such good programming practices as avoidance of unused code, minimization of imports, explains the difference between value and reference types, lazy initialization, access control, early returns.

This style is highly recommended for beginners and seasoned developers, I am sure everyone has something to learn from it.

#### 3. LinkedIn https://github.com/linkedin/swift-style-guide

#### 4. Google https://google.github.io/swift/#line-wrapping

Good style is subjective and should be left on your and your team's consideration.

### Static Analyzer

Not enough to document or verbally agree.

Allows for static analyzers based on accepted rules.

### Summary


---

*If you enjoyed reading this article, tweet it forward and subscribe: [@V8tr](https://twitter.com/{{ site.author.twitter }}).*

---