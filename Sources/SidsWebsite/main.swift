import Foundation
import Publish
import Plot
import SplashPublishPlugin

// This type acts as the configuration for your website.
struct SidsWebsite: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
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

try SidsWebsite().publish(withTheme: .primary,
                          deployedUsing: .gitHub("siddarthkalra/siddarthkalra.github.io", useSSH: true),
                          plugins: [.splash(withClassPrefix: "splash-")])
