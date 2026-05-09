import SwiftUI

struct RootView: View {
    @State private var searchModel = SearchModel()
    @Environment(AppModel.self) private var appModel

    var body: some View {
        NavigationStack {
            SearchResultsList()
                .navigationTitle("WikiMessage")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(
                    text: $searchModel.query,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search Wikipedia"
                )
                .searchSuggestions {
                    ForEach(searchModel.recentSearches, id: \.self) { term in
                        Label(term, systemImage: "clock")
                            .searchCompletion(term)
                    }
                }
        }
        .environment(searchModel)
        .sheet(item: $appModel.selectedArticleURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
