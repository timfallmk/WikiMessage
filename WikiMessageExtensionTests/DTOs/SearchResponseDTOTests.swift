import XCTest
@testable import WikiMessage_MessagesExtension

final class SearchResponseDTOTests: XCTestCase {

    private let decoder = JSONDecoder()

    private func fixture() throws -> Data {
        let bundle = Bundle(for: type(of: self))
        let url = try XCTUnwrap(bundle.url(forResource: "search_swift", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    func testDecodesPageCount() throws {
        let dto = try decoder.decode(SearchResponseDTO.self, from: fixture())
        XCTAssertEqual(dto.pages.count, 2)
    }

    func testDecodesFirstPageFields() throws {
        let dto = try decoder.decode(SearchResponseDTO.self, from: fixture())
        let first = dto.pages[0]
        XCTAssertEqual(first.id, 25460)
        XCTAssertEqual(first.key, "Swift_(programming_language)")
        XCTAssertEqual(first.title, "Swift (programming language)")
        XCTAssertEqual(first.description, "Programming language by Apple Inc.")
        XCTAssertNotNil(first.thumbnail?.url)
        XCTAssertEqual(first.thumbnail?.resolvedURL?.scheme, "https")
    }

    func testHandlesNullThumbnail() throws {
        let dto = try decoder.decode(SearchResponseDTO.self, from: fixture())
        XCTAssertNil(dto.pages[1].thumbnail)
    }

    func testMapsToArticle() throws {
        let dto = try decoder.decode(SearchResponseDTO.self, from: fixture())
        let article = Article(searchPage: dto.pages[0])
        XCTAssertEqual(article.id, 25460)
        XCTAssertEqual(article.title, "Swift (programming language)")
        XCTAssertTrue(article.articleURL?.absoluteString.contains("Swift_") ?? false)
    }

    func testExcerptHTMLIsStrippedWhenUsedAsDescription() throws {
        let dto = try decoder.decode(SearchResponseDTO.self, from: fixture())
        // Page 2 has description == nil so we fall back to excerpt.
        let article = Article(searchPage: dto.pages[1])
        XCTAssertEqual(article.description, "Taylor Swift is an American singer-songwriter.")
        XCTAssertFalse(article.description?.contains("<") ?? true)
    }
}
