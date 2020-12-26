import Foundation
import Publish
import Plot
import SplashPublishPlugin

// This type acts as the configuration for your website.
struct SidsWebsite: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case articles
        case about
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
}

private let plugins: [Plugin<SidsWebsite>] = [.splash(withClassPrefix: "splash-")]
private let rssFeedConfig: RSSFeedConfiguration = .default
private let theme: Theme<SidsWebsite> = .primary
private let indentation: Indentation.Kind? = nil
private let deploymentMethod: DeploymentMethod<SidsWebsite> = .gitHub("siddarthkalra/siddarthkalra.github.io", useSSH: true)
private let rssFeedSections: Set<SidsWebsite.SectionID> = Set(SidsWebsite.SectionID.allCases)
private let outputFolder: String = "Output"

try SidsWebsite().publish(using: [
    .group(plugins.map(PublishingStep.installPlugin)),
    .optional(.copyResources()),
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
    static func move404FileForGitHubPages() -> Self {
        let stepName = "Move 404 file for GitHub Pages"

        return step(named: stepName) { context in
            guard let orig404Page = context.pages["404"] else {
                throw PublishingError(stepName: stepName,
                                      infoMessage: "Unable to find 404 page")
            }

            let orig404FilePath: Path = "\(outputFolder)/\(orig404Page.path)/index.html"

            let orig404File = try context.file(at: orig404FilePath)
            try orig404File.rename(to: "404")
            try context.copyFileToOutput(from: "\(outputFolder)/\(orig404Page.path)/404.html")

            let orig404Folder = orig404File.parent
            try orig404Folder?.delete()
        }
    }
}
