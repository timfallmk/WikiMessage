import XCTest
@testable import WikiMessage_MessagesExtension

final class WikipediaServiceTests: XCTestCase {

    private func makeService() -> WikipediaService {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let client = HTTPClient(session: session)
        return WikipediaService(client: client)
    }

    func testSearchBuildsCorrectURL() async throws {
        var capturedURL: URL?
        MockURLProtocol.handler = { request in
            capturedURL = request.url
            let data = MockURLProtocol.fixture(named: "search_swift")
            return MockURLProtocol.response(data: data, url: request.url!)
        }
        _ = try await makeService().search(query: "swift")
        XCTAssertEqual(capturedURL?.host, "api.wikimedia.org")
        XCTAssertTrue(capturedURL?.path.contains("search/page") ?? false)
        XCTAssertTrue(capturedURL?.query?.contains("q=swift") ?? false)
    }

    func testSearchReturnsArticles() async throws {
        MockURLProtocol.handler = { request in
            MockURLProtocol.response(data: MockURLProtocol.fixture(named: "search_swift"), url: request.url!)
        }
        let articles = try await makeService().search(query: "swift")
        XCTAssertEqual(articles.count, 2)
        XCTAssertEqual(articles[0].title, "Swift (programming language)")
    }

    func testSummaryBuildsCorrectURL() async throws {
        var capturedURL: URL?
        MockURLProtocol.handler = { request in
            capturedURL = request.url
            let data = MockURLProtocol.fixture(named: "summary_einstein")
            return MockURLProtocol.response(data: data, url: request.url!)
        }
        _ = try await makeService().summary(for: "Albert_Einstein")
        XCTAssertEqual(capturedURL?.host, "en.wikipedia.org")
        XCTAssertTrue(capturedURL?.path.contains("Albert_Einstein") ?? false)
    }

    func testPropagatesHTTPErrors() async {
        MockURLProtocol.handler = { request in
            MockURLProtocol.response(statusCode: 404, data: Data(), url: request.url!)
        }
        do {
            _ = try await makeService().search(query: "anything")
            XCTFail("Expected HTTPError to be thrown")
        } catch is HTTPClient.HTTPError {
            // expected
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
