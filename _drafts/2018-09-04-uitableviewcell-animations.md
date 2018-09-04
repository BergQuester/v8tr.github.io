---
layout: post
title: "Loading animation of UITableViewCell: Practical Recipes"
permalink: /uitableviewcell-load-animation/
share-img: "/img/xcode-source-editor-extension-tutorial-share.png"
---

In this article you will learn how to implement custom loading animations for UITableViewCell by means of UIKit framework.

### Problem Statement

Animations are among the key factors that distinguish between the ordinary and outstanding user experience. Taking into account that table views are so widely used in iOS apps, developing eye-catching table view cells appearance animations can significantly improve user experience of your app.

Actually `UITableView` is so widely adopted that I am 99% sure you are using at least one in your current app. Let's not miss the opportunity to make table views less boring and way more visually appealing by writing a few lines code that animates `UITableViewCell` during their appearance.

### Getting Started

First off, grab [this starter project][starter-repo] to save some time on writing the boilerplate code. It contains a `UITableViewController` with static content:

<p align="center">
    <a href="{{ "/img/uitableviewcell-load-animation/starter.png" | absolute_url }}">
        <img src="/img/uitableviewcell-load-animation/starter.png" width="400" alt="Loading animation of UITableViewCell: Practical Recipes - Starter Project"/>
    </a>
</p>

When you open `TableViewController.swift`, you find several stubs needed for our further work:

{% highlight swift linenos %}

	@IBAction func onRefresh(_ sender: UIBarButtonItem) {
		// Refresh table view here
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		// Add animations here
	}

{% endhighlight %}

The `onRefresh` method handles taps on right navigation bar button. Later on we'll add the code that triggers animations, but for now let's leave it intact.

All the action will happen in `tableView(_:,willDisplay:,forRowAt:)`. Let's add some simples animation to see it working.

### Implementing Simple Animation

Let's begin with a simple fade animation. `UIView` has a [family of methods](https://developer.apple.com/documentation/uikit/uiview/1622418-animate) that animates changes to a view withing a specified duration. That's exactly what we will use to animate table view cell.

Add the code below to `tableView(_:,willDisplay:,forRowAt:)`:

{% highlight swift linenos %}

cell.alpha = 0

UIView.animate(
    withDuration: 0.5,
    delay: 0.05 * Double(indexPath.row),
    animations: {
        cell.alpha = 1
})

{% endhighlight %}

That produces the effect like this:

<p align="center">
    <a href="{{ "/img/uitableviewcell-load-animation/simple-animation.gif" | absolute_url }}">
        <img src="/img/uitableviewcell-load-animation/simple-animation.gif" alt="Loading animation of UITableViewCell: Practical Recipes - Simple Animation"/>
    </a>
</p>

Not bad for 8 lines of code, isn't it?

### Preparing for More Complex Animations

Although the above animations already looks good, let's take it to the next level and product something more complex.

We will utilize `transform` property of `UITableViewCell` that applies 2D transformations to the cell, such as rotate, scale, move, or skew.

As we go, we come up with different animations and it is difficult to judge immediately which one fits the project best. We need to come up with a reusable solution that allows to tweak and replace animations easily. To do so, let's define `Animation` that is essentially a closure that accepts several parameters:

{% highlight swift linenos %}

typealias Animation = (UITableViewCell, IndexPath, UITableView) -> Void

{% endhighlight %}

`Animator` is a utility class that runs animation it is initialized with. It also ensures that the animation is not run more than once for all visible cells.

{: .box-note}
*Experiment with `Animator` class and remove the usage of `hasAnimatedAllCells` property to see how the scroll behavior has changed.*

{% highlight swift linenos %}

final class Animator {
	private var hasAnimatedAllCells = false
	private let animation: Animation

	init(animation: @escaping Animation) {
		self.animation = animation
	}

	func animate(cell: UITableViewCell, at indexPath: IndexPath, in tableView: UITableView) {
		guard !hasAnimatedAllCells else {
			return
		}

		animation(cell, indexPath, tableView)

		hasAnimatedAllCells = tableView.isLastVisibleCell(at: indexPath)
	}
}

{% endhighlight %}

Now we want to be as flexible as possible with our animations to tweak and replace them easy. For this purpose let's define `AnimationFactory` and make it return the fade animation that we have already implemented:

{% highlight swift linenos %}

enum AnimationFactory {

	static func makeFadeAnimation(duration: TimeInterval, delayFactor: Double) -> Animation {
		return { cell, indexPath, _ in
			cell.alpha = 0

			UIView.animate(
				withDuration: duration,
				delay: delayFactor * Double(indexPath.row),
				animations: {
					cell.alpha = 1
			})
		}
	}
}

