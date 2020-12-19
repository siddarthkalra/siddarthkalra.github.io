//
//  Theme+Primary.swift
//  
//
//  Created by Siddarth Kalra on 2020-12-14.
//

import Publish
import Plot
import Foundation

extension Theme where Site == SidsWebsite {
    static var primary: Self {
        Theme(htmlFactory: PrimaryHTMLFactory(), resourcePaths: ["Resources/PrimaryTheme/styles.css"])
    }
}

private struct PrimaryHTMLFactory<Site: Website>: HTMLFactory {
    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: index, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
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
            .head(for: section, on: context.site),
            .body(
                .header(for: context, selectedSection: section.id),
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
            .head(for: item, on: context.site),
            .body(
                .class("item-page"),
                .header(for: context, selectedSection: item.sectionID),
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
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(.contentBody(page.body)),
                .footer(for: context.site)
            )
        )
    }

    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
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
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
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
        selectedSection: T.SectionID?
    ) -> Node {
        let sectionIDs = T.SectionID.allCases

        return .header(
            .wrapper(
                .a(.class("site-name"), .href("/"), .text(context.site.name)),
                .if(sectionIDs.count > 1,
                    .nav(
                        .ul(.forEach(sectionIDs) { section in
                            .li(.a(
                                .class(section == selectedSection ? "selected" : ""),
                                .href(context.sections[section].path),
                                .text(context.sections[section].title)
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
        .ul(.class("tag-list"), .forEach(item.tags) { tag in
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
        let letters: [String] = ["a", "b", "c", "d", "e", "f", "e"]

        guard sortedTags.count == letters.count else {
            fatalError("Too many tags (\(sortedTags.count)), vs. CSS classes (\(letters.count)). Add more CSS classes")
        }

        var map: [Tag: String] = [:]
        for (i, tag) in sortedTags.enumerated() {
            let letter = letters[i]
            let baseTagCSSClass: String = "tag"
            map[tag] = "\(baseTagCSSClass) tag-\(letter)"
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
