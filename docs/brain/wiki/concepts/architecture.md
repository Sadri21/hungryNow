# Architecture

## Folder structure

```
HungryNow/
├── App/                  → entry point + the root router (see "Where routing lives")
│   ├── hungrynowApp.swift → @main
│   └── RootView.swift     → which screen is showing, and anything presented OVER it
├── Features/
│   ├── Welcome/          → screen 02: the welcome + location-purpose screen
│   │   ├── Views/        → WelcomeView, supergraphic band, purpose card
│   │   └── ViewModel/    → asks for location permission via the protocol
│   └── Recommendation/
│       ├── Views/        → hero card, specialty row, button, loading state
│       ├── ViewModel/    → state + calls the service, no UI logic
├── Services/
│   ├── LocationService/       → CoreLocation, isolated behind a protocol
│   └── RecommendationService/
│       ├── RecommendationAPI.swift            → Moya TargetType enum
│       ├── RecommendationServiceProtocol.swift → the abstraction
│       └── RecommendationService.swift         → Moya-backed implementation
├── Models/                → RecommendationResponse, SpecialtyPick, etc.
└── Core/                  → shared utilities, constants, error types
    ├── Theme.swift        → Palette (1:1 with shared.css) + MockupScale
    └── Components/        → cross-screen UI: AppBar, PrimaryButton, SoftBackground, AppGlyphs
```

## Where routing lives (revised 2026-09-09)

**`App/` is entry point *and root router*.** The original line was "entry point only", and this widens it deliberately.

The root view began life as the Xcode template's `ContentView` inside `Features/Recommendation/Views/`, which was harmless while Recommendation was the only feature. Adding screen 02 broke it: `ContentView` had to reference `WelcomeView`, so **Recommendation depended on its sibling Welcome** — a dependency that existed for no reason other than where the router happened to be filed. Sadri caught this by asking whether the root view actually belonged to the feature. It didn't.

It split along the seam that was already there:

- `App/RootView.swift` — the `Route` enum, the transitions between screens, and app-wide appearance. **Global presentation belongs here**: a `.sheet` or `.alert` attached inside a feature view is torn down with that view when the route changes, and two features cannot coordinate one between them.
- `Features/Recommendation/Views/RecommendationView.swift` — only the feature's own `idle / loading / loaded / failed` switch.

**The rule this establishes:** features never import each other. Only `RootView` knows more than one. Screens 07-09 and the undecided `daily_limit_reached` state each become one more `Route` case, not another cross-feature reference.

The rejected alternative was inlining routing into the `@main` struct to keep `App/` literally entry-point-only. That preserves the words at the cost of the thing they were protecting, and gets unreadable by the fourth screen.

## Core/Components: shared UI is a Core concern (2026-09-09)

`Core/` was specified as "shared utilities, constants, error types" — no views. Building screen 04 forced the issue, and the widening is deliberate.

`shared.css` treats `.appbar`, `.softbg`, `.btn-primary` and the glyph set as **one shared set across screens 04-09**, and unifying them was its own recorded design pass — three near-identical headers collapsed into one bar on 2026-09-07. Rebuilding any of them per screen in SwiftUI would recreate exactly the drift that pass removed, and the mockups would stop being the source of truth the moment the second copy appeared.

They cannot live in a feature, either: screen 07 (permission denied) is location's business, 04-06 are recommendation's, and they all draw the same bar. A component owned by one feature and used by another is the dependency the `RootView` split just removed.

