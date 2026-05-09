import Testing
import Foundation
@testable import WikiMessage_MessagesExtension

@Suite("WikipediaService")
struct WikipediaServiceTests {

    private func makeService() -> (WikipediaService, URLSession) {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let client = HTTPClient(session: session)
        return (WikipediaService(client: client), session)
    }

    @Test func searchBuildsCorrectURL() async throws {
        var capturedURL: URL?
        MockURLProtocol.handler = { request in
            capturedURL = request.url
            let data = MockURLProtocol.fixture(named: "search_swift")
            return MockURLProtocol.response(data: data, url: request.url!)
        }
        let (service, _) = makeService()
        _ = try await service.search(query: "swift")
        #expect(capturedURL?.host() == "api.wikimedia.org")
        #expect(capturedURL?.path().contains("search/page") == true)
        #expect(capturedURL?.query()?.contains("q=swift") == true)
    }

    @Test func searchReturnsArticles() async throws {
        MockURLProtocol.handler = { request in
            let data = MockURLProtocol.fixture(named: "search_swift")
            return MockURLProtocol.response(data: data, url: request.url!)
        }
        let (service, _) = makeService()
        let articles = try await service.search(query: "swift")
        #expect(articles.count == 2)
        #expect(articles[0].title == "Swift (programming language)")
    }

    @Test func summaryBuildsCorrectURL() async throws {
        var capturedURL: URL?
        MockURLProtocol.handler = { request in
            capturedURL = request.url
            let data = MockURLProtocol.fixture(named: "summary_einstein")
            return MockURLProtocol.response(data: data, url: request.url!)
        }
        let (service, _) = makeService()
        _ = try await service.summary(for: "Albert_Einstein")
        #expect(capturedURL?.host() == "en.wikipedia.org")
        #expect(capturedURL?.path().contains("Albert_Einstein") == true)
    }

    @Test func propagatesHTTPErrors() async throws {
        MockURLProtocol.handler = { request in
            return MockURLProtocol.response(statusCode: 404, data: Data(), url: request.url!)
        }
        let (service, _) = makeService()
        await #expect(throws: HTTPClient.HTTPError.self) {
            _ = try await service.search(query: "anything")
        }
    }
}
