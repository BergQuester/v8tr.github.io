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

Locking APIs under test:
- `NSLock`
- `pthread_mutex_t`
- `pthread_rwlock_t`
- `os_unfair_lock_s`
- `DispatchQueue`
- `OperationQueue`

Test project created for this article: [https://github.com/V8tr/AtomicBenchmark](https://github.com/V8tr/AtomicBenchmark). It benchmarks atomic properties created with the above APIs and exports it to a CSV file. 

### Tools

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---