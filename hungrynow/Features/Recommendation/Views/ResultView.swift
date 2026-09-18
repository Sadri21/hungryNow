//
//  ResultView.swift
//  hungrynow
//
//  Screen 06 — Hero result. The peak moment.
//  Translated from the vault mockup `output/mockups/screen-06-result.html`.
//

import SwiftUI
import UIKit

/// Screen 06: The answer.
/// Edge-to-edge photo running to the top of the screen under the status bar,
/// a floating Home button, an overlapping card sheet with the `result-restaurant-pin` illustration,
/// clear facts card, permanently visible "Why this place" recommendation reason,
/// numbered local specialties, and a pinned footer with Directions and Try Another.
struct ResultView: View {
    let response: RecommendationResponse

    /// Loaded slides, keyed by index. Sparse — slides arrive as they are swiped to.
    let photos: [Int: HeroPhoto]

    /// How many slides the carousel has. One today; three when `photoRefs` lands.
    let photoCount: Int

    /// The chip in the eyebrow row.
    var locationName: String?

    /// Nil disables Directions. See `DirectionsLink`.
    let directionsURL: URL?

    /// Called with a slide index when it becomes visible, so its photo can be fetched lazily.
    let onSlideAppear: (Int) -> Void

    /// "Try another" discards this answer and asks for a different one.
    let onTryAnother: () -> Void

    /// Returns back to the Home screen.
    let onHome: () -> Void

    /// The hero's fact row: distance, price, rating, in that fixed order.
    var facts: [Fact] = []

    @State private var isViewActive = false
    @State private var slide = 0
    @State private var scrollProgress: Double = 0.0
    @State private var rawScrollOffset: CGFloat = 0.0
    @State private var navigationPath: [PlaceDetailItem] = []
    @Environment(\.colorScheme) private var colorScheme

    /// Resolves the actual device top safe area (status bar / Dynamic Island height).
    /// Prevents SwiftUI from zeroing out the inset when `.ignoresSafeArea()` is active.
    private var safeAreaTop: CGFloat {
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }),
           let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first {
            let inset = window.safeAreaInsets.top
            if inset > 0 { return inset }
        }
        return 59
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            GeometryReader { geo in
                let topInset = safeAreaTop

                ZStack(alignment: .top) {
                    // Background fills entire screen including top safe area
                    Color.bg
                        .ignoresSafeArea(edges: .all)

                    VStack(spacing: 0) {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                ResultMediaHeader(
                                    hero: response.hero,
                                    photos: photos,
                                    photoCount: photoCount,
                                    slide: $slide,
                                    topInset: topInset,
                                    width: geo.size.width,
                                    onSlideAppear: onSlideAppear
                                )

                                ResultSheet(
                                    hero: response.hero,
                                    locationName: locationName,
                                    photoCount: photoCount,
                                    slide: slide,
                                    facts: facts,
                                    photoAttribution: photos[slide]?.attribution
                                )

                                ResultSpecialtiesSection(specialties: response.specialties)
                            }
                            .frame(width: geo.size.width)
                            .trackScrollOffset { offset in
                                guard self.isViewActive else { return }
                                self.rawScrollOffset = offset

                                let scrollOffset = max(0, offset)
                                let headerHeight = max(260, topInset + 220)
                                let photoBottom = headerHeight - scrollOffset
                                let fadeDistance: CGFloat = 60
                                let fadeStart = topInset + fadeDistance

                                let progress: Double
                                if photoBottom >= fadeStart {
                                    progress = 0.0
                                } else if photoBottom <= topInset {
                                    progress = 1.0
                                } else {
                                    progress = Double((fadeStart - photoBottom) / fadeDistance)
                                }

                                self.scrollProgress = progress
                                self.updateStatusBarStyle(offset: offset, progress: progress)
                            }
                        }

                        ResultFooter(
                            directionsURL: directionsURL,
                            onTryAnother: {
                                self.isViewActive = false
                                StatusBarStyleManager.shared.setStyle(nil)
                                self.onTryAnother()
                            }
                        )
                    }
                    .frame(width: geo.size.width)

                    ResultStatusBarBackground(
                        topInset: topInset,
                        width: geo.size.width,
                        opacity: scrollProgress
                    )
                    .zIndex(100)

                    // Persistent floating back button
                    Button(action: {
                        self.isViewActive = false
                        StatusBarStyleManager.shared.setStyle(nil)
                        self.onHome()
                    }) {
                        AppGlyph.chevronLeft.image(size: 20, color: Color.text)
                            .offset(x: -1) // Optical centering for left-pointing chevron
                            .frame(width: 44, height: 44)
                            .background(Color.bg)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 2)
                            // Matches the visible circle, so the whole button is hittable
                            // rather than just the glyph inside it.
                            .contentShape(Circle())
                    }
                    .buttonStyle(.pressableRow)
                    .accessibilityLabel("Back to home")
                    .padding(.top, topInset + 8)
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .zIndex(110)
                }
                .coordinateSpace(name: "resultScreenSpace")
            }
            .ignoresSafeArea(edges: .top)
            .navigationDestination(for: PlaceDetailItem.self) { item in
                let heroImages: [UIImage] = item.isHero
                    ? photos.sorted(by: { $0.key < $1.key }).compactMap(\.value.image)
                    : []
                PlaceDetailsView(item: item, heroImages: heroImages)
            }
        }
        .onAppear {
            isViewActive = true
            updateStatusBarStyle()
        }
        .onDisappear {
            isViewActive = false
            StatusBarStyleManager.shared.setStyle(nil)
        }
        .onChange(of: slide) { _ in
            guard isViewActive else { return }
            updateStatusBarStyle()
        }
        .onChange(of: scrollProgress) { _ in
            guard isViewActive else { return }
            updateStatusBarStyle()
        }
        .onChange(of: rawScrollOffset) { _ in
            guard isViewActive else { return }
            updateStatusBarStyle()
        }
        .onChange(of: photos.count) { _ in
            guard isViewActive else { return }
            updateStatusBarStyle()
        }
        .onChange(of: photos[slide]?.detectedStatusBarStyle) { _ in
            guard isViewActive else { return }
            updateStatusBarStyle()
        }
        .onChange(of: colorScheme) { _ in
            guard isViewActive else { return }
            updateStatusBarStyle()
        }
        .onChange(of: navigationPath) { path in
            if path.isEmpty {
                updateStatusBarStyle()
            } else {
                StatusBarStyleManager.shared.setStyle(colorScheme == .dark ? .lightContent : .darkContent)
            }
        }
    }

    /// Dynamically drives the status bar appearance:
    /// - When pulled down (overscroll): photo pulls down, exposing Color.bg directly behind status bar (black text in light mode).
    /// - When scrolled down into content (scrollProgress >= 0.5): matches `Color.bg` (black text in light mode).
    /// - At the top at rest: adopts the photo's measured luminance style, defaulting to white text over the hero photo.
    private func updateStatusBarStyle(offset: CGFloat? = nil, progress: Double? = nil) {
        guard isViewActive && navigationPath.isEmpty else { return }

        let currentOffset = offset ?? rawScrollOffset
        let currentProgress = progress ?? scrollProgress

        if currentOffset < -2 {
            // Overscroll (pull-down): the hero photo is pulled down, exposing Color.bg directly behind status bar
            let systemStyle: UIStatusBarStyle = (colorScheme == .dark) ? .lightContent : .darkContent
            StatusBarStyleManager.shared.setStyle(systemStyle)
        } else if currentProgress >= 0.5 {
            let systemStyle: UIStatusBarStyle = (colorScheme == .dark) ? .lightContent : .darkContent
            StatusBarStyleManager.shared.setStyle(systemStyle)
        } else {
            if let detected = photos[slide]?.detectedStatusBarStyle {
                StatusBarStyleManager.shared.setStyle(detected)
            } else {
                // Default style on initial load: white status bar over the dark hero photo header
                StatusBarStyleManager.shared.setStyle(.lightContent)
            }
        }
    }
}

