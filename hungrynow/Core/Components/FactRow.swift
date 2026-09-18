//
//  FactRow.swift
//  hungrynow
//
//  `.fact-row` / `.fact` — the metric row.
//

import SwiftUI

/// One fact: a value with a caption naming the field.
///
/// Order is FIXED — distance, price, rating — and callers build the array in that order.
/// The row's whole value is that it scans as one object in one glance, and a row whose
/// columns move between screens does not.
struct Fact: Identifiable {
    let label: String
    let value: String

    /// Draws the star glyph beside the value. Belongs to the *rating* fact, not to a
    /// position in the array.
    ///
    /// `ResultFactsCard` used to key the star off `index == 1`, which held only while
    /// every pick had all three facts. Once a missing rating or distance can drop a
    /// column, position stops identifying the fact: a starred price is one omission away.
    var showsStar: Bool = false

    var id: String { label }
}

/// Value-over-label, not chips.
///
/// Sadri's call, 2026-09-08: the first build used outlined pills and broke the
/// "no pill everything" rule already written down in `visual-identity.md`. The exemption
/// there is for buttons and status — a fact dressed as an object is exactly what the rule
/// targets.
///
/// **The accent lives on the VALUE only.** The label is always `text2`, because it is a
/// caption naming the field rather than part of the fact — which is why `.calm` needs no
/// label variant and why the accent reservation still means something.
struct FactRow: View {
    let facts: [Fact]

    /// `.calm` — pistachio values instead of pomegranate. Screen 08 uses it; screen 06's
    /// hero does not, and that difference is the colour-meaning rule.
    var isCalm: Bool = false

    var body: some View {
        // Three columns fit one line at every device width and default text size. This is
        // the one place a wrap is preferable to a squeeze: at a large accessibility size the
        // values genuinely cannot share a line, and a wrapped row still reads, where
        // clipped numbers do not. The mockup could not express that at all.
        HStack(alignment: .top, spacing: Metrics.space5) {
            ForEach(facts) { fact in
                VStack(alignment: .leading, spacing: 1) {
                    Text(fact.value)
                        .font(AppFont.factValue)
                        .foregroundColor(isCalm ? Color.specText : Color.heroText)
                        .lineLimit(1)
                        .fixedSize()

                    Text(fact.label.uppercased())
                        .font(AppFont.microLabel)
                        .tracking(Metrics.microTracking)
                        .foregroundColor(Color.text2)
                        .lineLimit(1)
                        .fixedSize()
                }
                // Read as "400 metres away", not "400 m, away" — the caption is the unit of
                // meaning, so the pair is one element.
                .accessibilityElement(children: .combine)
            }
        }
    }
}
