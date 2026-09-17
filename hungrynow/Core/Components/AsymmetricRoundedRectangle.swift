//
//  AsymmetricRoundedRectangle.swift
//  hungrynow
//
//  A rounded rectangle with a different radius per corner.
//

import SwiftUI

/// Per-corner radii.
///
/// `UnevenRoundedRectangle` does this in one line and is **iOS 17**; the deployment
/// target is 16.0.
///
/// Exists because the radius language is a real rule, not decoration:
/// **one large corner, on the side facing what the surface overlaps.** Screen 06's sheet
/// bleeds left, right and down, so its only free edge is the top and it carries 28 there
/// (top-trailing) against 14 top-leading.
///
/// **Known duplication:** `WelcomeView.PurposeCardShape` predates this and does the same
/// job for screen 02's card, with `addQuadCurve` rather than a true arc — a parabolic
/// corner, which reads tighter than a circular one at a large radius. The two should be
/// reconciled onto this type, but screen 02 is not in scope here and silently changing its
/// corner curvature would be exactly the kind of drift the vault keeps catching.
struct AsymmetricRoundedRectangle: Shape {
    var topLeading: CGFloat = 0
    var topTrailing: CGFloat = 0
    var bottomTrailing: CGFloat = 0
    var bottomLeading: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        // Clamp so a radius larger than the box can't invert the outline — which happens
        // in practice here, because the sheet's band is only 40 mockup px tall.
        let limit = min(rect.width, rect.height) / 2
        let tl = min(topLeading, limit)
        let tr = min(topTrailing, limit)
        let br = min(bottomTrailing, limit)
        let bl = min(bottomLeading, limit)

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))

        // True circular corners via arc-to-point: the corner is the tangent vertex, so
        // each call is "come in along this edge, leave along the next".
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
                    tangent2End: CGPoint(x: rect.maxX, y: rect.minY + tr), radius: tr)

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
                    tangent2End: CGPoint(x: rect.maxX - br, y: rect.maxY), radius: br)

        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
                    tangent2End: CGPoint(x: rect.minX, y: rect.maxY - bl), radius: bl)

        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
                    tangent2End: CGPoint(x: rect.minX + tl, y: rect.minY), radius: tl)

        path.closeSubpath()
        return path
    }
}
