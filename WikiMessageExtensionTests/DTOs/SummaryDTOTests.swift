import Testing
import Foundation
@testable import WikiMessage_MessagesExtension

@Suite("SummaryDTO decoding")
struct SummaryDTOTests {

    private let decoder = JSONDecoder()

    private func fixture() throws -> Data {
        let url = Bundle(for: type(of: MockURLProtocol())).url(forResource: "summary_einstein", withExtension: "json")!
        return try Data(contentsOf: url)
    }

    @Test func decodesTitle() throws {
        let dto = try decoder.decode(SummaryDTO.self, from: fixture())
        #expect(dto.title == "Albert_Einstein")
        #expect(dto.displayTitle == "Albert Einstein")
    }

    @Test func decodesDescription() throws {
        let dto = try decoder.decode(SummaryDTO.self, from: fixture())
        #expect(dto.description?.isEmpty == false)
    }

    @Test func decodesExtract() throws {
        let dto = try decoder.decode(SummaryDTO.self, from: fixture())
        #expect(dto.extract != nil)
    }

    @Test func decodesThumbnailURL() throws {
        let dto = try decoder.decode(SummaryDTO.self, from: fixture())
        #expect(dto.thumbnail?.source != nil)
    }

    @Test func decodesArticleURL() throws {
        let dto = try decoder.decode(SummaryDTO.self, from: fixture())
        #expect(dto.contentURLs?.desktop?.page?.absoluteString.contains("wikipedia.org") == true)
    }
}
