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
        // The search API wraps matched terms in <span class="searchmatch">…</span>
        // and uses excerpt as a richer fallback when description is absent.
        description = page.description ?? page.excerpt?.strippingHTMLTags()
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
            title: (dto.displayTitle ?? dto.title).strippingHTMLTags(),
            description: dto.description ?? description,
            summary: dto.extract,
            thumbnailURL: dto.thumbnail?.resolvedURL ?? thumbnailURL,
            articleURL: dto.contentURLs?.desktop?.page ?? articleURL
        )
    }
}

extension String {
    fileprivate func strippingHTMLTags() -> String {
        replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}
