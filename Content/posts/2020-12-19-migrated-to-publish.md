---
layout: post
title: Migrating to Publish
date: 2020-12-19 10:45
description: TBD
tags: sundell publish, swift
---

Today I'm so glad to announce that this website has been migrated to John Sundell's Publish static site generator 🎉

I don't know the numbers but I'm almost giddy to join the growing number of static websites that are moving away from Ruby based static site generators. I want to take this opportunity to document some learnings and future enhancements.

# Getting setup

I love working in Swift so this was a no-brainer for me. This website is hosted on GitHub Pages and previously you were almost forced to use Ruby based static site generators. Well, those days are over! So how easy was it to migrate this amazingly small website to Publish?

If you have previous Swift knowledge, this will be a breeze to setup. I want to give kudos to John Sundell for designing such a simple API that is also extensible at the same time (more on that in the next section).

Here are the minimum amount of steps you need to do complete in order to generate your fancy new website:

## Define your fancy new website

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

## Define a fancy theme

This is how your website's HTML and CSS will be generated.

```swift
extension Theme where Site == FancyNewSite {
    static var fancyTheme Self {
        Theme(htmlFactory: FancyHTMLFactory(), resourcePaths: ["Resources/fancyTheme/styles.css"])
    }
}
```

`FancyHTMLFactory` conforms to the `HTMLFactory` protocol. This is the type that will generate your website's HTML. Implement all the required methods and your site will be up and running in no time. Publish includes a default `foundation` theme that you can use as a reference.

## Define your fancy publishing pipeline

There's two ways you go here. We can get all fancy (pun intended) here and use a custom pipeline or go with the default one that is provided out-of-the-box. I went with the default one for now since that has the advantage of being much quicker to setup.

```swift
// a default pipeline that generates your fancy site and deploys it to GitHub Pages
try FancyNewSite().publish(withTheme: .fancyTheme,
                          deployedUsing: .gitHub("fancyNewSite/fancynewsite.github.io", useSSH: true)])
```

## Run locally then deploy

Publish comes with a command line tool which provides the ability to run your website locally. Just execute the following in your terminal: `publish run -p 8000`.

Once you've iterated on your website locally it's time to share your hard work with the outside world. This, again, is extremely simple. Just run `publish deploy`.

That's it! You now have the excuse to feel all fancy.

![Fancy GIF](https://media.giphy.com/media/c0BgDP4p4gO8E/giphy.gif)

# Issues encountered

OK putting all the fanciness aside, let's talk about some of the issues I encountered along the way.

## Local HTTP server blocks ports

Every now again the HTTP server can develop a glitch and stop working. You'll get a message indicating the port you're trying to use is already taken. Not sure how this ends up happening but it can get a bit annoying as you're forced to choose a different port. I tried killing any Python process that was running on my machine but unfortunately that didn't remedy the problem.

However, really this just ended up being a problem with my original workflow? Every time I would regenerate my site, I would just restart the server thus increasing the likelihood of running into this problem. A better approach is to keep the HTTP server running and just use another shell to execute `publish generate` to regenerate your website without having to restart your HTTP server every time.

## Swift Package Manager

Publish is just a Swift package and so is your website. I have experience with other dependency managers like Carthage, CocoaPods and even NPM but I'm pretty new to SPM myself.

In order to add Swift syntax highlighting to my posts, I decided to adopt John Sundell's Publish plugin for Splash. However, adding `SplashPublishPlugin` as a dependency in my website's Package.swift, broke my build. I couldn't generate my website anymore as Xcode would no longer detect that my website had any active targets.

POTENTIAL FOR GIF/MEME HERE

I was stumped. I had no idea how Xcode got into this state. So, I went for a swim in the world of SPM by reading Apple's docs and even Sundell's article on the subject. But I couldn't solve the problem. Ultimately, I just went snooping around Xcode and used some common sense. Somehow, I knew that I needed to reset my build and throw out any existing build artifacts and I found exactly what I was looking for:

`File ˃ Swift Packages ˃ Reset Package Caches`

This forces Xcode to regenerate your entire Package dependency chain. Once I chose this option all my problems were solved and I was back on track.

## Sections vs. Pages

## WebsiteItemMetadata

At first, I didn't quite understand the purpose of the `WebsiteItemMetadata` protocol.

## Diffing the output HTML

The really nice part of Publish is that, if you commit your Output directory to Git, you can track exactly how your website has changed every time you regenerate. This is a really nice way to catch regressions. The only issue is that the generated HTML is minified so understanding the diff becomes next to impossible.

If only there was a way to prevent this minification while your developing 🤔? Maybe there is but I haven't found it yet. I'll keep digging and report back if I find something!

## Deploying to GitHub Pages

GitHub pages expects the content of your website to be situated in the root directory of your repository. However, my default, Publish will situate your generated website in `Output/`. [Brian Coyner's article](https://briancoyner.github.io/articles/2020-02-25-cocoaheads_publish_notes/) on Publish came up with a great solution that I've adopted. The gist of the solution is as follows:

- Create a new branch called `author` or whatever suits your fancy
- Push this branch to remote and make this your main branch on GitHub so that all new PRs are opened against this branch by default
- `author` now becomes your main trunk branch where the code for your Publish website package lives
- `master` becomes your deployment branch which only holds your generated HTML & CSS for your website
- Deploy new changes to `master` by using `publish deploy` (assuming that your publishing pipeline is already setup to deploy to GitHub)

# Future enhancements

Getting the initial version of my website up and running has been so much fun! However, there's at least a couple more things I still want to do to really streamline my process:

- for every new post, add the ability to automatically post a tweet and cross-publish the on Medium
- add the ability to work on drafts without publishing them to the website before they're ready
- a custom 404 page

Once I have working solutions for the above, I hope to share my findings with you all. Thank you to all that stuck around till the end. That means a lot. All feedback is welcome, so please don't hesitate to reach out to me on [Twitter](https://twitter.com/siddarthkalra).
