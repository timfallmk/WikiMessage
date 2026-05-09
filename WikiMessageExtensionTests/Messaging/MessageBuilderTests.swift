import Messages
import XCTest
@testable import WikiMessage_MessagesExtension

final class MessageBuilderTests: XCTestCase {

    private let article = Article(
        id: 1,
        key: "Test_Article",
        title: "Test Article",
        description: "A test description",
        summary: "A longer summary that might be truncated if it exceeds one hundred and twenty characters in total length.",
        thumbnailURL: nil,
        articleURL: URL(string: "https://en.wikipedia.org/wiki/Test_Article")
    )

    func testSetsCaption() {
        let layout = MessageBuilder.build(article: article).layout as? MSMessageTemplateLayout
        XCTAssertEqual(layout?.caption, "Test Article")
    }

    func testSetsSubcaption() {
        let layout = MessageBuilder.build(article: article).layout as? MSMessageTemplateLayout
        XCTAssertEqual(layout?.subcaption, "A test description")
    }

    func testTruncatesLongSummary() {
        let layout = MessageBuilder.build(article: article).layout as? MSMessageTemplateLayout
        XCTAssertTrue(layout?.trailingCaption?.hasSuffix("…") ?? false)
        XCTAssertLessThanOrEqual(layout?.trailingCaption?.count ?? 0, 121)
    }

    func testSetsURL() {
        let message = MessageBuilder.build(article: article)
        XCTAssertEqual(message.url?.absoluteString, "https://en.wikipedia.org/wiki/Test_Article")
    }

    func testSetsSummaryText() {
        let message = MessageBuilder.build(article: article)
        XCTAssertTrue(message.summaryText?.contains("Test Article") ?? false)
    }
}
