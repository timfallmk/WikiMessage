import SwiftUI
import UIKit

struct SearchResultsList: View {
    @EnvironmentObject private var searchModel: SearchModel
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        Group {
            switch searchModel.phase {
            case .idle:
                idleView
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
    }

    @ViewBuilder
    private var idleView: some View {
        if searchModel.recentSearches.isEmpty {
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
        } else {
            List {
                Section("Recent") {
                    ForEach(searchModel.recentSearches, id: \.self) { term in
                        Button {
                            searchModel.query = term
                        } label: {
                            Label(term, systemImage: "clock")
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    private func compose(_ article: Article) {
        guard let composer = appModel.composer else { return }
        Task { await searchModel.recordSearch(article.title) }
        Task { @MainActor in
            var thumbnail: UIImage? = nil
            if let url = article.thumbnailURL,
               let (data, _) = try? await URLSession.shared.data(from: url) {
                thumbnail = UIImage(data: data)
            }
            let message = MessageBuilder.build(article: article, thumbnailImage: thumbnail)
            try? await composer.insert(message)
        }
    }
}
