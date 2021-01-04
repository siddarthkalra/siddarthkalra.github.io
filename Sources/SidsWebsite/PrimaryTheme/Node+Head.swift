//
//  Node+Head.swift
//  
//
//  Created by Siddarth Kalra on 2021-01-04.
//

import Plot
import Publish

extension Node where Context == HTML.DocumentContext {
    /// Taken directly from https://github.com/JohnSundell/Publish/blob/master/Sources/Publish/API/PlotComponents.swift
    /// with minor adjustments
    static func head(
        for location: Location,
        on site: SidsWebsite,
        titleSeparator: String = " | ",
        stylesheetPaths: [Path],
        rssFeedPath: Path? = .defaultForRSSFeed,
        rssFeedTitle: String? = nil
    ) -> Node {
        var title = location.title

        if title.isEmpty {
            title = site.name
        } else {
            title.append(titleSeparator + site.name)
        }

        var description = location.description

        if description.isEmpty {
            description = site.description
        }

        return .head(
            .encoding(.utf8),
            .siteName(site.name),
            .url(site.url(for: location)),
            .title(title),
            .description(description),
            .twitterCardType(location.imagePath == nil ? .summary : .summaryLargeImage),
            .forEach(stylesheetPaths, { .stylesheet($0) }),
            .viewport(.accordingToDevice),
            .unwrap(site.favicon, { .favicon($0) }),
            .unwrap(rssFeedPath, { path in
                let title = rssFeedTitle ?? "Subscribe to \(site.name)"
                return .rssFeedLink(path.absoluteString, title: title)
            }),
            .unwrap(location.imagePath ?? site.imagePath, { path in
                let url = site.url(for: path)
                return .socialImageLink(url)
            }),
            .analyticsScript()
        )
    }
}
