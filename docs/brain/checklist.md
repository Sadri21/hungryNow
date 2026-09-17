# Build Checklist

## Next up — decided 2026-09-17

The app is functionally complete end to end: 49 Swift files, all nine screens ported, backend filtering by opening hours, full field passthrough. What remains is compliance, verification, and shipping-hygiene — not features.

1. ~~**Photo attribution (compliance blocker)**~~ — **DONE and verified on device 2026-09-17.** Credit renders under the hero photo as "Photo by <name>". Root cause of the long debug: a missing cache-staleness guard, now added. See log.
2. ~~**Replace screen 06 slide 2**~~ — **resolved, no work needed.** The watermarked foodpanda placeholder exists only in `output/mockups/archive-before-2026-09-10/`; the Sept 10 redesign dropped it, and it was never in the app (the real carousel fetches Places photos via `get_photo`). Verified 2026-09-17.
3. **`git init` the Xcode project.** Still not a repo (verified 2026-09-17). 49 Swift files with zero version history is the largest unmanaged risk on the project right now; this needs an interactive terminal.
4. **`LSApplicationQueriesSchemes`** — no plist entry exists yet. Directions to Google Maps / Waze will fail silently until `comgooglemaps` and `waze` are added.
5. **Verification pass** — SE + Dynamic Type slider, Reduce Motion end to end, accessibility inspector. All three are written as done "by reading the code," never actually run on a device.
6. **Then polish and demo** — visual polish pass, 2-3 simulated locations, the 20-40s Dark-appearance recording.

Deliberately *not* next: the screen-05 CSS ring/contrast fixes and the icon-composer work. They are mockup-side and cosmetic; items 1-4 are ship-blockers.

## HTML redesign review — 2026-09-11

- [x] Redesign all nine HTML mockups around hunger, timing, and restaurants. See `wiki/concepts/app-mockups.md` → Current redesign.
- [x] Add demo/offline/service-unavailable/photo/appearance review controls; check compact layouts.
- [ ] Review the Sept 11 mockup direction with Sadri before treating it as the approved SwiftUI spec — native ports below still reflect the previous mockups.

Check items off as you complete them. Update `wiki/log.md` when a step involves a real decision or gotcha worth remembering.

## Current focus — function, edge-case views, animation (set 2026-09-09)

Full reasoning for every line here and in "SwiftUI build — open items" below lives in `wiki/log.md` / `wiki/log-archive.md` (already logged as dated entries, not duplicated here) and [[architecture]].

**Function**
- [x] Backend passthrough — `latitude`, `longitude`, `placeId`, `rating`, `ratingCount`, `priceLevel`, `photoRefs` (array), `openNow` all land via `_enrich_hero` / `_enrich_specialty` in `main.py` (verified 2026-09-17). Client already models them as optional, so nothing changed on the client.
- [x] Photo `attribution` — backend done 2026-09-17 (`_photo_attributions`, cache, `get_photo`, `_enrich_hero`). No extra Places cost: `places.photos` already carried `authorAttributions`. **Client side still open** — see below.
- [ ] Gemini prompt: keep numbers out of `reason` (it currently restates the fact row and truncates).
- [ ] Add `comgooglemaps` / `waze` to `LSApplicationQueriesSchemes` before wiring Directions (`canOpenURL` fails silently without it).
- [ ] Settle 04 → 06 navigation — also closes screen 06's missing back affordance. See [[architecture]] → "Navigation: flat replacement now, one stack later".

**Edge-case views** (none built yet)
- [x] Screen 07 (permission denied) — resolved: `WelcomeView.onContinue` passes `CLAuthorizationStatus` driving `RootView.Route.locationDenied`.
- [x] Screens 08 (no results) / 09 (network error — two copy variants via `NWPathMonitor`, offline vs service-unavailable).
- [ ] Decide the `daily_limit_reached` state (can't share screen 09's "Try again").
- [x] All three built as native SwiftUI views (`LocationOffView`, `NoResultsView`, `NetworkErrorView`) reusing `AppBar`, `PrimaryButton`, `AppGlyphs`, asset 1x/2x/3x illustrations.

