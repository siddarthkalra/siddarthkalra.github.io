---
layout: post
title: Custom 404 page for GitHub Pages
date: 2020-12-26 00:00
description: Easily add a custom 404 page when using John Sundell's Publish + GitHub Pages by using a custom publishing step.
tags: article, static site generator, swift, quick tip
---

# Custom 404 Page for GitHub Pages

In my [previous article](/articles/2020-12-20-migrated-to-publish/) about migrating this website to John Sundell's [Publish framework](https://github.com/JohnSundell/Publish), I mentioned that one of the issues I faced was around how a custom 404 page produced by Publish does not work for websites hosted by [Github Pages](https://pages.github.com/).

A page called 404.md will be placed under the following URL when using the `.foldersAndIndexFiles` case of the `HTMLFileMode` enum defined in Publish:

```no-highlight
siddarthkalra.github.io/404/index.html
```

However, GitHub Pages expects:

```no-highlight
siddarthkalra.github.io/404.html
```

Now, one way to fix this problem would be to simply switch the file mode to `.standAloneFiles` , which I could have done. However, I didn't want to change the file hierarchy for my entire website just for this one case.

I fixed my problem by adding a new publishing step that renames 404/index.html to 404/404.html, copies 404.html to the output folder and deletes the 404 folder. Here's the code:

```swift
extension PublishingStep {
    static func move404FileForGitHubPages() -> Self {
        let stepName = "Move 404 file for GitHub Pages"

        return step(named: stepName) { context in
            guard let orig404Page = context.pages["404"] else {
                throw PublishingError(stepName: stepName,
                                      infoMessage: "Unable to find 404 page")
            }

            let orig404File = try context.outputFile(at: "\(orig404Page.path)/index.html")
            try orig404File.rename(to: "404")

            guard
                let orig404Folder = orig404File.parent,
                let outputFolder = orig404Folder.parent,
                let rootFolder = outputFolder.parent
            else {
                throw PublishingError(stepName: stepName,
                                      infoMessage: "Unable find root, output and 404 folders")
            }

            try context.copyFileToOutput(from: "\(orig404File.path(relativeTo: rootFolder))")
            try orig404Folder.delete()
        }
    }
}
```

Make sure to place this publishing step after the HTML generation step. To do so, you will need to adopt a custom publishing pipeline instead of the default one.