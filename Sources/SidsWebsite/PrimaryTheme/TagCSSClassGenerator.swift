//
//  TagCSSClassGenerator.swift
//  
//
//  Created by Siddarth Kalra on 2021-01-04.
//

import Publish

struct TagCSSClassGenerator {
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

