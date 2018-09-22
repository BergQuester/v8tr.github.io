---
layout: post
title: "Xcode Source Editor Extension Tutorial: Getting Started"
permalink: /xcode-source-editor-extension-tutorial/
share-img: "/img/xcode-source-editor-extension-tutorial-share.png"
---

Xcode is the core tool for Apple development. Although it is well-integrated with the most development workflows, from time to time you might feel like missing some basic features. In this article you will learn how to create Xcode Source Editor Extension that adds some extra functionality to Xcode.

### Explaining Xcode Source Editor Extensions

You create extensions to the source editor by means of [XcodeKit](https://developer.apple.com/documentation/xcodekit) framework. Extensions have quite limited functionality. They can read and modify the contents of current source file, select and deselect text within that file.

Most notable classes from `XcodeKit` are:

- `XCSourceEditorExtension` - the protocol that every Xcode Source Editor Extension must implement. You can think of it as an `AppDelegate` from your iOS and macOS apps.
- `XCSourceEditorCommand` - the protocol that stands for the source editor command handler. You can think of it as a sink where one or more command invocations are handled. You must implement at least one of these in your extension.
- `XCSourceEditorCommandInvocation` - an instance of the command sent to your extension. It contains a buffer and an identifier. As already noted, multiple invocations can be handled by a single `XCSourceEditorCommand`.
- `XCSourceTextBuffer` - a buffer used to manipulate the text contents and selections in a source editor.

Extension's commands are accessible from Xcode Editor dropdown menu. By the end of this article, your command will look something like this:

<p align="center">
    <a href="{{ "img/xcode-source-editor-extension-tutorial-editor-menu.png" | absolute_url }}">
        <img src="/img/xcode-source-editor-extension-tutorial-editor-menu.png" width="400" alt="Xcode Extension Tutorial: Getting Started - Locating Command in Xcode Editor Menu"/>
    </a>
</p>

### Creating Xcode Project

The extensions cannot exist on their own and must be wired up to a macOS application. 

First off, we create a macOS project in Xcode named *LinesSorter*.

<p align="center">
    <a href="{{ "img/xcode-source-editor-extension-tutorial-create-project.png" | absolute_url }}">
        <img src="/img/xcode-source-editor-extension-tutorial-create-project.png" width="680" alt="Xcode Extension Tutorial: Getting Started - Creating New MacOS Project in Xcode"/>
    </a>
</p>

Now add *Xcode Source Editor Extension Target* to your newly created project. Let's call it *SourceEditorExtension*. Tap *Activate* when it prompts you *Activate "SourceEditorExtension" scheme*.

<p align="center">
    <a href="{{ "img/xcode-source-editor-extension-tutorial-create-extension-target.png" | absolute_url }}">
        <img src="/img/xcode-source-editor-extension-tutorial-create-extension-target.png" width="680" alt="Xcode Extension Tutorial: Getting Started - Creating Xcode Source Editor Extension"/>
    </a>
</p>

At this point the targets must look like this:

<p align="center">
    <a href="{{ "img/xcode-source-editor-extension-tutorial-targets-list.png" | absolute_url }}">
        <img src="/img/xcode-source-editor-extension-tutorial-targets-list.png" width="400" alt="Xcode Extension Tutorial: Getting Started - Targets List"/>
    </a>
</p>

### Configuring Source Editor Command

All editor extension targets contain an extra entry in their *Info.plist* files named *NSExtension*. Lets unfold it and inspect inner properties. 

<p align="center">
    <a href="{{ "img/xcode-source-editor-extension-tutorial-command-identifier.png" | absolute_url }}">
        <img src="/img/xcode-source-editor-extension-tutorial-command-identifier.png" width="680" alt="Xcode Extension Tutorial: Getting Started - Editing Info.plist"/>
    </a>
</p>

The ones of particular interest are:

- `XCSourceEditorCommandClassName` - a name of the command class. Xcode has already created one for you. 
- `XCSourceEditorCommandIdentifier` - a command invocation identifier. Make sure to set it to something unique within your extension. 
- `XCSourceEditorCommandName` - a command name as it will be displayed in the second level of Xcode Editor menu. Let's change it into *Sort Selected Lines*.

*Bundle display name* stands for your extension name in Editor menu. Let's change it into *'Lines Sorter'*. There is no need to make any other edits as long as we have only one command.

Here is how extension name and command names are displayed in Editor menu:

<p align="center">
    <a href="{{ "img/xcode-source-editor-extension-tutorial-editor-menu-explained.png" | absolute_url }}">
        <img src="/img/xcode-source-editor-extension-tutorial-editor-menu-explained.png" width="480" alt="Xcode Extension Tutorial: Getting Started - Editor Menu Explained"/>
    </a>
</p>

### Implementing the Sorting Command

As you might have already guessed, our extension will sort selected lines of code. Sounds like an easy task? It sure is after you learned how *XcodeKit* works and did lots of preparation work.

{: .box-note}
*I got so much carried away by writing this article that I ended up with [LinesSorter][lines-sorter-repo] extension and open sourced it recently. Make sure to check it out after reading this article.*

We already know that as soon as the command is activated from Xcode Editor menu, an invocation instance is sent to a the command class.

Open `SourceEditorCommand.swift` and paste the method there:

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

Now we can sort selected lines by mutating `invocation.buffer.selections` which is an `NSMutableArray` of strings. All changes to the buffer will be reflected in Xcode source editor.

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
2. Call `sort` method to perform the actual sorting by mutating the input `NSMutableArray` in place. We pass `<` operator to sort alphabetically.

Lines of codes tend to have different indentation levels that affects their sorting. We usually don't want to take indentation into account as we sort. Let's define a custom comparator that takes care of it.

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
1. First of all, both the app target and the source editor extension must be signed with your developer certificate. I will not dive too deeply into details, but Apple got you covered with [this tutorial](https://help.apple.com/xcode/mac/current/#/dev60b6fbbc7).
2. Run *SourceEditorExtension* target and select Xcode app from the list. Source editor extensions launch in a separate instance of Xcode that can be distinguished by a the darker top bar.

<p align="center">
    <a href="{{ "img/xcode-source-editor-extension-tutorial-run-extension.png" | absolute_url }}">
        <img src="/img/xcode-source-editor-extension-tutorial-run-extension.png" width="400" alt="Xcode Extension Tutorial: Getting Started - Run Extension"/>
    </a>
</p>

Now trigger the Sort Lines command:

1. Select several lines of code.
2. Go to *Editor* > *Lines Sorter* > *Sort Selected Lines*.

Voila, your lines must be ordered alphabetically now.

Like any other editor command, you can assign a keys combination to yours. Go to *Xcode* > *Preferences* > *Key Bindings* > search for *"Lines Sorter"*.

<p align="center">
    <a href="{{ "img/xcode-source-editor-extension-tutorial-key-binding.png" | absolute_url }}">
        <img src="/img/xcode-source-editor-extension-tutorial-key-binding.png" width="680" alt="Xcode Extension Tutorial: Getting Started - Key Binding"/>
    </a>
</p>

### Summary

In this article we learned how you can push Xcode IDE to the next limits by writing your own extension.

Source editor extensions are quite limited in their functionality and are capable of editing and selecting lines of code within a single file.

Creating Xcode Source Editor Extension might seem daunting at first glance. After learning `XcodeKit`, the process of setting up an Xcode project and testing the extension it does not appear as such.

Check out [LinesSorter][lines-sorter-repo] that is an extended version of the project we created during this article. It also shows how to setup Unit tests and Continuous Integration for Xcode Source Editor Extension project.

---

*I'd love to meet you in Twitter: [@V8tr](https://twitter.com/{{ site.author.twitter }}). And don't forget to share this article if you find it useful.*

---

[lines-sorter-repo]: https://github.com/V8tr/LinesSorter-Xcode-Extension