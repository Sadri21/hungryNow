//
//  PressableRowStyle.swift
//  hungrynow
//
//  The press feedback for tappable rows that navigate somewhere.
//

import SwiftUI

/// Scales in and dims slightly while held, springs back on release.
///
/// A `ButtonStyle` rather than a `.onTapGesture` + `@State` pair at each call site:
/// `configuration.isPressed` already tracks the real touch, including the drag-off
/// cancel that a tap gesture gets wrong — slide your finger off a row mid-press and
/// this releases correctly instead of staying stuck in the pressed state.
///
/// **`.plain` is not enough on its own.** SwiftUI's `.plain` button style deliberately
/// applies no press feedback at all, so every row using it looked inert on tap. This
/// replaces it where a row leads somewhere.
///
/// The numbers are deliberately restrained: a row is a large target, and a large view
/// scaling by the ~0.94 a small button can take reads as a lurch. 0.97 with a light
/// dim is the standard iOS card-tap feel.
struct PressableRowStyle: ButtonStyle {

    /// How far the row scales in while held.
    var pressedScale: CGFloat = 0.97

    /// How much it dims while held.
    var pressedOpacity: Double = 0.7

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .opacity(configuration.isPressed ? pressedOpacity : 1)
            // Springs rather than eases: the release should feel elastic, and a spring
            // also handles an interrupted press (tap again mid-animation) without the
            // visible jump an `easeOut` gives when it restarts from a partial value.
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableRowStyle {

    /// Press feedback for a row that navigates somewhere. See `PressableRowStyle`.
    static var pressableRow: PressableRowStyle { PressableRowStyle() }

    /// Press feedback for a small inline control (the "Details" / "Directions" pair on a
    /// specialty row). Scales a touch further than a full-width row, because a small
    /// label needs more movement to read as pressed at all.
    static var pressableInline: PressableRowStyle {
        PressableRowStyle(pressedScale: 0.94, pressedOpacity: 0.6)
    }
}
