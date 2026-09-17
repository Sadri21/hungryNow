//
//  ScreenTransition.swift
//  hungrynow
//
//  Shared vocabulary for full-screen swaps. Lives in Core because both the app shell
//  (`App/RootView.swift`, routing between features) and the recommendation feature
//  (`RecommendationView`, switching between its own six states) animate the same way,
//  and the motion should not drift between them.
//

import SwiftUI

/// The house style for replacing one whole screen with another.
///
/// Per the vault's Motion rules (`wiki/concepts/visual-identity.md`): a brief
/// scale-and-fade "pop" from 98%, degrading to a plain crossfade under Reduce Motion.
enum ScreenTransition {

    /// Asymmetric because the two halves overlap: the outgoing screen is still on top
    /// while the incoming one grows in. Scaling both would read as a zoom-through rather
    /// than a replacement, so only the arrival scales; the departure just fades.
    static func transition(reduceMotion: Bool) -> AnyTransition {
        guard !reduceMotion else { return .opacity }

        return .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.98)),
            removal: .opacity
        )
    }

    /// 0.28s sits inside the vault's ≈0.2-0.3s window for the reveal. Reduce Motion keeps
    /// a shortened crossfade rather than dropping to zero — an instant swap is the thing
    /// being fixed, and a fade carries no motion to be sensitive to.
    static func animation(reduceMotion: Bool) -> Animation {
        reduceMotion
            ? .easeInOut(duration: 0.2)
            : .easeOut(duration: 0.28)
    }
}

extension View {

    /// Isolates a subtree's geometry from an animating ancestor, so the whole screen
    /// scales as one rendered unit rather than re-laying-out at every intermediate size.
    ///
    /// Matters because every screen here is rooted in a `GeometryReader`, which would
    /// otherwise republish a changing size to its children on each frame of a scale.
    ///
    /// Split out as a modifier because the availability branch cannot live inline in a
    /// `ViewBuilder` chain without changing the returned type on each path.
    @ViewBuilder
    func screenGeometryGroup() -> some View {
        if #available(iOS 17.0, *) {
            geometryGroup()
        } else {
            transformEffect(.identity)
        }
    }
}
