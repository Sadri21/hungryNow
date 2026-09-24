//
//  AppBar.swift
//  hungrynow
//
//  ONE bar for every in-app screen (04, 05 and the edge states 07-09), so the top of the
//  app never shifts as you move through it.
//  Updated per vault redesign `output/mockups/redesign.css` and `screen-04-home.html`.
//

import SwiftUI

/// The `hungrynow.` brand mark matching `screen-04-home.html` and `redesign.css`.
struct WordmarkView: View {
    var size: CGFloat = 22

    var body: some View {
        HStack(spacing: 0) {
            Text("hungry")
                .foregroundColor(Color.text)
            Text("now")
                .foregroundColor(Color.heroSurface)
            Circle()
                .fill(Color.heroSurface)
                .frame(width: 5, height: 5)
                .padding(.leading, 2)
                .padding(.bottom, 2)
        }
        .font(.system(size: size, weight: .bold))
        .tracking(-1.1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("hungrynow")
    }
}

/// The top bar: Wordmark or Screen Title leading, location status trailing.
struct AppBar: View {
    var title: String? = nil
    var locationName: String?

    var body: some View {
        HStack(spacing: Metrics.space2) {
            if let title, title.lowercased() != "hungrynow" {
                Text(title)
                    .font(AppFont.barTitle)
                    .foregroundColor(Color.text)
                    .fixedSize()
            } else {
                WordmarkView()
            }

            Spacer(minLength: Metrics.space2)

            LocationChip(name: locationName ?? "Near you")
        }
        .frame(height: 48)
    }
}

/// `.location` — the clean location context row matching `redesign.css`.
/// Consists of a 16pt pin glyph and location text in `Color.text2`.
struct LocationChip: View {
    let name: String

    @ScaledMetric(relativeTo: .caption) private var pinSize: CGFloat = 16

    var body: some View {
        HStack(spacing: 4) {
            Image("glyph-location-pin")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: pinSize, height: pinSize)
                .foregroundColor(Color.text2)
                .accessibilityHidden(true)

            Text(name)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color.text2)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AppBar(locationName: "Seminyak, Bali")
        AppBar(locationName: nil)
        AppBar(title: "Searching", locationName: "Seminyak, Bali")
    }
    .padding()
    .background(Color.bg)
}
