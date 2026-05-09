import Foundation

struct SummaryDTO: Decodable {
    let title: String
    let displayTitle: String?
    let description: String?
    let extract: String?
    let thumbnail: ThumbnailDTO?
    let originalimage: ThumbnailDTO?
    let contentURLs: ContentURLs?

    enum CodingKeys: String, CodingKey {
        case title
        case displayTitle = "displaytitle"
        case description
        case extract
        case thumbnail
        case originalimage
        case contentURLs = "content_urls"
    }

    struct ContentURLs: Decodable {
        let desktop: PageURL?

        struct PageURL: Decodable {
            let page: URL?
        }
    }
}

struct ThumbnailDTO: Decodable {
    // Summary REST returns absolute "source"; core v1 search returns
    // protocol-relative "url" like "//upload.wikimedia.org/..."
    let source: URL?
    let url: String?
    let width: Int?
    let height: Int?

    var resolvedURL: URL? {
        if let source { return source }
        guard let url else { return nil }
        let absolute = url.hasPrefix("//") ? "https:\(url)" : url
        return URL(string: absolute)
    }
}
