---
layout: post
title: Refactoring Massive App Delegate
permalink: /refactoring-massive-app-delegate/
share-img: "/img/benchmarking-locking-apis-share.png"
---

Topics:


According to Apple, App Delegate is capable of doing following actions: https://developer.apple.com/documentation/uikit/uiapplicationdelegate.

By investigating a dozen of open-source iOS apps I collected a list of what App Delegate usually does, besides the above list https://github.com/dkhamsing/open-source-ios-apps. I am sure it will sound very familiar to you.

Besides that, App Delegate usually does: 
- Initializes Core Data Stack
- Manages Core Data migrations
- Initializes 3rd parties
- handles Home scree quick actions
- handles custom actions from notifications
- configures UIApperance
- Handles local and push notifications
- Observes notifications from app
- Manages network session
- Handles background tasks
- Performs business logic to select initial view controller
- Creates UI stack
- Performes root view controller changes and animations
- Saves / loads data from UserDefaults or CoreData
- Plays audio
- 

https://github.com/peter-iakovlev/Telegram/blob/public/Telegraph/TGAppDelegate.mm

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---