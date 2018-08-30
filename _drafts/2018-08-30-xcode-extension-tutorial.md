---
layout: post
title: "Xcode Extension Tutorial: Getting Started"
permalink: /xcode-extension-tutorial/
share-img: "/img/massive_app_delegate_share.png"
---

Xcode is the core tool for Apple development. Although it is well-integrated with the most development workflows, from time to time you might feel like missing some basic features. In this article you will learn how to create Xcode Source Editor Extension that adds some extra functionality to Xcode.

As you are reading this article, you must be already familiar with Xcode IDE and even using it on daily basis. You must be generally happy with Xcode (except for the times it crashes), .....

### Explaining Xcode Source Editor Extensions

Extensions to the source editor in Xcode are capable of manipulating the contents of the selected file as well as the selected text within the editor. 

You create extensions with [XcodeKit](https://developer.apple.com/documentation/xcodekit). It lends itself to adding extra functionality and specialized behavior to the source editor. Most notable classes from `XcodeKit` are:

- `XCSourceEditorExtension` - the protocol that every Xcode Source Editor Extension must implement. You can think of it as `AppDelegate` from your iOS and MacOSX apps.
- `XCSourceEditorCommand` - the protocol that stands for the source editor command handler. You can think of it as a sink where one or more command invoications are handled. You must implement at least one of these in your extension.
- `XCSourceEditorCommandInvocation` - an instance of the command sent to your extension. It contains a buffer and an identifier. As already noted, multiple invocations can be handled by a single `XCSourceEditorCommand`.

The created commands will be accessible from Xcode Editor dropdown menu. By the end of this article, your command will look something like this:

<p align="center">
    <a href="{{ "img/xcode-extension-tutorial-editor-menu.png" | absolute_url }}">
        <img src="/img/xcode-extension-tutorial-editor-menu.png" width="400" alt="Xcode Extension Tutorial: Getting Started - Locating Command in Xcode Editor Menu"/>
    </a>
</p>

### Settings up Xcode Project

The extensions cannot exist on their own and must be wired to a macOS application. 

First off, we create a macOS project in Xcode named *LinesSorter*.

<p align="center">
    <a href="{{ "img/xcode-extension-tutorial-create-project.png" | absolute_url }}">
        <img src="/img/xcode-extension-tutorial-create-project.png" width="680" alt="Xcode Extension Tutorial: Getting Started - Creating New MacOS Project in Xcode"/>
    </a>
</p>

Now add *Xcode Source Editor Extension Target* to your newly created project. Let's call it *SourceEditorExtension*. Tap *Activate* when it prompts you "Activate “SourceEditorExtension” scheme".

<p align="center">
    <a href="{{ "img/xcode-extension-tutorial-create-extension-target.png" | absolute_url }}">
        <img src="/img/xcode-extension-tutorial-create-extension-target.png" width="680" alt="Xcode Extension Tutorial: Getting Started - Creating Xcode Source Editor Extension"/>
    </a>
</p>

At this point the targets must look like this:

<p align="center">
    <a href="{{ "img/xcode-extension-tutorial-targets-list.png" | absolute_url }}">
        <img src="/img/xcode-extension-tutorial-targets-list.png" width="400" alt="Xcode Extension Tutorial: Getting Started - Targets List"/>
    </a>
</p>

### Configuring Source Editor Command

All Xcode Source Editor Extension targets contain an extra entry in their *Info.plist* files named *NSExtension*. 

Lets find it in your your extension target's *Info.plist*. Unfold it to inspect all properties. The ones of particular interest are:

<p align="center">
    <a href="{{ "img/xcode-extension-tutorial-command-identifier.png" | absolute_url }}">
        <img src="/img/xcode-extension-tutorial-command-identifier.png" width="680" alt="Xcode Extension Tutorial: Getting Started - Editing Info.plist"/>
    </a>
</p>

- `XCSourceEditorCommandClassName` - name of your command class. You must implementing an instance of `XCSourceEditorCommand` with the exact same class name. Xcode has already created one for you inside the *SourceEditorExtension* target.
- `XCSourceEditorCommandIdentifier` - a command invocation identifier. Make sure you set it to something unique within your extension. 
- `XCSourceEditorCommandName` - name of the command as it will be displayed in the second level of Xcode Editor menu. Let's change it into *Sort Selected Lines*.

*Bundle display name* stands for your extension name in Editor menu. Let's change it into "Lines Sorter". There is no need to make any other edits as long as we have only one command.

Here is how extension name and command names are displayed in Editor menu:

<p align="center">
    <a href="{{ "img/xcode-extension-tutorial-editor-menu-explained.png" | absolute_url }}">
        <img src="/img/xcode-extension-tutorial-editor-menu-explained.png" width="480" alt="Xcode Extension Tutorial: Getting Started - Editor Menu Explained"/>
    </a>
</p>

### Implementing the Sorting Command

As you might have already guessed, our extension will sort selected lines of code. Sounds like an easy task? I bet it is. 

{: .box-note}
*I got so much carried away by writing this article that I ended up with [LinesSorter](https://github.com/V8tr/LinesSorter-Xcode-Extension) project and open sourced it recently. Make sure to check it out after reading this article.*

We already know that as soon as the command is activated from Xcode Editor menu, an invocation instance is sent to a handler class which is in our case `SourceEditorCommand`.

Open *SourceEditorCommand.swift* and paste the method there:

{% highlight swift linenos %}

func sort(_ inputLines: NSMutableArray, in range: CountableClosedRange<Int>, by comparator: (String, String) -> Bool) {
	guard range.upperBound < inputLines.count, range.lowerBound >= 0 else {
		return
	}

	let lines = inputLines.compactMap { $0 as? String }
	let sorted = Array(lines[range]).sorted(by: comparator)

	for lineIndex in range {
		inputLines[lineIndex] = sorted[lineIndex - range.lowerBound]
	}
}

{% endhighlight %}

Now we can sort selected lines by mutating `invocation.buffer.selections` that contants `NSMutableArray` of selected strings. All changes to the buffer will be reflected in Xcode source editor.

{% highlight swift linenos %}

func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
    defer { completionHandler(nil) }

    // At least something is selected
    guard let firstSelection = invocation.buffer.selections.firstObject as? XCSourceTextRange,
        let lastSelection = invocation.buffer.selections.lastObject as? XCSourceTextRange else {
            return
    }

    // One line is selected
    guard firstSelection.start.line < lastSelection.end.line else {
        return
    }

    sort(invocation.buffer.lines, in: firstSelection.start.line...lastSelection.end.line, by: <)
}

{% endhighlight %}

Few things going on here:
1. Do some sanity checks that at least two lines of code are selected within the editor.
2. Call `sort` method to perform the actual sorting, passing "<" operator as a comparator that will sort lines alphabetically.

In vast majority of cases we want to sort lines of code ignoring leading whitespaces, because they might have different indentation levels. Let's define a custom comparator that takes care of it.

{% highlight swift linenos %}

func isLessThanIgnoringLeadingWhitespacesAndTabs(_ lhs: String, _ rhs: String) -> Bool {
    return lhs.trimmingCharacters(in: .whitespaces) < rhs.trimmingCharacters(in: .whitespaces)
}

{% endhighlight %}

And now pass it to `sort` method:

```swift
sort(invocation.buffer.lines, in: firstSelection.start.line...lastSelection.end.line, by: isLessThanIgnoringLeadingWhitespacesAndTabs)
```

### Testing the Command

Finally let's see our work in action. Testing Xcode Source Editor Extensions is different from what you have used to when developing macOS and iOS apps.
1. First of all, both the app target and the source editor extension must be signed with your developer certificate. I will not dive too deply into details, but Apple got you covered with [this tutorial](https://help.apple.com/xcode/mac/current/#/dev60b6fbbc7).
2. Run *SourceEditorExtension* target and select Xcode app from the list. Source editor extensions launch in a separate instance of Xcode that can be distinguished by a the darker top bar.

<p align="center">
    <a href="{{ "img/xcode-extension-tutorial-run-extension.png" | absolute_url }}">
        <img src="/img/xcode-extension-tutorial-run-extension.png" width="400" alt="Xcode Extension Tutorial: Getting Started - Run Extension"/>
    </a>
</p>

Now trigger the Sort Lines command:

1. Select several lines of code.
2. Go to *Editor* > *Lines Sorter* > *Sort Selected Lines*.

Voila, your lines must be ordered alphabetically now.

Like any other editor command, you can assign a keys combination to yours. Go to *Xcode* > *Preferences* > *Key Bindings* > search for *"Lines Sorter"*.

<p align="center">
    <a href="{{ "img/xcode-extension-tutorial-key-binding.png" | absolute_url }}">
        <img src="/img/xcode-extension-tutorial-key-binding.png" width="680" alt="Xcode Extension Tutorial: Getting Started - Key Binding"/>
    </a>
</p>

### Summary

As you are reading this article, you must be already familiar with Xcode IDE and even using it on daily basis. 

In this article you have learned how you can push IDE to the limits by writing your own extension to the Xcode source editor.

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---