import Messages
import UIKit

enum MessageBuilder {
    static func build(article: Article, thumbnailImage: UIImage? = nil) -> MSMessage {
        let message = MSMessage()
        let layout = MSMessageTemplateLayout()

        layout.caption = article.title
        layout.subcaption = article.description

        if let summary = article.summary {
            let truncated = String(summary.prefix(120))
            layout.trailingCaption = summary.count > 120 ? truncated + "…" : truncated
        }

        // MSMessageTemplateLayout in iMessage's draft renderer requires either
        // image or mediaFileURL — leaving both nil triggers an unrecognized
        // selector crash inside CKComposition.compositionWithShelfPluginPayload.
        layout.image = thumbnailImage
            ?? UIImage(named: "defaultArticleImage")
            ?? UIImage(named: "articlePlaceholderImage")

        message.layout = layout
        message.url = article.articleURL
        message.summaryText = "Shared a Wikipedia article: \(article.title)"

        return message
    }
}
