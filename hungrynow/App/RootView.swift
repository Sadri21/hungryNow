//
//  RootView.swift
//  hungrynow
//
//  The app shell: what is on screen, and anything presented OVER it.
//
//  Was `ContentView` in Features/Recommendation/Views/. That put app-wide routing
//  inside a feature, and once the welcome screen arrived it forced Recommendation to
//  reference its sibling Welcome — a dependency that existed only because the router
//  happened to be filed there. Features now know nothing about each other; only this
//  file knows both.
//

import CoreLocation
import SwiftUI

struct RootView: View {

    /// Full-screen destinations.
    ///
    /// An enum rather than a `hasSeenWelcome` flag because the flow already has more
    /// than two states waiting: screens 07-09 (permission denied, no results, network
    /// error) are routes, not variations of the recommendation screen. Adding a case here
    /// should be the whole cost of a new screen. (`daily_limit_reached` was settled as a
    /// `NetworkErrorVariant` rather than a route, since it reuses screen 09's layout.)
    private enum Route: Hashable {
        case welcome
        case recommendation
        case locationDenied
    }

    /// Local for now. Whether passing the welcome screen should survive a relaunch is a
    /// first-run question that belongs with the permission-denied routing (screen 07).
    @State private var route: Route = .welcome
    private let locationService: LocationServiceProtocol = LocationService()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Route changes are animated here rather than at each call site, so every caller
    /// below stays a plain assignment and no route can be changed without its animation.
    private func go(to destination: Route) {
        guard destination != route else { return }

        withAnimation(ScreenTransition.animation(reduceMotion: reduceMotion)) {
            route = destination
        }
    }

    var body: some View {
        Group {
            switch route {
            case .welcome:
                WelcomeView { status in
                    switch status {
                    case .denied, .restricted:
                        go(to: .locationDenied)
                    default:
                        go(to: .recommendation)
                    }
                }

            case .recommendation:
                RecommendationView()

            case .locationDenied:
                LocationOffView(
                    onCheckPermission: {
                        let status = locationService.authorizationStatus
                        if status == .authorizedWhenInUse || status == .authorizedAlways {
                            go(to: .recommendation)
                        }
                    }
                )
            }
        }
        // Same wiring, and the same reasoning, as `RecommendationView`: `.id` sits under
        // `.transition` so the identity change marks the route's screen as the thing
        // inserted/removed, while the transition above it describes how. The animation
        // itself comes from the explicit `withAnimation` in `go(to:)` — an implicit
        // `.animation(_:value:)` does not create a transaction the transition can use.
        .id(route)
        .screenGeometryGroup()
        .transition(ScreenTransition.transition(reduceMotion: reduceMotion))
        // GLOBAL PRESENTATION BELONGS HERE, not inside a feature view. A `.sheet` or
        // `.alert` attached inside a feature is torn down with that feature when the
        // route changes, and two features cannot coordinate one between them. Anything
        // app-wide — a sheet, a confirmation dialog, a full-screen cover — hangs off
        // this Group so it outlives whichever screen is showing.
    }
}

#Preview {
    RootView()
}
