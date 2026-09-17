//
//  LottiePlayer.swift
//  hungrynow
//
//  The one place `Lottie` is imported from a view.
//

import Lottie
import SwiftUI
import UIKit

/// A bundled Lottie animation as a SwiftUI view.
///
/// Named `LottiePlayer` rather than `LottieView` on purpose: lottie-ios 4 ships its
/// own SwiftUI `LottieView`, and shadowing it would make every call site ambiguous
/// depending on what else is in scope. This wraps the imperative
/// `LottieAnimationView` instead of the library's SwiftUI type — that API has been
/// stable across lottie-ios 3 and 4, so a minor-version bump can't quietly change
/// the play/pause semantics underneath us.
///
/// **Why the library is confined to this file.** The project rule is that nothing
/// above the service layer touches a third-party library directly. A view is not a
/// ViewModel, so this isn't the dependency inversion that rule is really about, but
/// the same argument applies for the same reason: if Lottie is ever dropped for
/// native SwiftUI shapes, the swap should be this file plus one call site, not every
/// screen that animates.
struct LottiePlayer: UIViewRepresentable {

    /// Bundle resource name, without the `.json`.
    let name: String

    var loopMode: LottieLoopMode = .loop

    /// False parks the animation on `parkedProgress` instead of playing it. Screen 05
    /// drives this from Reduce Motion.
    var isAnimating: Bool = true

    /// 0...1 through the animation. The frame the animation holds when it isn't
    /// playing — a still that has to read as the same object, not as a half-drawn one.
    var parkedProgress: CGFloat = 0

    /// Lottie keypath -> colour, applied over the JSON's baked colours.
    ///
    /// A Lottie bakes every colour as literal RGBA, which is the one real objection
    /// the mockups raised against using Lottie here ("it matches the palette hexes
    /// exactly" was an argument for hand-built CSS). This is the answer: semantic `Color`
    /// tokens stay the single source of truth and the JSON's values are only a fallback.
    ///
    /// Missing keypaths fail SILENTLY in lottie-ios — wrong colour, no crash, no log.
    /// So these strings are a real contract with the animation's layer names; see
    /// the header of `build-radar-lottie.py`.
    var colorOverrides: [String: Color] = [:]

    func makeUIView(context: Context) -> LottieAnimationView {
        let bundle: Bundle = {
            let moduleBundle = Bundle(for: BundleToken.self)
            if moduleBundle.url(forResource: name, withExtension: "json") != nil {
                return moduleBundle
            }
            return Bundle.main
        }()

        let view = LottieAnimationView(name: name, bundle: bundle)
        view.contentMode = .scaleAspectFit
        // Stop rendering when the app backgrounds and resume where it left off.
        // The default already does this in lottie-ios 4; stated explicitly because a
        // looping animation that keeps ticking off-screen is a battery bug that costs
        // nothing to prevent and is invisible in the Simulator.
        view.backgroundBehavior = .pauseAndRestore
        view.loopMode = loopMode

        for (keypath, color) in colorOverrides {
            guard let lottieColor = color.lottieColorValue else { continue }
            view.setValueProvider(ColorValueProvider(lottieColor),
                                  keypath: AnimationKeypath(keypath: keypath))
        }

        sync(view)
        return view
    }

    func updateUIView(_ view: LottieAnimationView, context: Context) {
        view.loopMode = loopMode
        sync(view)
    }

    private func sync(_ view: LottieAnimationView) {
        if isAnimating {
            guard !view.isAnimationPlaying else { return }
            view.play()
        } else {
            view.pause()
            view.currentProgress = parkedProgress
        }
    }
}

private extension Color {
    /// sRGB components for Lottie's own colour type.
    ///
    /// Nil rather than a black fallback when the conversion fails: a silently wrong
    /// colour is worse than the JSON's baked value, which is at least correct today.
    var lottieColorValue: LottieColor? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return LottieColor(r: Double(r), g: Double(g), b: Double(b), a: Double(a))
    }
}

private final class BundleToken {}

#Preview("Nearby Search") {
    ZStack {
        Color.bg.ignoresSafeArea()
        LottiePlayer(name: "hungrynow-nearby-search-v3")
            .frame(width: 260, height: 260)
    }
    .preferredColorScheme(.light)
}
