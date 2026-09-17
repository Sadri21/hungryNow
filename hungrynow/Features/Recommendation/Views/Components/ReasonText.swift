//
//  ReasonText.swift
//  hungrynow
//
//  Screen 06 — 3-line clamped reason copy with expandable More / Less toggle.
//

import SwiftUI

/// 3-line clamped reason text with automatic overflow detection and a smooth "More / Less" toggle.
struct ReasonText: View {
    let text: String

    @State private var isExpanded = false
    @State private var isTruncated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .font(AppFont.bodyText)
                .foregroundColor(Color.text2)
                .lineLimit(isExpanded ? nil : 3)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    GeometryReader { geo in
                        if geo.size.width > 0 && !text.isEmpty {
                            ZStack {
                                Text(text)
                                    .font(AppFont.bodyText)
                                    .lineSpacing(2)
                                    .lineLimit(3)
                                    .frame(width: geo.size.width, alignment: .leading)
                                    .background(
                                        GeometryReader { g in
                                            Color.clear.preference(
                                                key: TextHeightsKey.self,
                                                value: TextHeightPair(clamped: g.size.height, full: 0)
                                            )
                                        }
                                    )

                                Text(text)
                                    .font(AppFont.bodyText)
                                    .lineSpacing(2)
                                    .lineLimit(nil)
                                    .frame(width: geo.size.width, alignment: .leading)
                                    .background(
                                        GeometryReader { g in
                                            Color.clear.preference(
                                                key: TextHeightsKey.self,
                                                value: TextHeightPair(clamped: 0, full: g.size.height)
                                            )
                                        }
                                    )
                            }
                            .hidden()
                        }
                    }
                )
                .onPreferenceChange(TextHeightsKey.self) { pair in
                    if pair.clamped > 0 && pair.full > 0 {
                        let truncated = pair.full > (pair.clamped + 1.5)
                        if isTruncated != truncated {
                            isTruncated = truncated
                        }
                    }
                }

            if isTruncated {
                Button(isExpanded ? "Less" : "More") {
                    withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
                }
                .buttonStyle(.plain)
                .font(AppFont.inlineAction)
                .foregroundColor(Color.heroText)
                .padding(.top, Metrics.space2)
                .frame(minHeight: Metrics.tapTarget, alignment: .leading)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}

private struct TextHeightPair: Equatable {
    var clamped: CGFloat = 0
    var full: CGFloat = 0
}

private struct TextHeightsKey: PreferenceKey {
    static var defaultValue: TextHeightPair = TextHeightPair()
    static func reduce(value: inout TextHeightPair, nextValue: () -> TextHeightPair) {
        let next = nextValue()
        if next.clamped > 0 { value.clamped = next.clamped }
        if next.full > 0 { value.full = next.full }
    }
}
