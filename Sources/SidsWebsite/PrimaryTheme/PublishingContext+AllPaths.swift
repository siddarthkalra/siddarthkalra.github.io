//
//  PublishingContext+AllPaths.swift
//  
//
//  Created by Siddarth Kalra on 2021-01-04.
//

import Publish

extension PublishingContext {
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

