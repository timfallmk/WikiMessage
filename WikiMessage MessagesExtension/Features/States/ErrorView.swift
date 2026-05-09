import SwiftUI

struct ErrorView: View {
    let error: Error
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Something went wrong")
                .font(.headline)
            Text(error.localizedDescription)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again", action: retry)
                .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
