import Observation

enum SearchPhase {
    case idle, loading, results([Article]), empty, error(Error)
}

@Observable
@MainActor
final class SearchModel {
    var query: String = ""
    var phase: SearchPhase = .idle
    var recentSearches: [String] = RecentSearchesStore.load()

    private let service: WikipediaService

    init(service: WikipediaService = .shared) {
        self.service = service
    }

    func performSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            phase = .idle
            return
        }
        phase = .loading
        do {
            let articles = try await service.search(query: trimmed)
            phase = articles.isEmpty ? .empty : .results(articles)
        } catch {
            if (error as? CancellationError) != nil { return }
            phase = .error(error)
        }
    }

    func recordSearch(_ term: String) {
        RecentSearchesStore.save(term)
        recentSearches = RecentSearchesStore.load()
    }
}
