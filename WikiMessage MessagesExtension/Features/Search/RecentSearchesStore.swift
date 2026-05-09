import Foundation

enum RecentSearchesStore {
    private static let key = "com.timfall.WikiMessage.recentSearches"
    private static let maxCount = 10

    static func load() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    static func save(_ term: String) {
        var searches = load()
        searches.removeAll { $0 == term }
        searches.insert(term, at: 0)
        UserDefaults.standard.set(Array(searches.prefix(maxCount)), forKey: key)
    }
}
