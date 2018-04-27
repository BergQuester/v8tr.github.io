---
layout: post
title: Multicast Delegate in Swift
permalink: /multicast-delegate-swift/
share-img: "/img/core_data_in_swift_4_share_img.png"
---

Delegate is among the most commonly used patterns in iOS apps. Although one-to-one delegation might be suitable for the vast amount of cases, sometimes you need to 
delegate to more than one object and that is where the canonical pattern begins to falter. In the current article we'll take a look at how a one-to-many delegation can be implemented together with a real world examples.

### Explaining Delegate pattern



---

*I'd love to meet you in Twitter: [here](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you found it useful.*

---

[private-concurrency-type]: https://developer.apple.com/documentation/coredata/nsmanagedobjectcontextconcurrencytype/1506495-privatequeueconcurrencytype
[fetch-request-docs]: https://developer.apple.com/documentation/coredata/nsfetchrequest
[fetching-managed-objects-article]: https://developer.apple.com/library/content/documentation/DataManagement/Conceptual/CoreDataSnippets/Articles/fetching.html
[managed-object-context-docs]: https://developer.apple.com/documentation/coredata/nsmanagedobjectcontext
[sample-project]: https://github.com/V8tr/CoreData_in_Swift4_Article