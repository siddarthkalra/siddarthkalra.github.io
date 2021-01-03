//
//  Theme+Primary.swift
//  
//
//  Created by Siddarth Kalra on 2020-12-14.
//

import Publish
import Plot
import Foundation

private let stylesheetPaths: [Path] = ["/primaryTheme/styles.min.css"]

extension Theme where Site == SidsWebsite {
    static var primary: Self {
        Theme(htmlFactory: PrimaryHTMLFactory(), resourcePaths: [])
    }
}

private extension Index {
    func emptyingTitle() -> Self {
        var mutatableIndex = self
        mutatableIndex.title = ""
        return mutatableIndex
    }
}

private struct PrimaryHTMLFactory: HTMLFactory {
    typealias Site = SidsWebsite

    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            // empty Index.title so that only the website's name is shown as the tab's title
            .head(for: index.emptyingTitle(), on: context.site, stylesheetPaths: stylesheetPaths),
            .body(
                .header(for: context, selectedPath: nil),
                .wrapper(
                    .itemList(
                        for: context.allItems(
                            sortedBy: \.date,
                            order: .descending
                        ),
                        context: context
                    )
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site, stylesheetPaths: stylesheetPaths),
            .body(
                .header(for: context, selectedPath: section.path),
                .wrapper(
                    .h1(.text(section.title)),
                    .itemList(for: section.items, context: context)
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site, stylesheetPaths: stylesheetPaths),
            .body(
                .class("item-page"),
                .header(for: context, selectedPath: item.path),
                .wrapper(
                    .article(
                        .div(
                            .class("content"),
                            .contentBody(item.body)
                        ),
                        .span("Tags: "),
                        .tagList(for: item, context: context)
                    )
                ),
                .footer(for: context.site)
            )
        )
    }

    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site, stylesheetPaths: stylesheetPaths),
            .body(
                .header(for: context, selectedPath: page.path),
                .wrapper(.contentBody(page.body)),
                .footer(for: context.site)
            )
        )
    }

    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site, stylesheetPaths: stylesheetPaths),
            .body(
                .header(for: context, selectedPath: page.path),
                .wrapper(
                    .h1("Browse all tags"),
                    .ul(
                        .class("all-tags"),
                        .forEach(page.tags.sorted()) { tag in
                            .li(
                                .class(TagCSSClassGenerator.cssClassForTag(tag, context: context)),
                                .a(
                                    .href(context.site.path(for: tag)),
                                    .text(tag.string)
                                )
                            )
                        }
                    )
                ),
                .footer(for: context.site)
            )
        )
    }

    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site, stylesheetPaths: stylesheetPaths),
            .body(
                .header(for: context, selectedPath: page.path),
                .wrapper(
                    .h1(
                        "Tagged with ",
                        .span(.class(TagCSSClassGenerator.cssClassForTag(page.tag, context: context)), .text(page.tag.string))
                    ),
                    .a(
                        .class("browse-all"),
                        .text("Browse all tags"),
                        .href(context.site.tagListPath)
                    ),
                    .itemList(
                        for: context.items(
                            taggedWith: page.tag,
                            sortedBy: \.date,
                            order: .descending
                        ),
                        context: context
                    )
                ),
                .footer(for: context.site)
            )
        )
    }
}

private extension Node where Context == HTML.BodyContext {
    static func wrapper(_ nodes: Node...) -> Node {
        .div(.class("wrapper"), .group(nodes))
    }

    static func header<T: Website>(
        for context: PublishingContext<T>,
        selectedPath: Path?
    ) -> Node {
        let allPaths = context.allPaths.filter { $0.0 != "404" }

        return .header(
            .wrapper(
                .a(.class("site-name"), .href("/"), .text(context.site.name)),
                .if(allPaths.count > 1,
                    .nav(
                        .ul(.forEach(allPaths) { path, title in
                            .li(.a(
                                .class(path == selectedPath ? "selected" : ""),
                                .href(path),
                                .text(title)
                            ))
                        })
                    )
                )
            )
        )
    }

    static func itemList<T: Website>(for items: [Item<T>], context: PublishingContext<T>) -> Node {
        return .ul(
            .class("item-list"),
            .forEach(items) { item in
                .li(.article(
                    .h1(.a(
                        .href(item.path),
                        .text(item.title)
                    )),
                    .tagList(for: item, context: context),
                    .p(.text(item.description)),
                    .p(.class("publish-date"), .text(dateFormatter.string(from: item.date)))
                ))
            }
        )
    }

    static func tagList<T: Website>(for item: Item<T>, context: PublishingContext<T>) -> Node {
        .ul(.class("tag-list"), .forEach(item.tags.sorted()) { tag in
            .li(.class(TagCSSClassGenerator.cssClassForTag(tag, context: context)),
                .a(
                    .href(context.site.path(for: tag)),
                    .text(tag.string)
                )
            )
        })
    }

    static func footer<T: Website>(for site: T) -> Node {
        return .footer(
            .p(
                .text("\(site.name) \u{00A9} 2020 \u{22C5} All rights reserved")
            ),
            .p(
                .text("Built in Swift using "),
                .a(
                    .text("Publish"),
                    .href("https://github.com/johnsundell/publish"),
                    .target(.blank)
                )
            ),
            .p(
                .a(
                    .text("Twitter"),
                    .href("https://twitter.com/siddarthkalra"),
                    .target(.blank)
                ),
                .text(" | "),
                .a(
                    .text("RSS"),
                    .href("/feed.rss"),
                    .target(.blank)
                )
            )
        )
    }
}

private extension PublishingContext {
    typealias PathTitle = String
    var allPaths: [(Path, PathTitle)] {
        let allSections = sections.reduce(into: [Path: String]()) { result, section in
            result[section.path] = section.title
        }

        return pages.reduce(into: allSections) { result, pages in
            result[pages.value.path] = pages.value.title
        }.sorted { $0.value < $1.value }
    }
}


private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    return df
}()

private struct TagCSSClassGenerator {
    private typealias TagToCSSClassMap = [Tag: String]
    private static var tagsToCSSMap: TagToCSSClassMap = [:]

    private static func makeTagsToCSSMap<T: Website>(context: PublishingContext<T>) -> TagToCSSClassMap {
        let sortedTags = context.allTags.sorted()
        let letters: [String] = ["a", "b", "c", "d", "e", "f", "g", "h"]

        var map: [Tag: String] = [:]
        var letterIdx = 0
        for tag in sortedTags {
            if letterIdx == letters.count {
                letterIdx = 0
            }

            let letter = letters[letterIdx]
            let baseTagCSSClass: String = "tag"
            map[tag] = "\(baseTagCSSClass) tag-\(letter)"

            letterIdx += 1
        }

        return map
    }

    static func cssClassForTag<T: Website>(_ tag: Tag, context: PublishingContext<T>) -> String {
        if tagsToCSSMap.isEmpty {
            tagsToCSSMap = makeTagsToCSSMap(context: context)
        }

        guard let cssClass = tagsToCSSMap[tag] else {
            fatalError("Unable to get CSS class for tag: \(tag)")
        }

        return cssClass
    }
}
