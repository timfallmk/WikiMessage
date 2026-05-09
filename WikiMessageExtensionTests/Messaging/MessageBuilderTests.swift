import Messages
import XCTest
@testable import WikiMessage_MessagesExtension

final class MessageBuilderTests: XCTestCase {

    private let article = Article(
        id: 1,
        key: "Test_Article",
        title: "Test Article",
        description: "A test description",
        summary: "A longer summary that might be truncated if it exceeds 120 chars in total length.",
        thumbnailURL: nil,
        articleURL: URL(string: "https://en.wikipedia.org/wiki/Test_Article")
    )

    func testSetsCaption() {
        let layout = MessageBuilder.build(article: article).layout as? MSMessageTemplateLayout
        XCTAssertEqual(layout?.caption, "Test Article")
    }

    func testSubcaptionPrefersSummary() {
        let layout = MessageBuilder.build(article: article).layout as? MSMessageTemplateLayout
        XCTAssertEqual(layout?.subcaption, article.summary)
    }

    func testFallsBackToDescriptionWhenNoSummary() {
        let plain = Article(
            id: 2, key: "k", title: "T", description: "Desc", summary: nil,
            thumbnailURL: nil, articleURL: nil
        )
        let layout = MessageBuilder.build(article: plain).layout as? MSMessageTemplateLayout
        XCTAssertEqual(layout?.subcaption, "Desc")
    }

    func testSetsURL() {
        let message = MessageBuilder.build(article: article)
        XCTAssertEqual(message.url?.absoluteString, "https://en.wikipedia.org/wiki/Test_Article")
    }
}