So: **`Core/Components/` holds UI shared across features.** Anything used by exactly one feature stays in that feature (`PurposeCardShape` is screen 02's alone and stays private to `WelcomeView`).

The glyph set is the load-bearing case. `shared.css` states the rule directly — every glyph on the same grid, same stroke weight, drawn from **one** set, never two hand-made ones that drift. `LocationPinShape` was already private inside `WelcomeView` when screen 04's location chip needed the same pin; that is precisely how a second set starts. It moved to `Core/Components/AppGlyphs.swift`, and `AppGlyph` is an enum rather than a generic view slot so a screen cannot quietly pass in a one-off.

**Two pin shapes coexist on purpose (2026-09-09). Do not "fix" this without asking.** A bundled glyph asset, `glyph-location-pin.imageset`, now draws the app bar's location chip. It supersedes the traced `LocationPinShape` on geometry grounds — straight tangent flanks and an explicit 1.5-unit tip arc instead of a cusp, which at 10pt under a 2.4 stroke read as a spike, and which finally makes the in-app pin and the app icon **one shape at two sizes**. The asset's own header calls it a drop-in swap for all eight screens that draw a pin.

Sadri deliberately scoped the swap to the chip only. **Screen 02's purpose card still draws the old traced `LocationPinShape`**, which is why that type still exists in `AppGlyphs.swift`. So the one-icon-set rule is knowingly broken in one place, by decision, not by drift — a future session should not silently unify them.

Two mechanical notes for whenever it is unified. The imageset needs **`template-rendering-intent: "template"`**: the SVG strokes with `currentColor`, Xcode does not resolve that against a SwiftUI foreground, and without the template intent the glyph renders black regardless of `.foregroundColor`. And the traced-path call sites carry a **stroke-weight bug** the asset does not — the mockups' `stroke-width` is in *viewBox units on the 24 grid*, not in mockup px, so `lineWidth: m.px(2.4)` in an `m.px(10)` frame is a 0.24 stroke-to-size ratio against the correct 0.1. The chip was ~2.4x too heavy before the swap; screen 02's card is still ~1.7x too heavy (`m.px(2)` in an `m.px(14)` frame, 0.143 against 0.083).

## Navigation: flat replacement now, one stack later (open, 2026-09-09)

`RootView` swaps screens with a `switch` on a `Route` enum. There is no `NavigationStack` anywhere yet. Sadri asked why — a fair challenge, and the answer splits in two.

**Where replacement is correct, and a push would be wrong:**

- **Welcome → the app is one-way.** Screen 02 is explicitly "no way to dismiss past it". A `NavigationStack` push is a *reversible* relationship by definition and ships a back button plus an interactive edge-swipe with it. Making it behave would mean `.navigationBarBackButtonHidden(true)` and killing the swipe — fighting the component into pretending it is not what it is. A back affordance leading to completed onboarding is a promise the app cannot keep.
- **Screens 07-09 replace, they do not stack.** Permission-denied, no-results and network-error are the screen the app *is in*, not places you drill into and pop out of. Pushing them builds a stack to unwind by hand on every retry, and "back" from no-results would land on a stale searching screen.
- **The product is deliberately not hierarchical** — a decision tool, not a directory. A navigation stack is the component for drilling into hierarchical content, and there is none here.

**Where a push is probably right, and the current design is weaker for lacking it:**

**Screen 04 → 06 (home → result) is a genuine navigation edge** and was wrongly lumped in with the rest. You arrive at a result *from* home and should be able to leave it. This is already an open checklist item — 06 has no back affordance, and `apple-hig-inputs.md` → Gestures requires a non-gesture alternative to the edge swipe. A `NavigationStack` around that one edge answers it with the system's own back button, swipe and transition, instead of hand-building a back control onto the one screen whose design point was shedding chrome.

**Proposed shape, not yet built:** a hybrid. `RootView` stays a flat switch for app-level state (welcome, the error states); a `NavigationStack` lives *inside* the Recommendation feature for home → result. That also keeps the layering honest — that navigation is the feature's own business, not the shell's.

**Deferred deliberately.** Screens 04 and 06 exist in SwiftUI only as placeholder states (`HungryButtonView`, `HeroCardView`), not as ports of the mockups. Wiring navigation onto placeholders would be rework, so this gets decided when 04 and 06 are actually built — and it should be settled *before* 06's back-affordance item is closed, since the stack may close it for free.

**Unrelated but adjacent, so it does not get misdiagnosed as a navigation problem:** the welcome → recommendation swap currently has *no transition at all*, an instant cut. The fix is `withAnimation` plus a `.transition()`, not a `NavigationStack`.

## The one rule that matters

ViewModels depend only on protocols (`RecommendationServiceProtocol`, a location-service protocol), never on concrete implementations or third-party libraries directly. This is Dependency Inversion — it's what lets networking libraries, data sources, or AI providers get swapped later without touching UI or business logic, and it's what makes this codebase genuinely "AI-scalable" rather than just claiming to be.

## Networking

Using [[moya]] as the abstraction over Alamofire. One `TargetType` case for now (`getRecommendation`); Moya's value compounds once more endpoints are added.

## Google credential boundary (revised 2026-09-16)

[[firebase-cloud-functions]] holds the [[gemini-api]] key and the **server-side Google Places REST/web-service key**. Those credentials are secrets and must never enter the client app.

Screen 6A's `GooglePlacesSwift.PlaceDetailsView` is a client SDK and cannot run through the Firebase proxy. It therefore uses a **separate iOS Places SDK key** supplied to `PlacesClient.provideAPIKey(_:)`. This client key is not the backend key and must be restricted in Google Cloud to HungryNow's exact iOS bundle identifier and only the Places SDK for iOS / Places API (New), then protected with Firebase App Check, client-specific quotas, monitoring, and billing alerts. Keep the raw value out of Git via an ignored `Secrets.xcconfig`; understand that any client key can still be extracted from the compiled app, so restrictions—not file placement—are the security boundary.

**Current decision:** use one dedicated restricted iOS key while development and production share the same bundle identifier. Split into separate development and production keys only when separate bundle IDs/environments exist or independent rotation, quota, and monitoring become useful. Never reuse either key across the client/server boundary.
