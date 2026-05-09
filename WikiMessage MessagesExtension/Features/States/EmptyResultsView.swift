import SwiftUI

struct EmptyResultsView: View {
    let query: String

    var body: some View {
        ContentUnavailableView.search(text: query)
    }
}
