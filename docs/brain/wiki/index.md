# Index — HungryNow Wiki

Master catalog. Update this whenever a page is added or removed.

This vault tracks what is specific to HungryNow. General, reusable design and
technique research that informed it is **deliberately not included** — the decisions
those pages produced are recorded here in full, which is what the app is built on.
Where a page mentions reference material that is not in this vault, that is
intentional and not a missing file.

## Concepts
- [[product-overview]] — what the app is, positioning, target user
- [[architecture]] — SOLID structure, folder layout, dependency rules
- [[api-contract]] — fixed JSON request/response contract for both Cloud Functions, reference for iOS `Models/` layer
- [[visual-identity]] — "Pomegranate & Pistachio" (primary) / "Rust & Mustard" (swappable backup) color, type, icon, and motion spec for the "Visual polish pass" checklist item (revised 2026-09-04, twice — see the page's Revision history for "Night Ledger" → "Golden Hour" → final)
- [[portfolio-art-direction]] — closes three of [[visual-identity]]'s open gaps (photography treatment, capture palette/appearance, app icon motif) and answers "how does this become an eye-catching portfolio piece" — including why the Pinterest-reference look is structurally unreachable here and why looking *shipped* beats looking beautiful for a developer's portfolio
- [[reference-adoption]] — the filter turning Sadri's eight collected UI references into per-screen decisions: adopt (systematised metric chips, inline read-more, inverted specialty chips, value-hierarchy, clipped scroll hint, text-driven shapes), reject (glassmorphism, gradients, neumorphism, serif, AI imagery, decorative encodings), one decision still open (screen 02 mosaic vs illustration), plus a pre-ship defect checklist derived from what 6-8 of the eight references got wrong
- [[app-mockups]] — HTML mockups of the first-run flow (launch → welcome → permission → home → loading → result), the per-screen editing model, illustration prompt rules, and what's still open. Read before touching anything in `output/mockups/`.

## Artwork on disk (not wiki pages — catalogued here so they're findable)

- `output/mockups/` — the nine first-run screen mockups. See [[app-mockups]].
- `output/mockups/glyph-location-pin.svg` — the location-pin interface glyph, rounded tip, added 2026-09-09. Replaces the cusped pin still inlined in eight screens and in `LocationPinShape`; construction and the swap caveat (screen 07's two partial pins) are in the file's comment and in [[log]].
- `output/ios-assets/` — **shipping** Xcode asset-catalog folders, added 2026-09-09. Distinct from `output/mockups/`, which holds mockup-only rasters.
  - `WelcomeSupergraphic.imageset/` — the screen-02 band as vector: `welcome-supergraphic.svg` (the asset), `welcome-supergraphic.pdf` (fallback if Xcode's SVG support misbehaves), single-scale `Contents.json` with `preserves-vector-representation`. **Do not add PNG scales back** — the reasoning is in [[app-mockups]] → "Ship as vector, not as @1x/@2x/@3x PNGs", including the band-height formula (`width × 0.826`) the layout depends on. Dark Mode variant still open.
  - `HomeIllustration.imageset/` — screen 04's centred figure as vector, traced from `illustration-home-crossroads-fullres.png`. Alpha preserved (it floats on the `.softbg` circles). **Known and accepted:** the wheels' tonal rings are flattened — invisible at the 216–260pt display size, findable past ~2× zoom. See [[app-mockups]] → "The home illustration vectorises too" before reusing this art large.
  - `quantize-supergraphic.py` + `vectorize-supergraphic.py` — regenerate the supergraphic SVG from `output/mockups/welcome-supergraphic.png`. Run them rather than hand-editing the SVG; the two anti-halo steps are easy to lose.
  - `vectorize-illustration.py` — the outlined-illustration tracer (`<src> <out.svg>`); covers the home figure and would cover the other illustrations. Note it traces ink at its **core**, unlike the supergraphic script — see [[app-mockups]] for why fattening the ink ruins thin strokes.
- `output/ios-assets/svg-path-to-swift.py` — converts a mockup glyph's SVG `d` attribute into SwiftUI `Path` code, added 2026-09-09. **Use it for every glyph port.** It does the SVG endpoint-to-centre arc conversion, which is the thing `LocationPinShape`'s comment warns about: SwiftUI's `addArc` is centre-parameterised and its `clockwise` flag reads backwards in the flipped coordinate space, so hand-converting an `A` command flips shapes silently. Reuses the radar generator's path parser rather than adding a second one. **Render the result against the original before trusting it** — a flipped sweep flag turns a bowl upside down and is invisible in the numbers.
- `output/ios-assets/radar-lottie/` — screen 05's searching animation, added 2026-09-09.
  - `build-radar-lottie.py` — **the generator.** Transcribes the CSS keyframes in `output/mockups/screen-05-loading.html` into `radar-sweep.json`. Read its header before editing the animation: it records the three places the CSS does not survive translation (Lottie has no conic gradient; the pulse rings' size; constant stroke weight) and why each departure is deliberate. Regenerate, don't hand-edit the JSON.
  - `radar-sweep.json` — the shipping animation. Lives in the app at `hungrynow/Resources/radar-sweep.json`; this is the copy of record. Layer names are a **contract** with `RadarPalette` in the app — a rename breaks the runtime palette override silently.
  - `radar-preview.html` — plays the real JSON in lottie-web, with an offline frame strip beside it. Open this before accepting any change to the animation.
  - `preview-radar.py` — renders one frame of the JSON to SVG with no dependencies. A checking tool for the subset the generator emits, not a Lottie player; it is what caught the antialiasing seams in the first build of the sweep.
- `output/icon/` — app icon artwork, added 2026-09-08. Reasoning and the rejected-shape list live in [[portfolio-art-direction]] → Decision 3 and its two *Revised 2026-09-08* blocks; **read those before editing any of these files.**
  - `app-icon-mockup.html` — self-contained page: all four candidates side by side, the 29pt size ladder with its measured budget table, the four appearance variants, a Home Screen placement, and tiles for the shapes that were drawn and rejected. No external dependencies.
  - `app-icon-foreground-fork-clock-pin.svg` — **three components** (tines/food + clock counter/time + taper/place), the version Sadri asked for
  - `app-icon-foreground-fork-pin.svg` — **two components**, and the more robust mark: no counter at all, so nothing to go opaque-wrong in the tinted/clear variants
  - `app-icon-foreground-bowl-ping.svg` — food-forward alternative; drops "near me"
  - `app-icon-foreground-pin-arc.svg` — the superseded 2026-09-07 motif, kept as the fallback
  - `app-icon-foreground-pin-only.svg` — bare pin, single shape
  - `hungrynow-bowl-now-concept-2026-09-11.png` — new flat, single-continuous-shape concept: bowl + clock/spiral + bite notch; created as a visual exploration, not a replacement for the selected Icon Composer artwork
  - `hungrynow-bowl-now-transparent-2026-09-11.png` — transparent-background PNG of the bowl + clock exploration, for placing over a separate Icon Composer background
  - `hungrynow-bowl-clock-pin-app-icon-2026-09-11.png` — flat app-icon exploration that replaces the clock hand with a location pin, retaining the food bowl, clock ring, and bite notch
  - `hungrynow-bowl-clock-pin-transparent-2026-09-11.png` — RGBA transparent-background version of the bowl + clock + location-pin exploration
  - `hungrynow-bowl-clock-pin-dark-on-white-2026-09-11.png` — dark aubergine bowl + clock + pin variation on white, with a pomegranate steam accent
  - `AppIcon-BowlClockPin.appiconset/` — ready-to-import iOS set for the bowl + clock + location-pin mark: 1024×1024 Default/Any, Dark, and Tinted variants; every PNG has an opaque background
  - All the `.svg` files are Icon Composer **foreground** layers: transparent ground by design, since the blush background is a separate layer. Geometry is derived, not eyeballed — **import them, don't re-trace.** Which mark ships is still Sadri's open pick (see `checklist.md`).
  - `AppIcon.appiconset/` — drop-in Xcode asset catalog set for the three-component mark (exported 2026-09-10): `AppIcon-Any.png` (opaque, no alpha), `AppIcon-Dark.png` and `AppIcon-Tinted.png` (both transparent-ground; tinted is grayscale), all 1024×1024, with `Contents.json` already wired for the `luminosity` appearances. **This is the pre-Icon-Composer path** — it works, but gets none of the Liquid Glass layering the `.icon` build was chosen for.

## Entities
_(each of these is trimmed to HungryNow-specific details — general facts moved to the main vault's `wiki/entities/tools/`)_
- [[firebase-cloud-functions]]
- [[gemini-api]]
- [[google-places-api]]
- [[moya]]

## Synthesis
- [[places-api-vs-openstreetmap]] — HungryNow's decision; general comparison moved to main vault

## Gaps
- [[gaps]] — known-but-undocumented areas and open items, reviewed periodically

## Log
- [[log]] — chronological record of decisions. Kept short (recent sessions only)
- [[log-archive]] — pre-2026-09-08 sessions, rotated out to keep the active log cheap to read every session. Full history, open on demand

## Sources
_(empty for now — add one page per external reference doc as you consult them)_
