import SwiftUI

struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Try Again", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    ErrorStateView(message: "Something went wrong. Please try again.", onRetry: {})
}
