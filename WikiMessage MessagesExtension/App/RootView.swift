import SwiftUI

struct RootView: View {
    @StateObject private var searchModel = SearchModel()
    @EnvironmentObject private var appModel: AppModel

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
        .environmentObject(searchModel)
        .sheet(isPresented: Binding(
            get: { appModel.selectedArticleURL != nil },
            set: { if !$0 { appModel.selectedArticleURL = nil } }
        )) {
            if let url = appModel.selectedArticleURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}