**Animation**
- [ ] Screen transitions — `withAnimation` + `.transition()` (not a nav stack, unless the item above lands one).
- [x] Status-bar luminance detector for screen 06 (`UIHostingController` subclass — SwiftUI can't set `preferredStatusBarStyle` directly). 4 known naive-version bugs written out in `screen-06-result.html`.
- [ ] Verify Reduce Motion end to end (radar parks on frame 172, screen 05's stage dot stops pulsing — never actually tested with the setting on).

**Before any of the above:** run the sizing migration on an SE + walk the Dynamic Type slider — only verified on one device so far.

## SwiftUI build — open items

Screens 02/04/05/06 are ported; backend, edge cases, icon, and polish remain. Completed items and full reasoning: `wiki/log.md` / `wiki/log-archive.md`.

- [ ] Backend: prefer the largest / closest-to-16:10 Places photo instead of the first one returned — cheap, high visual impact.
- [x] Replace screen 06's slide 2 — **not a real blocker.** Verified 2026-09-17: the watermarked image survives only in the pre-Sept-10 mockup archive, not in the current mockups and never in the app. Item outlived the redesign that removed it.
- [x] Per-photo attribution, backend half (compliance blocker) — `get_photo` now returns `attribution`, and the recommendation response carries `photoAttributions` index-aligned with `photoRefs` (2026-09-17).
- [x] Per-photo attribution, **client half** — done and **verified on device 2026-09-17**. `HeroPick.photoAttributions` decodes index-aligned with `photoRefs`; `getPhoto` threads `attribution` through API/protocol/service; `loadHeroPhoto` prefers the hero's credit over the response. `PlaceDetailItem` made per-photo (was crediting all slides to slide 1). Renders as "Photo by <name>".
- [x] Add `price_level` to `api-contract.md`'s passthrough-gap table (added 2026-09-17).
- [x] Filter recommendations by opening hours ("Open Now") in backend (`main.py`) — dynamic timezone evaluation over `periods`, 48-hour cache handling, and Gemini prompt enforcement (done 2026-09-17).
- [x] Port Screen 06 permanently visible reason block to native SwiftUI in `ResultView.swift` and `ResultSheet.swift` (done 2026-09-17).
- [x] Update Screen 06 eyebrow tag from "YOUR PICK" to "PICKED FOR YOU" in mockup and native SwiftUI (done 2026-09-17).
- [ ] Check the licence position on permanently re-hosting Places photos (365-day WebP copies in Firebase Storage).
- [ ] Document the screen-06 ambiguous-photo status-bar case as an accepted limitation (bright signage on night sky can fail both bar styles — no fix planned, scrim is banned).
- [ ] Screen 05: fix the CSS ring animation to match the Lottie (rings currently scale-cap under the centre badge and are invisible — `.ring` tops out at 52px inside the 46px badge).
- [ ] Screen 05: fix `.stage.next{opacity:.5}` — same contrast-bug class as the photo-credit item below (~2.4:1 on 12px text).
- [ ] Screen 06: fix `.photo-credit` opacity contrast (third instance of the same bug class). **Now applies to the shipped native view too** — `ResultSheet`'s credit line is `Color.text2` fineprint.
- [ ] Decide the credit line's **placement**: it currently sits at the bottom of the "Why this place" block, not on or under the photo it credits. Compliant but easy to miss, and it reads as part of the reason copy.
- [ ] Decide who owns screen 05's motion spec (CSS vs the Lottie generator script) — they've already diverged in 3 places.
- [ ] Screen 05 currently shows 2 stages, not 3 (API contract carries no candidate count) — Sadri's call whether a backend progress signal is worth adding for a third stage.
- [ ] Consolidate `AsymmetricRoundedRectangle` and `WelcomeView.PurposeCardShape` (two corner implementations) — note this visibly changes screen 02's curvature, needs a look before merging.
- [ ] One icon set, two representations (screen 05 Lottie-baked pins vs screen 06 `FoodGlyph` Swift paths) — drive both from one source, or explicitly accept the duplication.
- [ ] Re-read screen 02's "Location, only on tap" copy — still true, but a fix is now taken right after permission is granted, not only on the recommendation tap.
- [ ] Reword `visual-identity.md`'s "colour alone signals" line to "colour reinforces, alongside symbol fill weight and placement".

**App icon** — mark is chosen (three-component food+clock+pin, see log), rounded, exported as flat PNGs 2026-09-10. Still open:
- [ ] Build the actual Icon Composer layered version (the flat-PNG export was explicitly the pre-Composer stopgap) — needed for Liquid Glass layering/specular highlights.
- [ ] Test at 29pt on device once the Composer build exists (per-feature clearance floors in the log).
- [ ] Re-check layer specifics against Apple's live Icon Composer docs (`apple-hig.md` flags this as stale — iOS 27 changed icon guidance again).
- [ ] Keep using `convert` (ImageMagick) to render icon SVG candidates instead of waiting on a browser — caught 6 of 9 candidate failures that weren't visible in the arithmetic.

**Housekeeping**
- [ ] `git init` the Xcode project (`hungrynow/`) — needs an interactive terminal or that folder connected; not doable from this Cowork session.
- [ ] Decide where the mockups live for version control (`output/mockups/` isn't covered by the project repo; screen 06 alone was rewritten 8 times with only comments as history).
- [ ] Build a self-contained mockup page (CSS inlined, images as data URIs) — the mockups currently can't be previewed except by opening from Finder; this is why several sessions in a row logged unrendered screens.
- [ ] Render pass on screens 02, 03, 08 — all changed since last actually viewed.
- [ ] Screen 02 dark-appearance pass (aubergine motif line art → blush in dark).
- [x] (Candidate) Investigate an "open now" Places passthrough — shipped 2026-09-17 as full opening-hours filtering in `main.py`, not just a passthrough. See log.
- [ ] Two location fixes per screen-04 session (chip lookup + `findFood()`) are intentionally independent, not cached together — revisit only if it shows up in battery/latency.

**Toward shipping**
- [ ] Visual polish pass (spec ready — `wiki/concepts/visual-identity.md`).
- [ ] Test in Simulator across 2-3 simulated locations.
- [ ] Record a 20-40s demo in Dark appearance (radar sweep + hero-reveal glow need it) — trim and save.
- [ ] (Stretch) Draft Fiverr gig description.
- [ ] (Stretch) Pick 1-2 portfolio screenshots — Light led by screen 06, one Dark still, one edge-case screen.


<!-- ARCHIVE BELOW — reference/backlog, not the live agenda. Read on demand only (see CLAUDE.md startup rule), not on every session. -->

## From the mockup review — 2026-09-07

Full review of all nine screens in `output/mockups/index.html` against `wiki/concepts/reference-adoption.md`'s adopt list and the HIG sections the root `CLAUDE.md` rule routes to (Foundations → Layout / Color / Accessibility / Writing / Motion; Patterns → Launching, Loading, Feedback; Components → Status, Presentation). Five findings were already on this checklist and are not duplicated here (metric chip row, inline read-more, invert specialty chips, clip the last chip, accessibility sweep). Judgment calls that need a decision before they become work live in `raw/mockup-review-2026-09-07.md`.

Drift — the mockups fell behind decisions already made:

- [x] **Screen 03's backdrop is the pre-supergraphic screen 02** — rebuilt 2026-09-07 to reuse screen 02's own parts instead of redrawing them: `.sg` moved to `shared.css`, plus the shared `.wordmark` / `.tagline` / `.btn-primary` classes and the new `--welcome-ground` token. Coupling is now one CSS rule and one asset, neither of which can drift. **Not yet rendered** — no browser was available in the session that built it
- [ ] **Move the supergraphic band onto screen 01 and drop the centred mark.** Screen 01 tracks only 02's *ground tone*, which was the whole match when 02 was a floating PNG — now 02's dominant element is a 200px band, so launch → welcome shows a structural jump, which is exactly what `apple-hig-patterns.md` → Launching exists to prevent. HIG also allows a logo on a launch screen only when it's a fixed part of the first real screen: the band is, the mark isn't. Converts the recorded "deliberate small departure" into actual compliance
- [x] **Route every SVG stroke/fill through `currentColor`** — done 2026-09-07. Zero palette literals left in any SVG attribute across the nine screens (verified by grep); glyph colour is now set on the container in CSS, so `.state-icon.calm` and `.pin.hero` switch fill *and* stroke from one class. New tokens: `--on-hero` (foreground on a saturated accent) and `--hero-rgb` (channels for screen 05's conic gradient, moved out of that file). The screen-02-only dark item below is now the whole dark pass, since the markup no longer blocks it. Original finding: `.state-chip`'s glyph does this correctly; everything else hardcodes — `#8A1E33` on 02/07/09 state icons, `#4F6A38` on 05's pins, `#FBF3EC` on every `btn-primary` icon, `#8A1E33`/`#A6243D` on 01's mark. As written the dark-appearance pass is a markup edit across eight files instead of a token swap. Do it before the dark pass, not during (broader than the screen-02-only dark item above)

Defects:

- [x] **Mixed units fixed in the mockups** 2026-09-08 — screen 06 now reads `400 m`. The `$$` price tier became `Rp Rp`: a dollar glyph reads as USD while `price_level` is currency-neutral, and `Rp` tiers are what Google Maps itself shows in Indonesia. (The word "Mid-range" was tried first and dropped — it doesn't fit a value-over-label column, where the value has to stay terse.) The star came off the rating, since the label already says RATING. The formatter rule itself is still unwritten — see the item above; this was the copy only
- [x] **Screen 08's `.radius-note` folded into the shared `.fact-row.calm`** and the duplicated sentence rewritten to spend its words on the next action instead of restating the radius. Done 2026-09-08
- [ ] **Split screen 09 into two states.** "Check your connection and try again. If you are online, the recommendation service is briefly unavailable" asks the reader to run a two-branch diagnosis. `NWPathMonitor` already distinguishes offline from server error, and `apple-hig.md` → Writing says say what's wrong and how to fix it. Same layout, two copy variants
- [x] **Screen 05 on a location-cache hit — resolved in the SwiftUI port, 2026-09-09.** The wait note is held back 3s (`SearchingView.showWaitNote`), so it is only ever on screen once the wait it warns about is actually happening; its height is reserved either way so revealing it doesn't shove Cancel under the reader's thumb. The other half of the finding dissolved rather than being fixed: the stages no longer run on a script, so on a fast path they don't "flash past" — they advance when the location fix lands and then the screen is gone. Nothing to skip below a threshold. **Still open in the HTML mockup**, which keeps the t=0 note

## Deferred to the SwiftUI build — not answerable in a fixed-width HTML mockup

Sadri's call, 2026-09-08: the mockups are for deciding **what is on each screen**, not for proving it survives every device and text size. That's correct, and these three items were sitting in the mockup phase where they can only be faked. A 242px fixed-pixel frame cannot tell the truth about adaptive layout, and HTML `aria-*` has no bearing on what VoiceOver reads in an app. Doing them here would produce a passing mockup and prove nothing.

They are not dropped — they are the same work, moved to where it can actually be verified. Do them once the SwiftUI screens exist, in the Simulator with the accessibility inspector open.

- [ ] **Accessibility sweep** — every glyph gets a visible label or an `.accessibilityLabel`; decorative shapes get `.accessibilityHidden(true)` (the `.softbg` circles, screen 05's radar, screen 02's band). 6 of 8 references shipped unlabelled icon-only controls; this is the check that catches it. **Mostly done for 02/04/05/06 as they were ported** — decorative layers are hidden, the icon-only "Try another" is labelled, glyph+text pairs are combined into one element. What is left is verifying it with the inspector open rather than by reading the code
- [ ] **Longest-real-string pass** at the largest accessibility Dynamic Type size, on every screen — real Places names ("Restoran Nasi Kandar Ar Rashid" is typical, not a worst case), a long model-generated `reason`, and the Indonesian translation. 7 of 8 references got this wrong. This is what `.lineLimit(1).minimumScaleFactor(0.85)` and the per-label font sizes in the mockup CSS were always standing in for
- [x] **Screen 05's radar sizing — resolved 2026-09-09.** `RadarView` takes its side from the caller as `min(m.px(200), column)`, and `SearchingView` computes `column` from the real screen width. So it is a fraction of available width AND clamped, which matters because `m.px(200)` is genuinely wider than the padded column on every device (324.8pt of radar against 321.5pt of column on a 393pt screen) — the 2px overflow was not only a fixed-frame artifact, it reproduces at every scale. The dashed outer ring cannot be clipped: the generator draws it at r=99 inside a 200-unit box, and `scaleAspectFit` letterboxes rather than crops. **Still worth a look on an SE**, for the composition rather than the clipping

## After the MVP works

- [ ] Create Fiverr seller profile ("Become a Seller")
- [ ] Publish gig(s): "Add an AI chatbot to your existing app" + "Integrate ChatGPT/AI features into your Android/iOS app"
- [ ] Add demo video + screenshots + office app as portfolio proof
- [ ] Price first 3-5 orders low intentionally, to get reviews
