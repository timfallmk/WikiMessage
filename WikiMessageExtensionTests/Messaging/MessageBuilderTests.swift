import Testing
import Messages
@testable import WikiMessage_MessagesExtension

@Suite("MessageBuilder")
struct MessageBuilderTests {

    private let article = Article(
        id: 1,
        key: "Test_Article",
        title: "Test Article",
        description: "A test description",
        summary: "A longer summary that might be truncated if it exceeds one hundred and twenty characters in total length.",
        thumbnailURL: nil,
        articleURL: URL(string: "https://en.wikipedia.org/wiki/Test_Article")
    )

    @Test func setsCaption() {
        let message = MessageBuilder.build(article: article)
        let layout = message.layout as? MSMessageTemplateLayout
        #expect(layout?.caption == "Test Article")
    }

    @Test func setsSubcaption() {
        let message = MessageBuilder.build(article: article)
        let layout = message.layout as? MSMessageTemplateLayout
        #expect(layout?.subcaption == "A test description")
    }

    @Test func truncatesLongSummary() {
        let message = MessageBuilder.build(article: article)
        let layout = message.layout as? MSMessageTemplateLayout
        #expect(layout?.trailingCaption?.hasSuffix("…") == true)
        #expect((layout?.trailingCaption?.count ?? 0) <= 121)
    }

    @Test func setsURL() {
        let message = MessageBuilder.build(article: article)
        #expect(message.url?.absoluteString == "https://en.wikipedia.org/wiki/Test_Article")
    }

    @Test func setsSummaryText() {
        let message = MessageBuilder.build(article: article)
        #expect(message.summaryText?.contains("Test Article") == true)
    }
}
