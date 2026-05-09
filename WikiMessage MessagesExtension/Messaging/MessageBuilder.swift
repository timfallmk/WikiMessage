import Messages
import UIKit

enum MessageBuilder {
    static func build(article: Article) -> MSMessage {
        let message = MSMessage()
        let layout = MSMessageTemplateLayout()

        layout.caption = article.title
        layout.subcaption = article.description

        if let summary = article.summary {
            let truncated = String(summary.prefix(120))
            layout.trailingCaption = summary.count > 120 ? truncated + "…" : truncated
        }

        if let thumbnailURL = article.thumbnailURL,
           let data = try? Data(contentsOf: thumbnailURL),
           let image = UIImage(data: data) {
            layout.image = image
        }

        message.layout = layout
        message.url = article.articleURL
        message.summaryText = "Shared a Wikipedia article: \(article.title)"

        return message
    }
}
