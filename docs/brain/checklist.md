# Build Checklist

## Next up — decided 2026-09-17

The app is functionally complete end to end: 49 Swift files, all nine screens ported, backend filtering by opening hours, full field passthrough. What remains is compliance, verification, and shipping-hygiene — not features.

1. ~~**Photo attribution (compliance blocker)**~~ — **DONE and verified on device 2026-09-17.** Credit renders under the hero photo as "Photo by <name>". Root cause of the long debug: a missing cache-staleness guard, now added. See log.
2. ~~**Replace screen 06 slide 2**~~ — **resolved, no work needed.** The watermarked foodpanda placeholder exists only in `output/mockups/archive-before-2026-09-10/`; the Sept 10 redesign dropped it, and it was never in the app (the real carousel fetches Places photos via `get_photo`). Verified 2026-09-17.
3. **`git init` the Xcode project.** Still not a repo (verified 2026-09-17). 49 Swift files with zero version history is the largest unmanaged risk on the project right now; this needs an interactive terminal.
4. ~~**`LSApplicationQueriesSchemes`**~~ — **not a blocker; nothing is broken.** Verified 2026-09-17: `DirectionsLink` builds `https://` universal links for both Apple Maps and Google Maps and never calls `canOpenURL`, so there is nothing to fail silently. The plist entry is only needed if a nav-app *chooser* is added — see the open item below, which is a product decision, not a fix.
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
- [x] **Real `priceRange`** — done and verified on device 2026-09-18. `places.priceRange` added to the field mask (free: `rating` + `priceLevel` already put the call in the Enterprise tier), parsed by `_parse_price_range` to `{currency, start, end}`, passed through `_enrich_hero`/`_enrich_specialty`, with a cache-staleness guard keyed on the key's presence rather than its value. Client shows the real range, falls back to `$$` as a tier glyph, omits the column when neither exists. Fixed a Singapore restaurant reading "Rp50k–150k".
- [ ] Gemini prompt: keep numbers out of `reason` (it currently restates the fact row and truncates).
- [ ] **(Decision, not a fix)** Offer a nav-app chooser (Apple Maps / Google Maps / Waze)? Only then are `comgooglemaps` + `waze` needed in `LSApplicationQueriesSchemes`, since `canOpenURL` reports every undeclared scheme as missing. **Recommendation: don't.** Directions already works everywhere via `https://` universal links, and a picker contradicts the one-button, no-decisions premise for a hungry tourist. Close this as "won't do" unless Sadri wants the choice.
- [ ] Settle 04 → 06 navigation — also closes screen 06's missing back affordance. See [[architecture]] → "Navigation: flat replacement now, one stack later".

**Edge-case views** (none built yet)
- [x] Screen 07 (permission denied) — resolved: `WelcomeView.onContinue` passes `CLAuthorizationStatus` driving `RootView.Route.locationDenied`.
- [x] Screens 08 (no results) / 09 (network error — two copy variants via `NWPathMonitor`, offline vs service-unavailable).
- [x] Decide the `daily_limit_reached` state — **done 2026-09-17, rendered and verified on device 2026-09-18.** Now its own `NetworkErrorVariant.dailyLimitReached` ("THAT'S TODAY'S LOT" / "Back tomorrow.") with `isRetryable == false`, so the "Try again" button is omitted rather than disabled. Previously borrowed `.serviceUnavailable`, which told the user a spent daily quota was temporary and offered a button that could not succeed.
- [x] All three built as native SwiftUI views (`LocationOffView`, `NoResultsView`, `NetworkErrorView`) reusing `AppBar`, `PrimaryButton`, `AppGlyphs`, asset 1x/2x/3x illustrations.

