import Foundation

struct Article: Identifiable, Hashable, Sendable {
    let id: Int
    let key: String
    let title: String
    let description: String?
    let summary: String?
    let thumbnailURL: URL?
    let articleURL: URL?

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Article, rhs: Article) -> Bool { lhs.id == rhs.id }
}

extension Article {
    init(searchPage page: SearchResponseDTO.PageDTO) {
        id = page.id
        key = page.key
        title = page.title
        description = page.description ?? page.excerpt
        summary = nil
        thumbnailURL = page.thumbnail?.resolvedURL
        articleURL = URL(string: "https://en.wikipedia.org/wiki/\(page.key)")
    }

    init(summary dto: SummaryDTO, key: String) {
        id = 0
        self.key = key
        title = dto.displayTitle ?? dto.title
        description = dto.description
        summary = dto.extract
        thumbnailURL = dto.thumbnail?.resolvedURL
        articleURL = dto.contentURLs?.desktop?.page
    }

    func withSummary(_ dto: SummaryDTO) -> Article {
        Article(
            id: id,
            key: key,
            title: dto.displayTitle ?? dto.title,
            description: dto.description ?? description,
            summary: dto.extract,
            thumbnailURL: dto.thumbnail?.resolvedURL ?? thumbnailURL,
            articleURL: dto.contentURLs?.desktop?.page ?? articleURL
        )
    }
}
