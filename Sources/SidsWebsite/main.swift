import Foundation
import Publish
import Plot
import SplashPublishPlugin
import MinifyCSSPublishPlugin
import Files

// This type acts as the configuration for your website.
struct SidsWebsite: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case articles
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://siddarthkalra.github.io")!
    var name = "An Unheralded Perspective"
    var description = "My thoughts on Swift, iOS development and beyond"
    var language: Language { .english }
    var imagePath: Path? { nil }
    var favicon: Favicon? { .init() }
}

private let plugins: [Plugin<SidsWebsite>] = [.splash(withClassPrefix: "splash-")]
private let rssFeedConfig: RSSFeedConfiguration = .default
private let theme: Theme<SidsWebsite> = .primary
private let indentation: Indentation.Kind? = nil
private let deploymentMethod: DeploymentMethod<SidsWebsite> = .gitHub("siddarthkalra/siddarthkalra.github.io", useSSH: true)
private let rssFeedSections: Set<SidsWebsite.SectionID> = Set(SidsWebsite.SectionID.allCases)

try SidsWebsite().publish(using: [
    .group(plugins.map(PublishingStep.installPlugin)),
    .optional(.copyResources()),
    .installPlugin(.minifyCSS(in: "primaryTheme")),
    .combineCSS(in: "primaryTheme"),
    .addMarkdownFiles(),
    .sortItems(by: \.date, order: .descending),
    .generateHTML(withTheme: theme, indentation: indentation),
    .move404FileForGitHubPages(),
    .unwrap(rssFeedConfig) { config in
        .generateRSSFeed(
            including: rssFeedSections,
            config: config
        )
    },
    .generateSiteMap(indentedBy: indentation),
    .unwrap(deploymentMethod, PublishingStep.deploy)
])

extension PublishingStep {
    static func combineCSS(in cssFolderPath: Path) -> Self {
        step(named: "Combine CSS Files in '\(cssFolderPath)'") { context in
            let cssFolder = try context.outputFolder(at: cssFolderPath)
            let combinedCSSFile = try context.createOutputFile(at: cssFolderPath.appendingComponent("styles.min.css"))

            let existingCSSFiles = cssFolder.files.recursive.filter { file in
                file.path != combinedCSSFile.path && file.extension == "css"
            }

            try existingCSSFiles.forEach { file in
                try combinedCSSFile.append(file.read())
            }

            try existingCSSFiles.forEach { file in
                try file.delete()
            }
        }
    }

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