// MARK: - Preview

#Preview("Result") {
    ResultView(
        response: RecommendationResponse(
            hero: HeroPick(
                name: "Restoran Nasi Kandar Ar Rashid",
                address: "Jl. Raya Seminyak No. 12",
                reason: "**Come hungry.** Pick your curry at the counter, add a side, and enjoy a generous plate of rice and curry at an open-air table.",
                description: "A casual spot for a generous plate of rice and curry, with plenty to choose from at the counter.",
                foodCategory: "Nasi Kandar",
                phone: nil,
                photoRef: nil,
                placeId: nil,
                latitude: nil,
                longitude: nil,
                rating: 4.7,
                ratingCount: 1530,
                priceLevel: 2,
                photoRefs: nil
            ),
            specialties: [
                SpecialtyPick(name: "Warung Nasi Ibu Oka", address: "Jl. Suweta", reason: "", description: "Balinese roast pork", foodCategory: "Babi Guling", phone: nil, rating: 4.6, ratingCount: 1240, priceLevel: 2),
                SpecialtyPick(name: "Sate Babi Bawah Pohon", address: "Jl. Pantai", reason: "", description: "Grilled pork skewers", foodCategory: "Satay", phone: nil, rating: 4.5, ratingCount: 890, priceLevel: 1),
                SpecialtyPick(name: "Kedai Kopi Bhineka Djaja", address: "Jl. Gajah Mada", reason: "", description: "A stop after your meal", foodCategory: "Coffee", phone: nil, rating: 4.7, ratingCount: 520, priceLevel: 1),
            ]
        ),
        photos: [:],
        photoCount: 1,
        locationName: "Seminyak, Bali",
        directionsURL: nil,
        onSlideAppear: { _ in },
        onTryAnother: {},
        onHome: {},
        facts: [
            Fact(label: "away", value: "400 m"),
            Fact(label: "1.5K reviews", value: "4.9", showsStar: true),
            Fact(label: "per person", value: "IDR 50,000–75,000")
        ]
    )
    .preferredColorScheme(.light)
}