**Animation**
- [x] Screen transitions — **built.** `Core/ScreenTransition.swift` provides the asymmetric scale-and-fade (0.28s, inside the vault's motion window); `RootView` and `RecommendationView` apply it via `withAnimation` + `.transition()`. Verified 2026-09-17.
- [x] Status-bar luminance detector for screen 06 (`UIHostingController` subclass — SwiftUI can't set `preferredStatusBarStyle` directly). 4 known naive-version bugs written out in `screen-06-result.html`.
- [x] Verify Reduce Motion **on a device** — **done 2026-09-18** on SE/16.4. All three behaviours confirmed with the setting on: screen transitions degrade to a plain crossfade, navigation is unaffected, and the Lottie radar freezes on a static frame (`isAnimating: !reduceMotion`). Fades are deliberately kept — a fade carries no motion vector, and an instant swap is the thing the rule exists to prevent.

**Before any of the above:** ~~run the sizing migration on an SE~~ — **SE pass done 2026-09-18** (iPhone SE / iOS 16.4, the oldest supported OS): every screen through to Place Details checked, no layout breakage, nothing clipped or pushed off-screen. It caught a real ship-blocker — all 20 glyphs rendered blank on iOS 16 (`currentColor`, see log). **Dynamic Type slider still not walked.**

## SwiftUI build — open items

Screens 02/04/05/06 are ported; backend, edge cases, icon, and polish remain. Completed items and full reasoning: `wiki/log.md` / `wiki/log-archive.md`.

- [x] **Facts card shows only what is known** — done 2026-09-18. Distance, rating and price each omit their column when the data is missing, and the card is hidden entirely when nothing is known. Previously each gap was filled with a plausible constant: no rating rendered "4.9" from "1.5K reviews" against a named real business. Dropping a column exposed a latent bug — the star glyph was drawn at `index == 1`, so an omitted distance moved rating to index 0 and starred the **price**; the flag now lives on `Fact.showsStar`. Verified across all six omission combinations.
- [x] **`FactRow` removed** 2026-09-18 — no call sites. `log-archive.md` recorded screen 08 reusing it, true when written; `ResultSpecialtiesSection` has since styled its facts inline. `Fact` shared the file and is still used, so the view went and the file became `Fact.swift`.
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
- [x] Screen 05 `.stage.next{opacity:.5}` — **gone with the Sept 10 redesign.** Verified 2026-09-17: the selector exists nowhere in the current mockups.
- [x] Screen 06 `.photo-credit` opacity contrast — **not a live bug.** Verified 2026-09-17: `.photo-credit` survives only in `output/mockups/archive-before-2026-09-10/`. And the native credit line does NOT inherit the problem: `Color.text2` on `Color.bg` measures **6.12:1 light / 8.28:1 dark**, well past WCAG AA's 4.5:1 for small text. The bug was CSS `opacity`, which the native view never used.
- [x] Credit line placement — **settled: it stays where it is.** Moving it onto the photo would break `app-mockups.md` decision #1 ("No text over the photo", marked not-to-re-litigate): legible text on a photo needs a scrim, scrims are banned gradients, and no fixed overlay colour survives the range of Places photos (lit facade / dark interior / white tablecloth). Below the photo in the sheet is the only compliant spot. "Photo by <name>" now labels it so it doesn't read as stray copy.
- [ ] Decide who owns screen 05's motion spec (CSS vs the Lottie generator script) — they've already diverged in 3 places.
- [ ] Screen 05 currently shows 2 stages, not 3 (API contract carries no candidate count) — Sadri's call whether a backend progress signal is worth adding for a third stage.
- [ ] Consolidate `AsymmetricRoundedRectangle` and `WelcomeView.PurposeCardShape` — **confirmed still duplicated 2026-09-17**; `AsymmetricRoundedRectangle.swift:20` documents it in the file itself. Changes screen 02's curvature visibly, so look before merging.
- [ ] One icon set, two representations (screen 05 Lottie-baked pins vs screen 06 `FoodGlyph` Swift paths) — drive both from one source, or explicitly accept the duplication.
- [ ] Re-read screen 02's "Location, only on tap" copy — still true, but a fix is now taken right after permission is granted, not only on the recommendation tap.
- [ ] Reword `visual-identity.md`'s "colour alone signals" line to "colour reinforces, alongside symbol fill weight and placement".

**App icon** — mark is chosen (three-component food+clock+pin, see log), rounded, exported as flat PNGs 2026-09-10. Still open:
- [ ] Build the actual Icon Composer layered version (the flat-PNG export was explicitly the pre-Composer stopgap) — needed for Liquid Glass layering/specular highlights.
- [ ] Test at 29pt on device once the Composer build exists (per-feature clearance floors in the log).
- [ ] Re-check layer specifics against Apple's live Icon Composer docs (`apple-hig.md` flags this as stale — iOS 27 changed icon guidance again).
- [ ] Keep using `convert` (ImageMagick) to render icon SVG candidates instead of waiting on a browser — caught 6 of 9 candidate failures that weren't visible in the arithmetic.

**Housekeeping**
- [x] `git init` the Xcode project — **done 2026-09-17.** Initial commit `796a8d0` pushed to https://github.com/Sadri21/hungryNow (public). Secrets, venv, and `CLAUDE.local.md` gitignored and verified excluded.
- [x] Decide where the mockups live for version control — **resolved by the vault move.** They are at `docs/brain/output/mockups/` inside the repo, 61 files now tracked in git, so every future rewrite has real history.
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

- [x] **Mixed units fixed in the mockups** 2026-09-08 — screen 06 now reads `400 m`. The `$$` price tier became `Rp Rp`: a dollar glyph reads as USD while `price_level` is currency-neutral, and `Rp` tiers are what Google Maps itself shows in Indonesia. **Superseded in the app 2026-09-18** — `Rp` is itself a currency, so it is wrong the moment the app runs abroad; the shipped app uses Google's real `priceRange` with its own currency code and falls back to `$$` as a pure tier glyph. This item still describes the HTML mockups, which keep `Rp Rp`. (The word "Mid-range" was tried first and dropped — it doesn't fit a value-over-label column, where the value has to stay terse.) The star came off the rating, since the label already says RATING. The formatter rule itself is still unwritten — see the item above; this was the copy only
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
