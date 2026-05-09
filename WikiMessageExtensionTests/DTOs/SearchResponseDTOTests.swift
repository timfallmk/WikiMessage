import Testing
import Foundation
@testable import WikiMessage_MessagesExtension

@Suite("SearchResponseDTO decoding")
struct SearchResponseDTOTests {

    private let decoder = JSONDecoder()

    private func fixture() throws -> Data {
        let url = Bundle(for: type(of: MockURLProtocol())).url(forResource: "search_swift", withExtension: "json")!
        return try Data(contentsOf: url)
    }

    @Test func decodesPageCount() throws {
        let dto = try decoder.decode(SearchResponseDTO.self, from: fixture())
        #expect(dto.pages.count == 2)
    }

    @Test func decodesFirstPageFields() throws {
        let dto = try decoder.decode(SearchResponseDTO.self, from: fixture())
        let first = dto.pages[0]
        #expect(first.id == 25460)
        #expect(first.key == "Swift_(programming_language)")
        #expect(first.title == "Swift (programming language)")
        #expect(first.description == "Programming language by Apple Inc.")
        #expect(first.thumbnail?.source != nil)
    }

    @Test func handlesNullThumbnail() throws {
        let dto = try decoder.decode(SearchResponseDTO.self, from: fixture())
        #expect(dto.pages[1].thumbnail == nil)
    }

    @Test func mapsToArticle() throws {
        let dto = try decoder.decode(SearchResponseDTO.self, from: fixture())
        let article = Article(searchPage: dto.pages[0])
        #expect(article.id == 25460)
        #expect(article.title == "Swift (programming language)")
        #expect(article.articleURL?.absoluteString.contains("Swift_") == true)
    }
}
