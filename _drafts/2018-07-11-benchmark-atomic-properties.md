---
layout: post
title: Benchmarking Atomic Properties in Swift
permalink: /benchmark-atomic-properties/
share-img: "/img/atomic-properties-share.png"
---

- Intro
- Conclusion

When designing atomic property in Swift, you might wonder which API to pick among the diversity of available choices. In this article we will benchmark performance of most notable Apple locking APIs and suggest best options based on their characteristics.

### Locking APIs and Atomicity

We've already covered major locking APIs as well as concurrent programming concepts in [Atomic Properties in Swift]({{ "/atomic-properties/" | absolute_url }}), so make sure you've checked this article before moving forward.

### Sampling Data

First off, let's describe the data and the way it has been collected.

| API under test | Name on chart |
|----------|-------------|
| `NSLock` | NSLock |
| `pthread_mutex_t` | Mutex |
| `pthread_rwlock_t` | Read-write lock |
| `os_unfair_lock_s`| Spinlock |
| `DispatchQueue` | Dispatch Queue |
| `OperationQueue`| Operation Queue |

- `NSLock`
- `pthread_mutex_t` - named *Mutex* on charts
- `pthread_rwlock_t` - named *Read-write* lock on charts
- `os_unfair_lock_s` - named *Spinlock* on charts
- `DispatchQueue`
- `OperationQueue`

#### Source code

Small utility app was created for this article: [https://github.com/V8tr/AtomicBenchmark](https://github.com/V8tr/AtomicBenchmark). It benchmarks atomic properties created with the above APIs and exports it to a CSV file.

We use power-of-two data points. Each data sample is calculated 100 times and then an average value is taken to compensate possible deviations.

### Benchmarking Getters

<p align="center">
    <a href="{{ "img/benchmark-atomic-prop-2.png" | absolute_url }}">
        <img src="/img/benchmark-atomic-prop-2.png" alt="Benchmarking Atomic Properties in Swift - 2"/>
    </a>
</p>

Locks have roughly equal performance, with `NSLock` being a bit slower than the others.

<p align="center">
    <a href="{{ "img/benchmark-atomic-prop-3.png" | absolute_url }}">
        <img src="/img/benchmark-atomic-prop-3.png" alt="Benchmarking Atomic Properties in Swift - 3"/>
    </a>
</p>

`OperationQueue` is way slower than `DispatchQueue`.

<p align="center">
    <a href="{{ "img/benchmark-atomic-prop-1.png" | absolute_url }}">
        <img src="/img/benchmark-atomic-prop-1.png" alt="Benchmarking Atomic Properties in Swift - 1"/>
    </a>
</p>

`DispatchQueue` is 7-8 times slower than locks, `OperationQueue` is ~20 times slower than the dispatch queue and 140-160 times slower than locks.

### Benchmarking Setters

<p align="center">
    <a href="{{ "img/benchmark-atomic-prop-5.png" | absolute_url }}">
        <img src="/img/benchmark-atomic-prop-5.png" alt="Benchmarking Atomic Properties in Swift - 5"/>
    </a>
</p>

Same as with getters, all locks have roughly equal performance and `NSLock` is a bit slower than the rest. Variance of statistic is higher, comparing to the same calculations for getters.

<p align="center">
    <a href="{{ "img/benchmark-atomic-prop-6.png" | absolute_url }}">
        <img src="/img/benchmark-atomic-prop-6.png" alt="Benchmarking Atomic Properties in Swift - 6"/>
    </a>
</p>

Comparing to getters, `OperationQueue` falls behind `DispatchQueue` even more.

<p align="center">
    <a href="{{ "img/benchmark-atomic-prop-4.png" | absolute_url }}">
        <img src="/img/benchmark-atomic-prop-4.png" alt="Benchmarking Atomic Properties in Swift - 4"/>
    </a>
</p>

`DispatchQueue` is 3-4 times slower than locks, `OperationQueue` is ~70 times slower than the dispatch queue and 220-250 times slower than locks.

### Comparing Setters vs. Getters

<p align="center">
    <a href="{{ "img/benchmark-atomic-prop-7.png" | absolute_url }}">
        <img src="/img/benchmark-atomic-prop-7.png" alt="Benchmarking Atomic Properties in Swift - 7"/>
    </a>
</p>

---

<p align="center">
    <a href="{{ "img/benchmark-atomic-prop-8.png" | absolute_url }}">
        <img src="/img/benchmark-atomic-prop-8.png" alt="Benchmarking Atomic Properties in Swift - 8"/>
    </a>
</p>

---

<p align="center">
    <a href="{{ "img/benchmark-atomic-prop-9.png" | absolute_url }}">
        <img src="/img/benchmark-atomic-prop-9.png" alt="Benchmarking Atomic Properties in Swift - 9"/>
    </a>
</p>

---

<p align="center">
    <a href="{{ "img/benchmark-atomic-prop-10-cut.png" | absolute_url }}">
        <img src="/img/benchmark-atomic-prop-10.png" alt="Benchmarking Atomic Properties in Swift - 10"/>
    </a>
</p>

---

<p align="center">
    <a href="{{ "img/benchmark-atomic-prop-11.png" | absolute_url }}">
        <img src="/img/benchmark-atomic-prop-11.png" alt="Benchmarking Atomic Properties in Swift - 11"/>
    </a>
</p>

---

<p align="center">
    <a href="{{ "img/benchmark-atomic-prop-12.png" | absolute_url }}">
        <img src="/img/benchmark-atomic-prop-12.png" alt="Benchmarking Atomic Properties in Swift - 12"/>
    </a>
</p>

`DispatchQueue` and `OperationQueue` have considerable variance of setter vs. getter performance, locks are approximately equal.

### What to pick?

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---