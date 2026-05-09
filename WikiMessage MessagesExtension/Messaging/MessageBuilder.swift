import Messages
import UIKit

enum MessageBuilder {
    static func build(article: Article, thumbnailImage: UIImage? = nil) -> MSMessage {
        let layout = MSMessageTemplateLayout()
        layout.caption = article.title
        layout.subcaption = article.summary ?? article.description
        layout.image = thumbnailImage
            ?? UIImage(named: "defaultArticleImage")
            ?? UIImage(named: "articlePlaceholderImage")

        let message = MSMessage()
        message.layout = layout
        message.url = article.articleURL
        return message
    }
}
