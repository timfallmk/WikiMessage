import SwiftUI

struct SearchResultsList: View {
    @Environment(SearchModel.self) private var searchModel
    @Environment(AppModel.self) private var appModel

    var body: some View {
        Group {
            switch searchModel.phase {
            case .idle:
                ContentUnavailableView(
                    "Search Wikipedia",
                    systemImage: "magnifyingglass",
                    description: Text("Type to search for articles.")
                )
            case .loading:
                LoadingView()
            case .results(let articles):
                List(articles) { article in
                    ArticleRow(article: article)
                        .onTapGesture { compose(article) }
                        .contextMenu {
                            if let url = article.articleURL {
                                Button("Open in Safari", systemImage: "safari") {
                                    appModel.selectedArticleURL = url
                                }
                                Button("Copy Link", systemImage: "link") {
                                    UIPasteboard.general.url = url
                                }
                            }
                        }
                }
                .listStyle(.plain)
            case .empty:
                EmptyResultsView(query: searchModel.query)
            case .error(let error):
                ErrorView(error: error) {
                    Task { await searchModel.performSearch() }
                }
            }
        }
        .task(id: searchModel.query) {
            try? await Task.sleep(for: .milliseconds(300))
            await searchModel.performSearch()
        }
    }

    private func compose(_ article: Article) {
        guard let composer = appModel.composer else { return }
        let message = MessageBuilder.build(article: article)
        searchModel.recordSearch(article.title)
        Task {
            try? await composer.insert(message)
        }
    }
}
