//
//  ResultFactsCard.swift
//  hungrynow
//
//  Screen 06 — 3-column facts card showing distance away, rating, and price per person.
//

import SwiftUI

/// Elevated facts card with 3 columns: distance, rating, and price per person.
struct ResultFactsCard: View {
    let facts: [Fact]

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(Array(facts.enumerated()), id: \.offset) { index, fact in
                if index > 0 {
                    Color.hairline
                        .frame(width: 1, height: 38)
                }

                VStack(alignment: .leading, spacing: 4) {
                    if fact.showsStar {
                        HStack(spacing: 5) {
                            AppGlyph.starFill.image(size: 16, color: Color.heroText)
                            Text(fact.value)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(Color.text)
                                .lineLimit(1)
                        }
                    } else {
                        Text(fact.value)
                            .font(.system(size: fact.value.count > 7 ? 17 : 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color.text)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }

                    Text(fact.label)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(Color.text2)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, index == 0 ? 0 : 14)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.elevated)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.vertical, 16)
    }
}
