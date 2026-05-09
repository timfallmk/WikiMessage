import Foundation

actor WikipediaService {
    static let shared = WikipediaService()

    private let client: HTTPClient
    private var inflightSearchTask: Task<[Article], Error>?

    init(client: HTTPClient = .shared) {
        self.client = client
    }

    func search(query: String) async throws -> [Article] {
        inflightSearchTask?.cancel()
        let task = Task<[Article], Error> {
            let baseURL = "https://api.wikimedia.org/core/v1/wikipedia/en/search/page"
            var components = URLComponents(string: baseURL)!
            components.queryItems = [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "limit", value: "10")
            ]
            let dto = try await client.fetch(SearchResponseDTO.self, from: components.url!)
            return dto.pages.map(Article.init(searchPage:))
        }
        inflightSearchTask = task
        return try await task.value
    }

    func summary(for key: String) async throws -> SummaryDTO {
        let encoded = key.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? key
        let url = URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(encoded)")!
        return try await client.fetch(SummaryDTO.self, from: url)
    }
}
