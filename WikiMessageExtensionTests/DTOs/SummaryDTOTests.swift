import XCTest
@testable import WikiMessage_MessagesExtension

final class SummaryDTOTests: XCTestCase {

    private let decoder = JSONDecoder()

    private func fixture() throws -> Data {
        let bundle = Bundle(for: type(of: self))
        let url = try XCTUnwrap(bundle.url(forResource: "summary_einstein", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    func testDecodesTitle() throws {
        let dto = try decoder.decode(SummaryDTO.self, from: fixture())
        XCTAssertEqual(dto.title, "Albert_Einstein")
        XCTAssertEqual(dto.displayTitle, "Albert Einstein")
    }

    func testDecodesDescription() throws {
        let dto = try decoder.decode(SummaryDTO.self, from: fixture())
        XCTAssertFalse(dto.description?.isEmpty ?? true)
    }

    func testDecodesExtract() throws {
        let dto = try decoder.decode(SummaryDTO.self, from: fixture())
        XCTAssertNotNil(dto.extract)
    }

    func testDecodesThumbnailURL() throws {
        let dto = try decoder.decode(SummaryDTO.self, from: fixture())
        XCTAssertNotNil(dto.thumbnail?.source)
    }

    func testDecodesArticleURL() throws {
        let dto = try decoder.decode(SummaryDTO.self, from: fixture())
        XCTAssertTrue(dto.contentURLs?.desktop?.page?.absoluteString.contains("wikipedia.org") ?? false)
    }
}
