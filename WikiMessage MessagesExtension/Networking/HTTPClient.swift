import Foundation

actor HTTPClient {
    static let shared = HTTPClient()

    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024)
        config.httpAdditionalHeaders = [
            "User-Agent": "WikiMessage/2.0 (https://github.com/timfallmk/WikiMessage)"
        ]
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }

    init(session: URLSession) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw HTTPError.badStatus((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        return try decoder.decode(T.self, from: data)
    }

    enum HTTPError: Error, LocalizedError {
        case badStatus(Int)

        var errorDescription: String? {
            switch self {
            case .badStatus(let code): return "Server returned status \(code)."
            }
        }
    }
}
