import SwiftUI

struct SearchResultsList: View {
    @EnvironmentObject private var searchModel: SearchModel
    @EnvironmentObject private var appModel: AppModel
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        Group {
            switch searchModel.phase {
            case .idle:
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("Search Wikipedia")
                        .font(.headline)
                    Text("Type to search for articles.")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loading:
                LoadingView()
            case .results(let articles):
                List(articles) { article in
                    ArticleRow(article: article)
                        .onTapGesture { compose(article) }
                        .contextMenu {
                            if let url = article.articleURL {
                                Button {
                                    appModel.selectedArticleURL = url
                                } label: {
                                    Label("Open in Safari", systemImage: "safari")
                                }
                                Button {
                                    UIPasteboard.general.url = url
                                } label: {
                                    Label("Copy Link", systemImage: "link")
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
        .onChange(of: isSearching) { newValue in
            if newValue { appModel.expandRequest?() }
        }
    }

    private func compose(_ article: Article) {
        guard let composer = appModel.composer else { return }
        let message = MessageBuilder.build(article: article)
        Task { await searchModel.recordSearch(article.title) }
        Task {
            try? await composer.insert(message)
        }
    }
}
