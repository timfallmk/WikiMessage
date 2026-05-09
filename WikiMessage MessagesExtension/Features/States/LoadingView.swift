import SwiftUI

struct LoadingView: View {
    var body: some View {
        ContentUnavailableView {
            ProgressView()
                .controlSize(.large)
        } description: {
            Text("Searching…")
                .foregroundStyle(.secondary)
        }
    }
}
