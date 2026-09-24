//
//  ResultSheet.swift
//  hungrynow
//
//  Screen 06 — Overlapping result sheet card with restaurant pin illustration,
//  location caption, "PICKED FOR YOU" label, name, facts card, permanently visible
//  recommendation reason, and restaurant details handoff.
//

import SwiftUI

/// The main content sheet overlapping the hero photo by 24pt.
struct ResultSheet: View {
    let hero: HeroPick
    let locationName: String?
    let photoCount: Int
    let slide: Int
    let facts: [Fact]
    let photoAttribution: String?
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            captionRow

            // "PICKED FOR YOU" tag
            HStack(spacing: 8) {
                AppGlyph.cutlery.image(size: 16, color: Color.heroText)
                    .accessibilityHidden(true)
                Text("PICKED FOR YOU")
                    .font(AppFont.microLabel)
                    .tracking(Metrics.microTracking)
                    .foregroundColor(Color.heroText)
            }
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Restaurant Name
            Text(hero.name)
                .font(AppFont.screenQuestion)
                .foregroundColor(Color.text)
                .fixedSize(horizontal: false, vertical: true)

            // Facts card — omitted entirely when nothing is known, since the card is
            // only a frame around its columns and an empty one reads as a loading bar.
            if !facts.isEmpty {
                ResultFactsCard(facts: facts)
            }

            // Permanently visible reason block
            reasonBlock

            // Restaurant details handoff
            googleDetailsRow
        }
        .padding(.horizontal, Metrics.margin)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .background(Color.bg)
        .clipShape(AsymmetricRoundedRectangle(topLeading: 32, topTrailing: 32))
        .overlay(alignment: .topTrailing) {
            Image("result-restaurant-pin")
                .resizable()
                .scaledToFit()
                .frame(width: 112, height: 112)
                .offset(x: -16, y: -52)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .padding(.top, -24)
    }

    // MARK: - Caption Row

    private var captionRow: some View {
        HStack(alignment: .center) {
            HStack(spacing: 4) {
                AppGlyph.locationPin.image(size: 14, color: Color.text2)
                    .accessibilityHidden(true)
                Text(locationName ?? "Near you")
                    .font(AppFont.chip)
                    .foregroundColor(Color.text2)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if photoCount > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<photoCount, id: \.self) { index in
                        if index == slide {
                            Capsule()
                                .fill(Color.heroSurface)
                                .frame(width: 16, height: 6)
                        } else {
                            Circle()
                                .fill(Color.hairline)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
            }
        }
        .frame(minHeight: 44)
        .padding(.trailing, 104) // Leaves clearance for the 112pt illustration
    }

    // MARK: - Reason Block

    private var reasonBlock: some View {
        let reasonText = hero.reason.isEmpty ? hero.description : hero.reason

        return VStack(alignment: .leading, spacing: 4) {
            Text("Why this place")
                .font(AppFont.tag)
                .foregroundColor(Color.heroText)
                .accessibilityAddTraits(.isHeader)

            Text(LocalizedStringKey(reasonText))
                .font(AppFont.bodyText)
                .foregroundColor(Color.text2)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            if let photoAttribution {
                // "Photo by" prefix, not the bare name: most Places credits are the
                // restaurant's own name (it uploaded the photo), so an unlabelled
                // "Kampung Kecil Abdul Muis" under the reason text reads as a stray
                // string rather than a credit.
                Text("Photo by \(photoAttribution)")
                    .font(AppFont.fineprint)
                    .foregroundColor(Color.text2)
                    .padding(.top, 4)
                    .accessibilityLabel("Photo by \(photoAttribution)")
            }
        }
    }

    // MARK: - Restaurant Details Handoff

    private var googleDetailsRow: some View {
        NavigationLink(value: PlaceDetailItem(hero: hero)) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Restaurant details")
                        .font(AppFont.listTitle)
                        .foregroundColor(Color.text)

                    Text("Photos, hours, reviews and more")
                        .font(AppFont.note)
                        .foregroundColor(Color.text2)
                }

                Spacer()

                AppGlyph.chevronRight.image(size: 20, color: Color.heroText)
            }
            .padding(.top, 12)
            .padding(.bottom, 8)
            .frame(minHeight: 56)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .top) {
                Color.hairline.frame(height: 1)
            }
            // The whole row is the target, not just the words and the chevron.
            // Without this the `Spacer()` between them is a hole: a tap in the middle
            // of the row — the most natural place to aim — hit nothing at all.
            .contentShape(Rectangle())
        }
        .buttonStyle(.pressableRow)
        .padding(.top, 8)
    }
}
