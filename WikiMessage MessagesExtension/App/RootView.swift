import SwiftUI

struct RootView: View {
    @StateObject private var searchModel = SearchModel()
    @EnvironmentObject private var appModel: AppModel
    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            Divider()
            SearchResultsList()
        }
        .environmentObject(searchModel)
        .onChange(of: searchFocused) { focused in
            if focused { appModel.expandRequest?() }
        }
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

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search Wikipedia", text: $searchModel.query)
                .focused($searchFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
            if !searchModel.query.isEmpty {
                Button {
                    searchModel.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
