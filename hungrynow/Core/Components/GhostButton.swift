//
//  GhostButton.swift
//  hungrynow
//
//  `.btn-ghost` — the demoted action.
//

import SwiftUI

/// Text-only, full width, no fill and no border.
///
/// The counterpart to `PrimaryButton`: one pill and one ghost, so "which of these two
/// actions is the real one" never has to be re-decided per screen. Shared from the first
/// use rather than the third, because 05, 06 and the edge states all want it.
struct GhostButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.secondaryLabel)
                .foregroundColor(Color.text2)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, Metrics.space3)
                .frame(maxWidth: .infinity, minHeight: Metrics.tapTarget)
                // Without this only the label is tappable, not the full width the layout
                // implies.
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
