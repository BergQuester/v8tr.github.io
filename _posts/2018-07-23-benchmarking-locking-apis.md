---
layout: post
title: Benchmarking Swift Locking APIs
permalink: /benchmarking-locking-apis/
share-img: "/img/benchmarking-atomic-properties.png"
---

When designing concurrent code in Swift, you might wonder which API to pick among the diversity of available choices. In this article we will benchmark performance of most notable Apple locking APIs and suggest best options based on their characteristics.

### Locking APIs and Atomicity

We've already covered major locking APIs as well as concurrent programming concepts in [Atomic Properties in Swift]({{ "/atomic-properties/" | absolute_url }}), so make sure you've checked this article before moving forward.

### Sampling Data

First off, let's describe sampling data and the way it has been collected.

| API under test | Name on chart |
|----------|-------------|
| `NSLock` | NSLock |
| `pthread_mutex_t` | Mutex |
| `pthread_rwlock_t` | Read-write lock |
| `os_unfair_lock_s`| Spinlock |
| `DispatchQueue` | Dispatch Queue |
| `OperationQueue`| Operation Queue |
{: .width-full .text-align-center}

To benchmark each API a class has been implemented with a critical section in its setter and getter.

### Source code

Main benchmark function:

<script src="https://gist.github.com/V8tr/e030176b09db21cf9578ebbec8e1f0e6.js"></script>

To compensate deviations of individual benchmark iterations, each data sample is calculated 100 times and an average value is taken.

<script src="https://gist.github.com/V8tr/530c8c79053f90d17cf5214e16b17413.js"></script>

Whole app source code can be found here: [https://github.com/V8tr/AtomicBenchmark](https://github.com/V8tr/AtomicBenchmark). It implements an abstraction over the above two methods, runs test samples and exports statistics to a CSV file.

### Benchmarking Getters

<p align="center">
    <a href="{{ "img/benchmarking-locking-apis-2.png" | absolute_url }}">
        <img src="/img/benchmarking-locking-apis-2.png" alt="Benchmarking Swift Locking APIs - 2"/>
    </a>
</p>

Locks have roughly equal performance, with `NSLock` being a bit slower than the others.

<p align="center">
    <a href="{{ "img/benchmarking-locking-apis-3.png" | absolute_url }}">
        <img src="/img/benchmarking-locking-apis-3.png" alt="Benchmarking Swift Locking APIs - 3"/>
    </a>
</p>

`OperationQueue` is way slower than `DispatchQueue`.

<p align="center">
    <a href="{{ "img/benchmarking-locking-apis-1.png" | absolute_url }}">
        <img src="/img/benchmarking-locking-apis-1.png" alt="Benchmarking Swift Locking APIs - 1"/>
    </a>
</p>

`DispatchQueue` is 7-8 times slower than locks, `OperationQueue` is ~20 times slower than the dispatch queue and 140-160 times slower than locks.

### Benchmarking Setters

<p align="center">
    <a href="{{ "img/benchmarking-locking-apis-5.png" | absolute_url }}">
        <img src="/img/benchmarking-locking-apis-5.png" alt="Benchmarking Swift Locking APIs - 5"/>
    </a>
</p>

Same as with getters, all locks have roughly equal performance and `NSLock` is a bit slower than the rest. Variance of statistic is higher, comparing to the same calculations for getters.

<p align="center">
    <a href="{{ "img/benchmarking-locking-apis-6.png" | absolute_url }}">
        <img src="/img/benchmarking-locking-apis-6.png" alt="Benchmarking Swift Locking APIs - 6"/>
    </a>
</p>

Comparing to getters, `OperationQueue` falls behind `DispatchQueue` even more.

<p align="center">
    <a href="{{ "img/benchmarking-locking-apis-4.png" | absolute_url }}">
        <img src="/img/benchmarking-locking-apis-4.png" alt="Benchmarking Swift Locking APIs - 4"/>
    </a>
</p>

`DispatchQueue` is 3-4 times slower than locks, `OperationQueue` is ~70 times slower than the dispatch queue and 220-250 times slower than locks.

### Comparing Setters vs. Getters

<p align="center">
    <a href="{{ "img/benchmarking-locking-apis-7.png" | absolute_url }}">
        <img src="/img/benchmarking-locking-apis-7.png" alt="Benchmarking Swift Locking APIs - 7"/>
    </a>
</p>

---

<p align="center">
    <a href="{{ "img/benchmarking-locking-apis-8.png" | absolute_url }}">
        <img src="/img/benchmarking-locking-apis-8.png" alt="Benchmarking Swift Locking APIs - 8"/>
    </a>
</p>

---

<p align="center">
    <a href="{{ "img/benchmarking-locking-apis-9.png" | absolute_url }}">
        <img src="/img/benchmarking-locking-apis-9.png" alt="Benchmarking Swift Locking APIs - 9"/>
    </a>
</p>

---

<p align="center">
    <a href="{{ "img/benchmarking-locking-apis-10-cut.png" | absolute_url }}">
        <img src="/img/benchmarking-locking-apis-10.png" alt="Benchmarking Swift Locking APIs - 10"/>
    </a>
</p>

---

<p align="center">
    <a href="{{ "img/benchmarking-locking-apis-11.png" | absolute_url }}">
        <img src="/img/benchmarking-locking-apis-11.png" alt="Benchmarking Swift Locking APIs - 11"/>
    </a>
</p>

---

<p align="center">
    <a href="{{ "img/benchmarking-locking-apis-12.png" | absolute_url }}">
        <img src="/img/benchmarking-locking-apis-12.png" alt="Benchmarking Swift Locking APIs - 12"/>
    </a>
</p>

`DispatchQueue` and `OperationQueue` have considerable variance of setter vs. getter performance, locks are approximately equal.

### Summary

Based on the benchmark results, `DispatchQueue` must be your best choice for creating a critical section in your code.

Under 10000 calculations it performs almost identical to locks, while providing higher-level and thus less error-prone API.

Besides the example in test project, where we use serial `DispatchQueue` with synchronous setter and getter, it can be configured in several ways that might be faster in some cases: 
- Serial queue with async setter and sync getter;
- Concurrent queue with a barrier in the setter;

If for some reason the block-based locking nature of `DispatchQueue` is not what you need, I'd suggest to go with `NSLock`. It's a bit more heavyweight than the rest of the locks, but this can be neglected.

Pthread locks are usually a bad choice due to considerably complex configuration and some usage nuances, as highlighted in [Atomic Properties in Swift]({{ "/atomic-properties/" | absolute_url }}).

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---