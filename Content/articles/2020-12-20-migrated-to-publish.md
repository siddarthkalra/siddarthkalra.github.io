---
layout: post
title: Migrated to Publish
date: 2020-12-20 00:00
description: Documenting learnings and future enhancements after migrating this website to Publish, a static site generator by John Sundell written in Swift!
tags: article, static site generator, swift
---

# Migrated to Publish

Today, I'm so glad to share that this website has been migrated to [Publish](https://github.com/JohnSundell/Publish), a static site generator by John Sundell written in Swift! 🎉 

I love working in [Swift](https://swift.org/) so this was a no-brainer for me and for many others it seems. This website is hosted on [GitHub Pages](https://pages.github.com/) and previously you were almost forced to adopt something like [Jekyll](https://jekyllrb.com/), a static site generator written in Ruby. Well, those days are over! I want to take this opportunity to document some learnings and future enhancements.

## Getting setup

So how easy was it to migrate this incredibly small website to Publish?

If you have previous Swift knowledge, this will be a breeze to setup. John Sundell really deserves a ton of credit here for designing such a simple yet extensible API.

So lets go through the minimum amount of steps you need to complete in order to generate your fancy new website.

### 1. Define your fancy new website

This is done by conforming to the `Website` protocol.

```swift
struct FancyNewSite: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
        case about
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://fancynewsite.github.io")!
    var name = "A Fancy New Site"
    var description = "Let's get fancy, shall we?"
    var language: Language { .english }
    var imagePath: Path? { nil }
}
```

### 2. Create a fancy theme

This is how your website's HTML and CSS will be generated.

```swift
extension Theme where Site == FancyNewSite {
    static var fancyTheme Self {
        Theme(htmlFactory: FancyHTMLFactory(), resourcePaths: ["Resources/fancyTheme/styles.css"])
    }
}
```

`FancyHTMLFactory` conforms to the `HTMLFactory` protocol. This is the type that will generate your website's HTML. Implement all the required methods and your site will be up and running in no time. Publish includes a default `foundation` theme that you can use as a reference.

### 3. Define your fancy publishing pipeline

There's two ways you can go here. We can get all fancy (pun intended) and use a custom pipeline or go with the default one that is provided out-of-the-box. I went with the default one for now since that has the advantage of being much quicker to setup.

```swift
// a default pipeline that generates your fancy site and deploys it to GitHub Pages
try FancyNewSite().publish(withTheme: .fancyTheme,
                          deployedUsing: .gitHub("fancyNewSite/fancynewsite.github.io", useSSH: true))
```

### 4. Run locally then deploy

Publish comes with a command line tool which provides the ability to run your website locally. Just execute the following in your terminal: `publish run -p 8000`.

Once you've iterated on your website locally it's time to share your hard work with the outside world. Again this is extremely simple - just run `publish deploy`.

That's it! You now have the excuse to get all fancy! 😅

![Fancy GIF](https://media.giphy.com/media/c0BgDP4p4gO8E/giphy.gif)

## Issues encountered

Alright putting all the fanciness aside, let's talk about some of the issues I encountered along the way.

### Local HTTP server blocks ports

Every now and again the HTTP server can develop a glitch and stop working. You'll get a message indicating the port you're trying to use is already taken. Not sure how this ends up happening but it can get a bit annoying as you're forced to choose a different port each time. Since the server used by Publish is written in Python, I tried killing any Python process that was running on my machine but unfortunately that didn't remedy the problem.

However, really the problem was just with my original workflow. Every time I would regenerate my site, I would just restart the server thus increasing the likelihood of running into this problem. A better approach is to keep the HTTP server running and just use another shell to execute `publish generate` to regenerate your website without having to constantly restart your server.

### Swift Package Manager

Publish is just a [Swift package](https://swift.org/package-manager/) and so is the website project that gets generated after you run `publish new`. I have experience with other dependency managers like [Carthage](https://github.com/Carthage/Carthage), [CocoaPods](https://cocoapods.org/) and even [NPM](https://www.npmjs.com/) but I'm pretty new to Swift Package Manager (SPM).

In order to add Swift syntax highlighting to my posts, I decided to adopt Sundell's [Publish plugin for Splash](https://github.com/JohnSundell/SplashPublishPlugin). However, adding `SplashPublishPlugin` as a dependency in my website's Package.swift, broke my build. I couldn't generate my website anymore as Xcode would no longer detect that my website had any active targets.

![I'm stuck GIF](https://media.giphy.com/media/3oKIPsU8OC7JhkvY8U/giphy.gif)

I was stumped. I had no idea how Xcode got into this state. So, I went for a swim in the world of SPM by reading Apple's [official docs](https://swift.org/package-manager/) and even Sundell's [article](https://www.swiftbysundell.com/articles/managing-dependencies-using-the-swift-package-manager/) on the subject. An hour went by but I couldn't solve the problem.

My intuition indicated that I somehow needed to reset my build and throw out any existing build artifacts to have a "fresh start". I just didn't know how though. Ultimately, spending a bit of time snooping around Xcode revealed the solution.

```no-highlight
File ˃ Swift Packages ˃ Reset Package Caches
```

This forces Xcode to regenerate your entire package dependency chain. Once I chose this option all my problems were solved and I could generate my website once again. I was back on track.

### Section vs. Page

`Section` essentially models a directory with a rigid hierarchy. `Item` models each page within this directory and a given `Section` can contain many items.

`Page`, on the other hand, models a standalone HTML page and doesn't hold any pre-conceived notions around directory hierarchy.

Use `Section` when you want to group a set of pages together. If something is standalone then use `Page` instead.

### WebsiteItemMetadata

`WebsiteItemMetadata` is a protocol that basically gives you the ability to include custom metadata for each `Item` defined by your website. Publish takes advantage of Swift's type system and allows us to work with a strongly typed struct instead of using something like a dictionary, which cannot provide the same compile-time guarantees.

Let's go through an example to solidify our understanding. Say I want to add a timestamp that indicates the last time each post on my website was edited. Posts on my website are embedded within a `Section` called `posts` and thus each post is an `Item`.

All I have to do now is to add the following to my metadata struct:

```swift
struct ItemMetadata: WebsiteItemMetadata {
    var lastEdited: Date
}
```

Now I can go through each one of my posts written in markdown and add this information within the --- lines at the top.

```no-highlight
---
lastEdited: 2020-10-21 16:49
---
```

Lastly, I can simply access this new property in Swift via `item.lastEdited`. If somehow you don't update each post, Publish will throw an error when the site is regenerated:

```no-highlight
Fatal error: Error raised at top level: Publish encountered an error:
[step] Add Markdown files from 'Content' folder
[path] posts/fancy-new-post.md
[info] Missing metadata value for key 'lastEdited'
```

Consider a website with hundred of posts. It would be easy to make mistakes and miss updating a post here or there. This type of rigid enforcement at generation time prevents such mistakes and doesn't let you move forward with publishing until you fix them. I think that's incredibly useful.

### Diffing the generated HTML

The really nice part of Publish is that, if you commit your Output directory to Git, you can track exactly how your website's HTML has changed every time you regenerate it. This is a really nice way to catch regressions. The only issue is that the generated HTML is minified so understanding the diff becomes next to impossible.

If only there was a way to prevent this minification while you're developing? 🤔 Maybe there is but I haven't found it yet. I'll keep digging and report back if I find something!

### Deploying to GitHub Pages

GitHub pages expects the content of your website to be situated in the root directory of your repository. However, by default, Publish will situate your generated website in `Output/`. Brian Coyner's [article](https://briancoyner.github.io/articles/2020-02-25-cocoaheads_publish_notes/) on Publish came up with a great solution that I've adopted. The gist of the solution is as follows:

- Create a new branch called `author` or whatever suits your fancy
- Push this branch to remote and make this your base branch on GitHub so that all new PRs are opened against this branch by default
- `author` becomes your main branch where the code for your Publish website package lives
- `master` becomes your deployment branch which only holds the generated HTML & CSS for your website
- Instead of changing `master` directly, deploy new changes to `master` by using `publish deploy` (assuming that your publishing pipeline is already setup to deploy to GitHub)

## Future enhancements

Getting the initial version of my website up and running has been so much fun! However, there's at least a couple more things I have in mind that would really streamline my process:

- for every new post, add the ability to automatically cross-publish the post on Medium and submit a tweet
- add the ability to work on drafts without publishing them to the website before they're ready
- a custom 404 page
- support for multiple CSS files that get minified into one CSS file

As I make progress on these enhancements, I hope to share updates. Thank you to all that stuck around till the end. All feedback is welcome, so please don't hesitate to reach out to me on [Twitter](https://twitter.com/siddarthkalra). Now let's go build some websites! 🚀
