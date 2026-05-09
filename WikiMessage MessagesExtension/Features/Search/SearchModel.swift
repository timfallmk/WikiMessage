import Combine

enum SearchPhase {
    case idle, loading, results([Article]), empty, error(Error)
}

final class SearchModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var phase: SearchPhase = .idle
    @Published private(set) var recentSearches: [String] = RecentSearchesStore.load()

    private let service: WikipediaService

    init(service: WikipediaService = .shared) {
        self.service = service
    }

    @MainActor
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
            if error is CancellationError { return }
            phase = .error(error)
        }
    }

    @MainActor
    func recordSearch(_ term: String) {
        RecentSearchesStore.save(term)
        recentSearches = RecentSearchesStore.load()
    }
}
