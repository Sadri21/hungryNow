//
//  Fact.swift
//  hungrynow
//
//  `.fact` — one metric in the facts card.
//

import SwiftUI

/// One fact: a value with a caption naming the field.
///
/// Order is FIXED — distance, rating, price — and callers build the array in that order,
/// skipping any fact whose data is missing rather than substituting a placeholder.
/// The card's whole value is that it scans as one object in one glance, and a card whose
/// columns move between screens does not.
///
/// Rendered by `ResultFactsCard`. A second renderer, `FactRow`, was removed on 2026-09-18:
/// screen 08 was documented as reusing it but `ResultSpecialtiesSection` styles its facts
/// inline, leaving it with no call sites.
struct Fact: Identifiable {
    let label: String
    let value: String

    /// Draws the star glyph beside the value. Belongs to the *rating* fact, not to a
    /// position in the array.
    ///
    /// `ResultFactsCard` used to key the star off `index == 1`, which held only while
    /// every pick had all three facts. Once a missing rating or distance can drop a
    /// column, position stops identifying the fact: a starred price is one omission away.
    var showsStar: Bool = false

    var id: String { label }
}
