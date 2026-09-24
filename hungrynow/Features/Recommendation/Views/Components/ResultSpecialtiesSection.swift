//
//  ResultSpecialtiesSection.swift
//  hungrynow
//
//  Screen 06 — Numbered local specialty alternative recommendations ("01", "02", "03").
//

import SwiftUI

/// Numbered local specialty picks section with subtitle and cuisine category.
struct ResultSpecialtiesSection: View {
    let specialties: [SpecialtyPick]
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("SOMETHING A LITTLE DIFFERENT")
                .font(AppFont.microLabel)
                .tracking(Metrics.microTracking)
                .foregroundColor(Color.specText)
                .padding(.bottom, 6)

            Text("Try a local specialty")
                .font(AppFont.rounded(.title2, .bold))
                .foregroundColor(Color.text)
                .padding(.bottom, 16)

            VStack(spacing: 0) {
                ForEach(Array(specialties.enumerated()), id: \.offset) { index, pick in
                    if index > 0 {
                        Color.hairline.frame(height: 1)
                    }
                    HStack(alignment: .top, spacing: 14) {
                        Text(String(format: "%02d", index + 1))
                            .font(AppFont.tag)
                            .foregroundColor(Color.specText)
                            .padding(.top, 2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(pick.name)
                                .font(AppFont.listTitle)
                                .foregroundColor(Color.text)

                            let sub = specialtySubtitle(for: pick)
                            if !sub.isEmpty {
                                Text(sub)
                                    .font(AppFont.bodyText)
                                    .foregroundColor(Color.text2)
                            }

                            // specialty-meta
                            if pick.rating != nil || pick.priceLevel != nil {
                                HStack(spacing: 5) {
                                    if let rating = pick.rating {
                                        HStack(spacing: 3) {
                                            AppGlyph.star.image(size: 13, color: Color.specText)
                                                .accessibilityHidden(true)
                                            Text(FactFormatter.ratingValue(rating))
                                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                                .foregroundColor(Color.specText)
                                        }
                                        .accessibilityElement(children: .ignore)
                                        .accessibilityLabel(
                                            FactFormatter.spokenRating(FactFormatter.ratingValue(rating))
                                        )
                                    }

                                    if let count = pick.ratingCount, count > 0 {
                                        Text("·")
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(Color.hairline)
                                            .accessibilityHidden(true)

                                        Text("\(FactFormatter.compactCount(count)) reviews")
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(Color.text2)
                                    }

                                    if let priceText = FactFormatter.price(
                                        range: pick.priceRange,
                                        level: pick.priceLevel
                                    ) {
                                        Text("·")
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(Color.hairline)
                                            .accessibilityHidden(true)

                                        Text(priceText)
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(Color.text2)
                                    }
                                }
                                .padding(.top, 4)
                            }

                            // specialty-actions
                            HStack(spacing: 20) {
                                NavigationLink(value: PlaceDetailItem(specialty: pick)) {
                                    HStack(spacing: 5) {
                                        Text("Details")
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                        AppGlyph.chevronRight.image(size: 17, color: Color.specText)
                                    }
                                    .foregroundColor(Color.specText)
                                    .frame(minHeight: 44)
                                    // The 44pt minHeight only reserved space — it was not
                                    // hittable, so the gap above and below the 13pt label
                                    // did nothing. This makes the whole reserved box the
                                    // target, which is what the height was for.
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.pressableInline)

                                Button {
                                    if let url = DirectionsLink.appleMaps(
                                        latitude: pick.latitude,
                                        longitude: pick.longitude,
                                        name: pick.name
                                    ) ?? DirectionsLink.googleMapsPlace(
                                        placeId: pick.placeId,
                                        name: pick.name,
                                        address: pick.address
                                    ) {
                                        openURL(url)
                                    }
                                } label: {
                                    HStack(spacing: 5) {
                                        Text("Directions")
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                        AppGlyph.navigationPointer.image(size: 17, color: Color.specText)
                                    }
                                    .foregroundColor(Color.specText)
                                    .frame(minHeight: 44)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.pressableInline)
                            }
                            .padding(.top, 2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .padding(24)
        .background(Color.elevated)
        .clipShape(AsymmetricRoundedRectangle(topLeading: 28, topTrailing: 28))
    }

    private func specialtySubtitle(for pick: SpecialtyPick) -> String {
        if pick.description.isEmpty {
            return pick.foodCategory
        } else {
            return "\(pick.foodCategory) · \(pick.description)"
        }
    }
}

// MARK: - Preview

#Preview("Specialties Section") {
    ResultSpecialtiesSection(
        specialties: [
            SpecialtyPick(
                name: "Warung Nasi Ibu Oka",
                address: "Jl. Suweta",
                reason: "",
                description: "Balinese roast pork",
                foodCategory: "Babi Guling",
                rating: 4.6,
                ratingCount: 1240,
                priceLevel: 2
            ),
            SpecialtyPick(
                name: "Sate Babi Bawah Pohon",
                address: "Jl. Pantai",
                reason: "",
                description: "Grilled pork skewers",
                foodCategory: "Satay",
                rating: 4.5,
                ratingCount: 890,
                priceLevel: 1
            ),
            SpecialtyPick(
                name: "Kedai Kopi Bhineka Djaja",
                address: "Jl. Gajah Mada",
                reason: "",
                description: "A stop after your meal",
                foodCategory: "Coffee",
                rating: 4.7,
                ratingCount: 520,
                priceLevel: 1
            )
        ]
    )
    .background(Color.bg)
}
