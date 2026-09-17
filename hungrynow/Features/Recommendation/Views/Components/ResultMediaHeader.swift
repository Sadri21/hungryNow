//
//  ResultMediaHeader.swift
//  hungrynow
//
//  Screen 06 — Hero photo carousel with floating Home button and photo fallbacks.
//

import SwiftUI

/// Edge-to-edge hero media header for Screen 06.
/// Runs under the status bar to the top of the screen with a floating Home button.
struct ResultMediaHeader: View {
    let hero: HeroPick
    let photos: [Int: HeroPhoto]
    let photoCount: Int
    @Binding var slide: Int
    let topInset: CGFloat
    let width: CGFloat
    let onSlideAppear: (Int) -> Void

    var body: some View {
        let height = max(260, topInset + 220)

        Group {
            if photoCount > 1 {
                TabView(selection: $slide) {
                    ForEach(Array(0..<photoCount), id: \.self) { index in
                        slideView(index: index, width: width, height: height)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            } else {
                slideView(index: 0, width: width, height: height)
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .onChange(of: slide) { onSlideAppear($0) }
        .onAppear { onSlideAppear(0) }
    }

    @ViewBuilder
    private func slideView(index: Int, width: CGFloat, height: CGFloat) -> some View {
        // No `AsyncImage` fallback branch, deliberately: `loadHeroPhoto(at:of:)` publishes
        // a `HeroPhoto` only once its bytes are downloaded and decoded, so `image` is
        // never nil here. The old URL-only branch fetched the same file a second time —
        // see the comment on that method.
        if let uiImage = photos[index]?.image {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
                .clipped()
                .accessibilityLabel("Photo of \(hero.name)")
        } else {
            photoFallback(width: width, height: height)
        }
    }

    private func photoFallback(width: CGFloat, height: CGFloat) -> some View {
        let glyph = AppGlyph.forCategory(hero.foodCategory)

        return Color.specFill
            .frame(width: width, height: height)
            .overlay(
                glyph.image(size: 56, color: Color.specText)
            )
            .accessibilityLabel("No photo available for \(hero.name)")
    }
}