{% endhighlight %}

Replace old animation code in `TableViewController.swift` with the new fancy one:

{% highlight swift linenos %}

override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
	let animation = AnimationFactory.makeFadeAnimation(duration: 0.5, delayFactor: 0.05)
	let animator = Animator(animation: animation)
	animator.animate(cell: cell, at: indexPath, in: tableView)
}

{% endhighlight %}

Run the project to verify that everything is working as expected.

Finally, you are ready to write more cool animation stuff.

### Bounce Animation

`UIKit` is powerful enough to let you define bounce animation by means of single animate method. For this animation we define new factory method:

{% highlight swift linenos %}

static func makeMoveUpWithBounce(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
    return { cell, indexPath, tableView in
        cell.transform = CGAffineTransform(translationX: 0, y: rowHeight)

        UIView.animate(
            withDuration: duration,
            delay: delayFactor * Double(indexPath.row),
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.1,
            options: [.curveEaseInOut],
            animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
}

{% endhighlight %}

* `dampingRatio` - essentially a bouncing power. Use value of 1 for no bouncing at all and values closer to 0 to increase oscillation.
* `velocity` - spring velocity. Value of 1 corresponds to the total animation distance travelled within a second.
* `options` - options for animating views.

I came up with these values by tweaking the animation to my taste.

{: .box-note}
*Tip: try passing different [options](https://developer.apple.com/documentation/uikit/uiview/animationoptions) to see how they affect cells animation.*

Update code inside table view controller to use bouncing animation as we did before.

{% highlight swift linenos %}

let animation = AnimationFactory.makeMoveUpWithBounce(rowHeight: cell.frame.height, duration: 1.0, delayFactor: 0.05)
let animator = Animator(animation: animation)
animator.animate(cell: cell, at: indexPath, in: tableView)

{% endhighlight %}

The animation produces the effect like this:

<p align="center">
    <a href="{{ "/img/uitableviewcell-load-animation/bounce-animation.gif" | absolute_url }}">
        <img src="/img/uitableviewcell-load-animation/bounce-animation.gif" alt="Loading animation of UITableViewCell: Practical Recipes - Bounce Animation"/>
    </a>
</p>

### Move and Fade Animation

Move and fade animation changes both `transform` and `alpha` values of a cell.

{% highlight swift linenos %}

static func makeMoveUpWithFade(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
    return { cell, indexPath, _ in
        cell.transform = CGAffineTransform(translationX: 0, y: rowHeight / 2)
        cell.alpha = 0

        UIView.animate(
            withDuration: duration,
            delay: delayFactor * Double(indexPath.row),
            options: [.curveEaseInOut],
            animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
        })
    }
}

{% endhighlight %}

Adapt the code in table view controller as we did twice before and run the app. It must look like this:

<p align="center">
    <a href="{{ "/img/uitableviewcell-load-animation/move-and-fade-animation.gif" | absolute_url }}">
        <img src="/img/uitableviewcell-load-animation/move-and-fade-animation.gif" alt="Loading animation of UITableViewCell: Practical Recipes - Move and Fade Animation"/>
    </a>
</p>

### Slide in Animation

I bet you have already gotten a knack of writing the animations and started appreciating the way they can be easily be replaced and configured.

Slide in animation does what its name suggests: it moves cells from right edge of the screen to their positions in a table. 

{% highlight swift linenos %}

static func makeSlideIn(rowHeight: CGFloat, duration: TimeInterval, delayFactor: Double) -> Animation {
    return { cell, indexPath, tableView in
        cell.transform = CGAffineTransform(translationX: tableView.bounds.width, y: 0)

        UIView.animate(
            withDuration: duration,
            delay: delayFactor * Double(indexPath.row),
            options: [.curveEaseInOut],
            animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
}

{% endhighlight %}

It produces next visual effect:

<p align="center">
    <a href="{{ "/img/uitableviewcell-load-animation/slide-in-animation.gif" | absolute_url }}">
        <img src="/img/uitableviewcell-load-animation/slide-in-animation.gif" alt="Loading animation of UITableViewCell: Practical Recipes - Slide in Animation"/>
    </a>
</p>


### Source Code

You can grab [final project here][final-repo].

And there is [starter project here][starter-repo].

### Summary

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---

[starter-repo]: https://github.com/V8tr/UITableViewCellAnimation-Article-Starter
[final-repo]: https://github.com/V8tr/UITableViewCellAnimation-Article-Starter
[lines-sorter-repo]: https://github.com/V8tr/LinesSorter-Xcode-Extension