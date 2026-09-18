//
//  RecommendationView.swift
//  hungrynow
//
//  Created by Asa Teknologi on 02/09/26 as ContentView; renamed and reduced to the
//  feature's own screen when routing moved to App/RootView.swift.
//

import Combine
import SwiftUI

/// The recommendation feature's screen: the "I'm Hungry" button and the three states
/// it can lead to. Knows nothing about onboarding, routing, or any other feature.
struct RecommendationView: View {
    @StateObject private var viewModel = RecommendationViewModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Which screen is showing — the view's OWN copy, and what the body switches on.
    ///
    /// The body cannot switch on `viewModel.state` directly. A `@Published` change
    /// rebuilds the body wholesale, and `.animation(_:value:)` keyed on a value computed
    /// during that rebuild has no earlier value to interpolate from, so no animated
    /// transaction is ever created — the screens just snap.
    ///
    /// Mirroring the state into local `@State` that is written inside `withAnimation`
    /// puts the change on a transaction the view owns. The ViewModel still knows nothing
    /// about presentation.
    @State private var screen: Screen = .idle

    var body: some View {
        // No wrapping VStack. Screens 04 and 05 are whole screens — they bring their own
        // app bar, background and bottom inset — so a shared container's spacing would
        // fight them. The two states that are still placeholders keep their own.
        //
        // The Group exists only to hang the transition wiring off. It adds no layout of
        // its own, so the screens below still own their full frame.
        Group {
            switch screen {
            case .idle:
                HomeView(
                    locationName: viewModel.locationName,
                    onFindPlace: viewModel.findFood
                )
                .task { viewModel.resolveLocationName() }

            case .loading:
                SearchingView(
                    locationName: viewModel.locationName,
                    stage: viewModel.searchStage,
                    onCancel: viewModel.cancelSearch
                )

            case .loaded(let response):
                ResultView(
                    response: response,
                    photos: viewModel.heroPhotos,
                    photoCount: viewModel.heroPhotoCount(for: response.hero),
                    locationName: viewModel.locationName,
                    directionsURL: DirectionsLink.appleMaps(
                        latitude: response.hero.latitude,
                        longitude: response.hero.longitude,
                        name: response.hero.name
                    ),
                    onSlideAppear: { viewModel.loadHeroPhoto(at: $0, of: response.hero) },
                    // "Try another" discards this answer and asks for a different one, which
                    // is a fresh search — NOT a retry of a failed request. Same call as the
                    // Home button, deliberately: the flow returns to screen 05 and comes back
                    // with a different pick.
                    onTryAnother: viewModel.findFood,
                    onHome: viewModel.resetToHome,
                    facts: viewModel.heroFacts(for: response.hero)
                )

            case .locationDenied:
                LocationOffView(
                    onCheckPermission: {
                        viewModel.checkLocationPermission()
                    }
                )

            case .noResults:
                NoResultsView(
                    locationName: viewModel.locationName,
                    onRetry: viewModel.findFood
                )

            case .networkError(let variant):
                NetworkErrorView(
                    variant: variant,
                    locationName: viewModel.locationName,
                    onRetry: viewModel.findFood,
                    onHome: viewModel.resetToHome
                )
            }
        }
        // `.id` sits UNDER `.transition` deliberately. Modifiers apply inside-out, so
        // the identity change marks the screen itself as inserted/removed while the
        // `.transition` above it stays attached to describe how.
        .id(screen)
        // Keeps each screen's geometry from being re-read mid-animation, so the content
        // scales as one unit rather than re-laying-out at every intermediate size.
        .screenGeometryGroup()
        .transition(screenTransition)
        // The animation comes from the `withAnimation` below, not from
        // `.animation(_:value:)`. Keying an implicit animation off the ViewModel's state
        // does not work here: a `@Published` change rebuilds the body wholesale, and the
        // modifier sees the new value already in place with nothing to interpolate from.
        //
        // Receiving the publisher and assigning inside `withAnimation` creates an
        // explicit transaction that the transition above can attach to. This lives in
        // the View, so the ViewModel still holds no presentation logic.
        .onReceive(viewModel.$state) { newState in
            let next = Self.screen(for: newState)
            guard next != screen else { return }

            withAnimation(transitionAnimation) {
                screen = next
            }
        }
    }

    // MARK: - Transition

    /// Which screen is showing, plus whatever that screen needs to render.
    ///
    /// `Hashable` because `.id()` requires it, and hand-written rather than synthesized
    /// for two reasons. `RecommendationResponse` is not `Hashable`, and identity here is
    /// deliberately per-CASE only: a hero photo landing mid-result must not look like a
    /// new screen and re-run the transition. (`ResultView` still updates when photos
    /// arrive — it reads `viewModel.heroPhotos` directly, so `@Published` re-renders it
    /// without touching this token.)
    private enum Screen: Hashable {
        case idle
        case loading
        case loaded(RecommendationResponse)
        case locationDenied
        case noResults
        case networkError(NetworkErrorVariant)

        private var hashKey: String {
            switch self {
            case .idle: return "idle"
            case .loading: return "loading"
            case .loaded: return "loaded"
            case .locationDenied: return "locationDenied"
            case .noResults: return "noResults"
            case .networkError(.offline): return "networkError.offline"
            case .networkError(.serviceUnavailable): return "networkError.serviceUnavailable"
            case .networkError(.dailyLimitReached): return "networkError.dailyLimitReached"
            }
        }

        static func == (lhs: Screen, rhs: Screen) -> Bool {
            lhs.hashKey == rhs.hashKey
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(hashKey)
        }
    }

    /// Collapses the ViewModel's state to the screen token the body renders.
    private static func screen(for state: RecommendationViewModel.State) -> Screen {
        switch state {
        case .idle: return .idle
        case .loading: return .loading
        case .loaded(let response): return .loaded(response)
        case .locationDenied: return .locationDenied
        case .noResults: return .noResults
        case .networkError(let variant): return .networkError(variant)
        }
    }

    private var screenTransition: AnyTransition {
        ScreenTransition.transition(reduceMotion: reduceMotion)
    }

    private var transitionAnimation: Animation {
        ScreenTransition.animation(reduceMotion: reduceMotion)
    }

}

#Preview {
    RecommendationView()
}
