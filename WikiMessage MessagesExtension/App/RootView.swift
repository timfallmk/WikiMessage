import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var searchModel: SearchModel

    var body: some View {
        SearchResultsList()
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
