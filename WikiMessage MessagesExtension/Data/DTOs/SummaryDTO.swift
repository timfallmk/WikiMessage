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
    let source: URL?
    let width: Int?
    let height: Int?
}
