# App Mockups — first-run flow

## Current redesign — 2026-09-11

Sadri requested a redesign of **all nine HTML screens**, centered on hunger, timing, and restaurants, with less generic AI-looking decoration. The active `output/mockups/screen-01` through `screen-09` files now contain that redesign. **This is a reviewable HTML direction, not a completed SwiftUI migration or a claim that Sadri has approved every visual choice.** The historical decisions below describe the previous version unless explicitly carried forward here.

- **Welcome:** a bespoke SVG restaurant frontage; striped awning, service window, and steaming bowl. Clear location purpose above Continue. Launch matches the welcome background blocks without a logo or imposed delay; the location prompt remains a facsimile of system-owned UI.
- **Home:** a plate that doubles as a clock, a large hunger/time headline, and one bottom action. The clock is a decorative motif, not a time-of-day readout, ETA, queue estimate, or countdown.
- **Searching:** a kitchen ticket with an indeterminate rotating clock and one honest status message. No fabricated restaurant counts, percentages, or completed backend stages. Cancel remains available. Reduce Motion disables the clock animation.
- **Result:** existing restaurant photography, visible Home navigation, a separated distance/rating/price row, expandable explanation, and a numbered specialty list. A pinned Directions action sits beside the accessible “Find another restaurant” control. The carousel uses **two exterior fixtures** (`hero-photo-example.jpg`, `hero-photo-dish.jpg`); the misleadingly named `hero-photo-street.jpg` contains a foodpanda watermark and is excluded. Preserve per-photo attribution in the native implementation; a caption describing the exterior does not replace Google’s required attribution.
- **Recovery:** plain headlines identifying location-off, no nearby restaurants, and offline states. `screen-09-network-error.html?variant=service` has separate service-unavailable copy and a clock symbol, without telling an online user to reconnect. The daily cap remains a separate unresolved product state.
- **Identity:** retains the Pomegranate & Pistachio palette; changes the mockup’s typography from uniformly rounded to system sans, uses fewer containers, and replaces blurred circles and floating character art with restaurant and table-setting imagery. The earlier `visual-identity.md` remains the shipping identity history; this new direction has not been applied to native assets.

**Files and preview.** `index.html` is the new live screen board, with Light / Dark / System review controls and a “Try the flow” link. `redesign.css` supplies the active mockup presentation; `prototype.js` supplies local demo navigation, photo controls, and explanatory Settings / Directions handoffs. `board.css` and `board.js` belong only to the review board. The earlier `shared.css` is retained for `variants-fact-row.html` and historical references; it no longer styles the nine redesigned screens. The complete previous set, including images, is in `output/mockups/archive-before-2026-09-10/` (backup started on September 10; redesign completed September 11).

**Demo contract.** `?demo=1` carries through the first-run links and moves Searching → Result after 4.5 seconds; this is a demonstration timer, not a production performance promise. Without that query, each screen remains still for design review. The board’s appearance override is a review tool, not a proposed in-app setting. Restaurant facts, names, specialty examples, and photos are fixtures carried across the design study and are **not a geographically validated live recommendation**. No API, geolocation, maps, or device-settings calls are made. **These fixtures are permitted only inside the static HTML mockups. They must never be copied into native/runtime code as a fallback for a missing SDK or unfinished API integration; the agent must surface the missing dependency to Sadri and pause that implementation unless he explicitly authorizes mock data for a specific debugging task.**

**Verification:** visually reviewed the nine-screen board and individual layouts in the in-app browser; checked 375 × 812 and 375 × 667 layouts, light and dark examples, permission routing, Cancel, automatic demo completion, carousel controls, expanded details, Settings / Directions dialogs, retry links, and both network variants. Checked JavaScript syntax and every local reference in the nine screens and board. Native Dynamic Type, actual permission rendering, and device Reduce Motion testing remain part of the SwiftUI handoff, not verified by this HTML exercise.

---

**Status:** in progress (2026-09-07). Screens 01–05 and the edge cases 07–09 designed; screen 06's hero card and photo are designed, its specialty chips and footer action are not. Built from [[visual-identity]] (Pomegranate & Pistachio, light appearance). These are HTML mockups, not SwiftUI — they exist so the "Build SwiftUI screen" checklist item starts from a decided design instead of an empty `ContentView`.

## Why these exist

Sadri's read after the first SwiftUI sketch: building screens from scratch produces something very plain. The mockups front-load the design decisions — layout, spacing, copy, states — so the Swift work becomes translation rather than invention.

## Where everything lives

All under `output/mockups/`:

| File | What it is |
|---|---|
| `index.html` | Flow view — embeds every screen live via iframe, so it never goes stale. Two rows: happy path (01–06), edge cases (07–09) |
| `screen-01-launch.html` | Launch screen |
| `screen-02-welcome.html` | Welcome **+ location purpose** — the merged onboarding/pre-permission screen |
| `screen-03-permission.html` | The iOS system location alert (system-drawn; only the purpose string is ours) |
| `screen-04-home.html` | Home, idle state |
| `screen-05-loading.html` | Loading state |
| `screen-06-result.html` | Hero result |
| `screen-06a-place-details.html` | Reusable full-screen restaurant details destination opened by the hero and specialties |
| `screen-07-permission-denied.html` | Location denied — the dead end, with "Open Settings" |
| `screen-08-no-results.html` | Nothing within walking distance (API `404 no_results`) |
| `screen-09-network-error.html` | Retryable failure (`places_lookup_failed` / `recommendation_failed` / transport) |
| `shared.css` | Design tokens + device frame + shared components |
| `welcome-banner.png` | Welcome illustration — final, background removed, transparent PNG (620×620) |
| `welcome-banner.jpg` | Superseded (the old sharper art with fake signage). Unreferenced — kept for before/after only |
| `home-illustration.png` | Home illustration — final, background removed, transparent PNG (560×560) |
| `home-illustration.jpg` | Superseded placeholder (a crop of the Welcome art). Unreferenced — safe to delete |
| `state-location-off-illustration.png` | Screen 07 object-only illustration — map, disabled pin, phone, settings and storefronts; transparent PNG (560×560) |
| `state-no-results-illustration.png` | Screen 08 object-only illustration — magnified empty map, closed storefront and table setting; transparent PNG (560×560) |
| `state-network-error-illustration.png` | Screen 09 object-only illustration — crossed Wi-Fi, phone, disconnected pins and food objects; transparent PNG (560×560) |
| `hero-photo-example.jpg` | Example Places-style photo for screen 06's hero card (480×300; full-res in `output/`) |

Source art at full resolution sits one level up in `output/`: `illustration-home-crossroads-fullres.png` and `illustration-welcome-arrival-fullres.png` (both 1024×1024, backgrounds already removed); `illustration-location-off-fullres.png`, `illustration-no-results-fullres.png`, and `illustration-network-error-fullres.png` (1254×1254, transparent); `illustration-welcome-banner-fullres.png`; and `illustration-food-pin-fullres.png` (the earlier flat-vector version, superseded but kept).

Also in `output/`, from the identity work: `visual-identity-style-sheet.html` (the locked spec, light+dark) and `visual-identity-color-options*.html` (the five elimination rounds — history, not active).

**Superseded:** `output/app-mockups-first-run.html` is the original single-file version of all six screens. The per-screen files replaced it. It's kept only as a snapshot — do not edit it, and don't treat it as a second source of truth. Deleting it is fine once nobody wants the before/after.

## The editing model (important)

The screens were split apart specifically so iterating on one can't break the others:

- **`shared.css`** holds only what genuinely is shared: color tokens, the device/phone frame, status bar, home indicator, **the app bar**, **the soft background**, buttons, hero card, spec chips. Change a token here and every screen updates at once — this is also where a swap to the Rust & Mustard backup palette would happen (see [[visual-identity]] → Architecture).
- **Screen-specific layout lives inside that screen's own file**, in a scoped `<style>` block under its `.screen-*` class. Screen 04 is the model for this. Screens 02, 03 and 05 were moved to their own files in the 2026-09-07 passes; 01 and 06 still have layout rules in `shared.css` — move them out as each gets worked on.
- **Shared beyond tokens, deliberately:** the app bar (`.appbar`) and the soft background (`.softbg`) live in `shared.css` and are used by 04, 05, 06 and 07–09 — consistency across the flow isn't achievable if each screen owns its own copy. The edge-case states (07–09) additionally share a `.screen-state` / `.state-*` block, because all three are the same shape (the shared app bar, then a centered icon + headline + explanation, then one action in the thumb zone) and only the icon, copy and action differ. Copying that layout into three files would be worse. Each file still scopes its own extras (the Settings steps list, the radius pill, the variant callout).

A previous split silently truncated all six files with a bad non-greedy regex (missing closing tags and home indicators). If regenerating from a combined file again, match `<div>` nesting properly and verify `<div>` / `</div>` counts per file.

## Screen decisions worth not re-litigating

**01 Launch** — icon mark only, no text, no animation. HIG says a launch screen isn't a branding moment and should look nearly identical to the first real screen. Strictly it should carry no logo at all; keeping the mark is a deliberate, flagged departure.

**02 Welcome — supergraphic rebuild 2026-09-07 (supersedes the floating-art layout).** Sadri's reason for the change is the design argument: screens 02 and 04 were *both* "art floating on soft blurred circles", so the two read as the same screen. Swapping one picture for another wouldn't have fixed that — the differentiation had to be structural. Now:

- **02** = an edge-to-edge geometric **supergraphic** band, no blur anywhere.
- **04** = centred floating illustration on the shared `.softbg` circles, unchanged.

Both still obviously the same app, because palette, radius language and type are shared. Technique catalogued as `supergraphic-mosaic` from reference 005 in the main vault; decision recorded in [[reference-adoption]].

**Geometry.** A 4 × 68px grid = 272px on a 242px screen, shifted **−15px**, so cells crop by 15px at *both* side edges — being larger than its frame is what makes a supergraphic one. Rows 40 + 80 + 80 = 200px measured from the screen top, running *behind* the status bar.

**The status-bar collision is solved deliberately, not dodged.** Stopping the band below the status bar would kill the top bleed, so instead **row 1 is restricted to pale fills only** (`--bg`, `--sg-hero-1`, `--sg-spec-1` — all ≥13:1 against aubergine). Never put a `--sg-*-2` fill or a dark motif in row 1. This is precisely the defect reference 005 left unresolved: its mosaic bled off the top edge with no status bar drawn anywhere in the pin.

**Content is now a generated asset, not a CSS grid (2026-09-07, same day).** Sadri's verdict on the hand-built version was **"very rigid"** — correct, and unavoidable: a uniform 4 × 3 grid of identical cells is rigid by construction, and irregularity is the one thing this technique cannot do without. Generated from the prompt below, then post-processed. `welcome-supergraphic.png`, 816 × 600 (@3x for the 272 × 200 box), authored at exactly 1.36:1 so `object-fit:cover` never re-crops it. **Superseded for shipping by a vector version, 2026-09-09 — see "Ship as vector" below.** The PNG remains the mockup's source of truth and the vector's origin; the mockups still reference it.

What the delivered image got right, measured rather than eyeballed: **the pale top strip clause was obeyed** (0.000% ink in the top 20%, darkest tone there ~`#D798A0`), the grid came back genuinely irregular, and both side edges bleed. What it got wrong: the ink colour arrived as `#422021` (a maroon-brown) rather than aubergine `#2B1512`, and 22,676 unique colours meant soft shading and anti-aliasing throughout.

**Post-processing, in order:**
1. Cropped 3:2 → 1.36:1 by trimming 143px from the **right**, so the noodle bowl stays whole at the left edge and only geometric partial cells get cut.
2. **Quantised every pixel to the seven palette tokens.** This is the step that matters: it corrected the ink colour and flattened every gradient and soft shadow the generator introduced. Final distribution — sg-spec-2 21%, sg-hero-1 18%, elevated 17%, sg-hero-2 15%, ink 15%, bg 11%, sg-spec-1 3%.
3. **One hand edit:** a large solid dome at the bottom edge was recoloured aubergine → sage. Reason: it was the heaviest mass in the composition and sat directly above the centred wordmark, so two dark masses stacked on the vertical centreline and the dome read like a thumbnail rather than decoration. Isolated programmatically rather than by eye — ink connected components with fill-ratio ≥ 0.8 touching the bottom edge, which separates a solid blob from line-art icons (every icon measured ≤ 0.67). Three variants were rendered at true screen scale and compared: as-is, dome→sage, dome→removed. Sage won; removing it left the bottom-centre flat.

**A watch-out for any replacement asset:** re-measure the top-20% ink before installing it. The pale strip is what protects the status bar, and it is a property of the *asset*, not of the layout.

**The cut bottom edge is correct, not a flaw.** Shapes sliced by the band's lower boundary read as "the pattern continues under the content" — the same logic as the side bleed. The only thing that made it look wrong was the dark dome, now fixed.

### Ship as vector, not as @1x/@2x/@3x PNGs (2026-09-09)

**The raster export was the wrong deliverable and the arithmetic says so.** Sadri asked for a 1x/2x/3x set and then, correctly, that something looked too small — though not the thing he pointed at. `1x` is a *point* scale, not a device size: no iPhone since the 3GS renders the 1x slot, and every Pro is @3x, so the 272 × 200 file is dead weight and was never the problem. The real problem is that the asset was authored for the **mockup's 242pt frame**, not a real device. A shipping iPhone is 393pt wide (16/17) to 440pt (Pro Max), so the band's @3x width needs ~1269–1410px against the 816px that exists — a **1.7× upscale on flat seven-colour geometry with hard edges**, i.e. the single worst content type to upscale. Height was already fine (600px = 200pt @3x).

**Resolution: vectorise.** HIG → Foundations → Images is explicit that flat icon-like art that needs to scale should ship as PDF/SVG rather than as multiple rasters, and this asset is seven flat fills with no gradient or soft shadow *by construction* (that was the whole point of the quantisation step above), so it vectorises exactly rather than approximately.

**Method — traced from the PNG, not redrawn.** Redrawing would have re-created the uniform CSS grid Sadri already rejected as "very rigid"; the irregularity is the generated composition's whole value, so it had to be preserved pixel-faithfully. Scripts kept next to the output in `output/ios-assets/`:

1. `quantize-supergraphic.py` — nearest-palette-token classification of every pixel into the seven tokens. (Watch the int16 overflow: squared RGB distance needs int32.)
2. `vectorize-supergraphic.py` — per-colour-layer trace via `potracer`.

Two things in step 2 are the difference between a clean result and a bad one, both worth keeping if this is ever redone:

- **Ink holes are filled, not traced around.** The ink motifs are lifted out and the vacated pixels flood-filled from the surrounding block colour, so each colour layer is a *solid* region with ink painted on top of it. Tracing colour layers with ink-shaped holes instead leaves sub-pixel seams where the two curve fits disagree.
- **The anti-alias ring is absorbed into the fill, and the ink is traced 1px fat.** First attempt filled only the ink core, so the light anti-aliased ring around every motif survived as a pale halo (clearly visible around the bowl and the food cart). Treating `dilate(ink, 2)` as unknown and tracing `dilate(ink, 1)` removes it. Side effect: it also cut the path data from 293KB to 72KB, because the ragged ring had been generating thousands of junk curves.

Output: `output/ios-assets/WelcomeSupergraphic.imageset/` — `welcome-supergraphic.svg` (72KB) as the asset, `welcome-supergraphic.pdf` (36KB) as the fallback if Xcode's SVG support misbehaves, `Contents.json` single-scale with `preserves-vector-representation`. Verified against the PNG at 816px (mean per-pixel diff 9.85/765) and inspected at 1440px. The 1px ink dilation is the whole of that diff.

**The aspect ratio is not a problem, contrary to first impressions.** Art is 1.36:1; a 200pt band across a 393pt screen would want 2.2:1, which looks like a shortfall. It isn't, because **the band should scale with screen width rather than stay at 200pt**. Reproduce the mockup's own relationship — art 272pt wide on a 242pt screen, i.e. 1.124× overhang — and the band height falls out as `width × 0.826`: **325pt on a 393pt iPhone, 364pt on a Pro Max.** As a share of screen height that is 38.1%, against 39.7% in the 242 × 504 mockup frame. So the composition is used whole, at its authored ratio, with the 15pt-equivalent side crop intact, and nothing is cropped top or bottom — which matters because cropping the top would destroy the pale status-bar strip that the asset was specifically constructed to provide.

```swift
// Band height = screenWidth * 0.826; art is 1.124x wider than the screen so it bleeds both sides.
GeometryReader { geo in
    let w = geo.size.width
    Image("WelcomeSupergraphic")
        .resizable()
        .scaledToFill()
        .frame(width: w * 1.124, height: w * 0.826)
        .frame(width: w, alignment: .center)   // crop the overhang
        .clipped()
        .accessibilityHidden(true)             // decorative
}
.frame(height: UIScreen.main.bounds.width * 0.826)
.ignoresSafeArea(edges: .top)
```

### The home illustration vectorises too — but for a different reason, and with one real loss (2026-09-09)

Sadri asked for the same treatment on `home-illustration.png` (screen 04's centred figure). **The supergraphic's argument doesn't transfer**, and that's worth being clear about: that asset was 816px against a ~1410px need. This one has a 1024 × 1024 fullres source (`illustration-home-crossroads-fullres.png`) for a 216pt box — even scaled aggressively it needs ~1179px @3x, a 1.15× upscale of soft organic artwork, which is nearly invisible. **The raster was adequate here.** Vector won on other grounds.

**What actually decided it was file size, which went the opposite way from the guess.** SVG is **151KB**; the raster set it replaces (@2x + @3x from the 1024 source at a 216pt box) is **207KB + 416KB = 623KB**. Vector is 4× cheaper *and* unbounded — so the trade isn't "fidelity vs. flexibility", it's "fidelity vs. everything else".

**The fidelity cost is real but sub-visible.** The wheels, and the small red dots, carry **soft concentric tonal rings** in the original (radial scan through a tire: `#2D0716 → #4A1D31 → #2D0715 → #41172B`). Unlike the supergraphic, this illustration was **never quantised to a flat palette** — that step was what made the supergraphic trace exactly. So the rings can only be flattened or approximated:

- **8-colour palette** (shipped): wheels become flat plum discs. 151KB, clean everywhere else.
- **10-colour palette** (tried, rejected): adding `#2D0716` and `#4A1D31` blew the file to **933KB** and made the whole image blotchy — those tones live mostly in *anti-aliasing*, not in flat regions, so tracing them produced thousands of junk slivers. Mean error got *worse*, not better.

**Rendered side by side at 260pt — the real display size — the two are indistinguishable.** The flattening is only findable past roughly 2× zoom. That is the whole basis for shipping it; if this art is ever reused at 400pt+ (an onboarding hero, say), re-check the wheels before assuming it still holds.

Palette (8, derived by measuring only pixels whose 3 × 3 neighbourhood is uniform, which excludes anti-aliasing): outline `#41112B` · red `#A72A3C` · dark red `#7E1B30` · sage `#98A472` · peach `#F8B7A5` · cream `#F6F1ED` · beige `#EED6B2` · yolk `#F6C978`. The hair is **not** a separate tone — it is the outline colour (`#3E102C` measured at its centre); the lighter interior it appears to have is source softness.

**One method difference from the supergraphic, and it matters.** There, ink is traced at `dilate(ink,1)`. Doing that here made every stroke ~40% heavier — the outlines are only 4–6px at 1024, so +2px is a large fraction — and the face visibly coarsened. Here the ink is traced at its **core**, with the anti-alias ring still absorbed into the fills underneath (`dilate(ink,2)` flood-filled from the surrounding colour). Fills extending under the ink is what prevents the halo; dilating the ink itself was never the part doing that work. **Rule for any future asset: absorb the ring into the fill, and only fatten the ink if the strokes are thick enough to afford it.**

Output: `output/ios-assets/HomeIllustration.imageset/` (SVG + PDF fallback, single-scale, alpha preserved since the figure floats on the shared `.softbg` circles). Generated by `vectorize-illustration.py`, which takes source and destination paths and so also covers the remaining illustrations if they ever need the same treatment.

**Open, deliberately not invented: the Dark Mode variant.** HIG → Foundations → Color and Dark Mode both require light + dark variants for any custom colour, and this is a fixed seven-token light palette. Choosing the dark palette is a design decision, not a mechanical one, so no dark SVG was generated. When it is, add it to the same imageset with an `appearances` qualifier rather than swapping the asset in code.

**Ground tone + lower shapes (2026-09-07, third pass on this screen).** Sadri: the area under the band read as "just white". Answered from reference 008 rather than by piling decoration onto a white field — 008 tints the whole screen ground and builds hierarchy from value, using sage for its home screen and cream for its list. So:

- **Screen ground `--bg` → `--elevated`** (the warmer, deeper tone).
- **Purpose card `--elevated` → `--bg` + a `--hairline` border.** Pure white was tried in between and **rejected**: it measured better (1.26:1 against the ground vs 1.13:1) but at real size read as a bright sticker pasted on, because this palette is deliberately warm. A contrast ratio is not a temperature judgement — see [[visual-identity]] → Rejected. The hairline is not optional: 3:1 is the threshold for a boundary carried by tone alone and no light-mode surface pair in this palette reaches it.
- **One hard-edged circle** bleeding off the bottom-left corner (300px `--sg-spec-1`). Deliberately **not** the blurred `.softbg` circles that 04-09 use — hard geometry versus soft blur is the thing keeping 02 and 04 distinct, so reintroducing blur here would undo the rebuild. A second rose circle at the right edge was built and removed: it sat directly *behind* the purpose card, so almost none of it showed and it only added noise at the card's edge. Rendering the card on a transparent fill made it obvious — the circle showed straight through the content block. **One confident corner arc beats two arbitrary circles.**

Contrast re-measured on the new ground before committing: TextPrimary 13.65:1, TextSecondary 5.42:1, and 5.18:1 where the privacy note crosses the sage circle. All pass AA.

**The purpose card's shape, third attempt (2026-09-07).** Sadri said twice that the card didn't belong to the screen. Both of my first two answers were about the *fill* — flip it lighter, then pure white — and both missed the point. **The fault was the shape.** A symmetric, inset, uniformly-rounded rectangle with a hairline shares *nothing* with the band above it, so no fill was ever going to fix it.

The band has two defining properties: it **bleeds off the frame**, and its geometry is **asymmetric**. The card now does both:

- **Bleeds off the left edge** — `align-self:stretch` plus `margin-left:-22px` cancels `.content`'s padding, and `padding-left:22px` restores the text inset. So only *colour* crosses the edge; the text still starts 22px in, aligned with every other element on the screen.
- **One large radius on the bottom-right** (34px), small on the top-right (14px), square where it meets the screen edge. `border-left` is dropped, because at `-22px` it would land exactly on x=0 and draw a 1px line down the screen edge.

That is `asymmetric-corner-radius` from references 006/008 — already item 7 on the adopt list in [[reference-adoption]] — combined with the band's own edge-bleed logic. **The lesson worth keeping: when an element "doesn't belong", check whether it shares the screen's *shape* vocabulary before touching its colour.** Two rounds were spent on fill for a shape problem.

**Knock-on caught: screen 01 had to follow.** `apple-hig-patterns.md` → Launching says a launch screen should look nearly identical to the first real screen, *same solid colours*, so the transition is invisible — and screen 01's caption had always claimed to match screen 02. Changing 02's ground silently made that claim false and would have introduced a visible tone jump on launch. Screen 01 now sets `--elevated` too, and its rules were moved out of `shared.css` into its own file per the editing model above (it was one of the two screens still holding layout there). **If 02's ground ever changes again, change 01 in the same commit.**

**Accessibility bug fixed at source while in there:** `.privacy-note` carried `opacity:.75`, which composites `--text2` to 3.51:1 on `--bg` and 3.26:1 on the new ground. It is 10px text and needs 4.5:1, so it was failing on **all three screens that use it** (02, 08, 09) — before this change, not because of it. Opacity removed; now 6.12:1 / 5.42:1. Rule recorded in `shared.css`: if it reads too heavy, use a smaller size or a lighter token with a *measured* ratio, never opacity, which breaks contrast silently.

**Vertical budget of the 504px content area:** 184 padding-top (172 to clear the band + 12 breathing) + 22 wordmark + 48 tagline + 108 purpose + 99 CTA = **461, i.e. ~43px slack** — more than the 19px the floating-PNG layout had, so this version is also the safer one on space. The old constraints still hold: tagline 2 lines, purpose 4 lines.

**Verified statically, not visually.** Tag balance (22/22 divs, 7/7 svgs), full class coverage both directions, 12 grid cells matching 4×3, every `var()` resolving to a defined token, and the geometry arithmetic above. **No render was done — this session had no browser binary available** (unlike the sessions that rendered screens 04/05/06 at 3×). Open the file in a browser before trusting the composition; the numbers are right but nobody has looked at it yet.

*Caught during the rebuild:* the full-file rewrite silently dropped the `.purpose` style block, restored immediately. That is the second instance of the same bug — a full-file rewrite loses per-screen rules, and the class-coverage check catches an undefined class but not a *dropped* rule on a class that still exists. Screen 06's footer border was lost the same way.

**02 + 03 merged (decided 2026-09-07)** — the old split (Welcome, then a permission bottom sheet over it) is gone. Welcome now carries the location purpose itself, in a small elevated block under the tagline, with a single "Continue" button. Reasons: HIG's Onboarding pattern explicitly allows folding an essential permission into onboarding *so you can explain the benefit*, and HungryNow is one of the cases it's talking about (no location, no app at all); the two screens were saying the same thing twice; and it removes a tap before the app is usable. The merged screen still satisfies every constraint the sheet was built around — exactly one button, "Continue" not "Allow", no dismissal path that skips the real system alert.

The purpose block needed room, so the banner first shrank 312px → 224px in that same session. It was then replaced entirely by the floating-art layout above, so those numbers no longer exist anywhere in the file — see the 02 Welcome entry for the current sizes.

**03 is now the system alert itself** — not our UI. It's mocked because the one part we do own, the purpose string, has to be written before it's typed into `Info.plist`, and it's easier to judge in place than in a plist. Drawn in the system font rather than SF Rounded on purpose, to signal it's iOS chrome. Locked copy for `NSLocationWhenInUseUsageDescription`:

> HungryNow uses your location to find restaurants within walking distance of where you are right now.

Active, specific sentence per HIG's Privacy rules — not "location access is needed for a better experience."

**04 Home** — the shared app bar (wordmark left, location chip right), illustration centered in a 216px box with no fill or radius (`object-fit:contain`; the art is a transparent PNG, so it floats on the screen background rather than sitting in a tile), one headline question, one button. Deliberately stripped: an earlier version had an eyebrow, a supporting paragraph and a "Takes about 5 seconds" note, all cut as too much text. The 5-second claim was also wrong — real calls run 0.6s cached to ~16s cold.

**05 Searching — design pass 2026-09-07, then revised the same day.**

*First pass* replaced the original spinner-on-an-empty-screen with a skeleton of the result (hero card + specialty chips), which is what HIG's Loading pattern asks for — placeholder graphics that get replaced as content arrives.

*Revision, on Sadri's call:* the skeleton came out and a **radar sweep** went in as the focal point, because the screen needed to be eye-catching, not just correct. Defensible beyond taste, too: with a single hero result, a full-size skeleton card can read as a result that's already there, and the honest stages below already carry the "something is happening" job the skeleton was doing.

What the radar is: a **rotating sweep arm** — a **90° pomegranate-to-transparent conic fade**, brightest at its leading edge, one rotation per 3s loop — over two faint dashed range rings, plus expanding pomegranate pulse rings from a centre "you" marker, plus five place pins. Four pins pistachio, one pomegranate for the hero-to-be, so the colour-meaning rule holds even in an animation. The motif is literal rather than decorative: the range rings are the 1.5km radius the backend actually searches, and the pins are candidates being found. By the end of a loop the map is populated, which is what "found 24 places" means.

**Every part shares the same 3s period, and the pin positions are computed, not placed by eye.** Each pin sits at the exact angle the arm's leading edge reaches at that pin's `animation-delay` (arm starts at 12 o'clock, 120°/s: 0.45s → -36°, 0.95s → 24°, 1.45s → 84°, 1.95s → 144°, 2.35s → 192°), so a pin appears *because* the sweep crossed it. Verified numerically — every pin lands within 0.1° of its arm angle. Radius is varied 30–36% so the cluster looks placed rather than measured. **If a delay changes, recompute the position or the causal illusion silently breaks** — that is the one fragile thing on this screen.

**The arm went through two versions.** It was first built as a flat translucent 58° sector, specifically to honour [[visual-identity]]'s no-gradients rule — and it did not read as a radar, because the trailing fade *is* what says "scanning." Sadri asked for the real thing: widened to 90° and given a conic gradient from pomegranate at ~34% alpha down to transparent. That is now a **sanctioned exception** recorded in [[visual-identity]], alongside the loading pulse-glow — both are transient motion cues on this one screen, not persistent decoration, which is the distinction the rule cares about. It is not licence for gradients elsewhere.

A hard 1.6px line was drawn on the leading edge in both versions and removed 2026-09-07 on Sadri's read: against a soft fade it read as a separate object laid over the sweep rather than as its edge. The gradient's own bright boundary defines where the arm is, so the alpha at the leading edge was raised from .34 to .40 to compensate. No hard strokes inside the radar now.

The one thing easy to get backwards: rotation is clockwise, so the fade must run transparent at 270° up to full alpha at 360° (`from -90deg`, where 360° is the 12 o'clock leading edge). Written the other way, the tail leads the arm and the radar reads as spinning backwards. The same mistake was made and caught in the flat-sector version.

**Why it is not a Lottie.** Sadri asked for a Lottie. It's built as inline SVG + CSS keyframes instead, and that was a deliberate substitution: it matches the palette hexes exactly (a stock Lottie would need recolouring frame by frame), adds no dependency, and maps onto SwiftUI shapes and `withAnimation` directly when this becomes real code. Lottie in the app means adding `lottie-ios` plus a commissioned JSON, for an animation this simple. If a Lottie is commissioned later, this screen is the reference to match. Recorded as a decision, not an oversight.

No gradients anywhere — a true radar sweep wants a conic gradient, which [[visual-identity]] bans, so depth comes from opacity and line weight only. Everything stops under `prefers-reduced-motion`, which leaves a static populated map with the arm parked at 206° — still readable as a radar, just not a spinning one, and not a frozen mid-animation frame.

Kept from the first pass: the three **honest stages** ("Found 24 places nearby" / "Reading what locals say" / "Picking your one") mapped to the real backend sequence — Places or location-cache lookup, the Gemini call, the assembled response — advancing on real events, with stage 1's count real because Places returns candidates before Gemini runs. Still no percentage and no bar: durations aren't knowable (0.6s cached to ~16s cold), and HIG forbids faking determinate progress or switching indicator shape mid-task. Also kept: **Cancel** (HIG Status — offer it for anything people might want to interrupt; a ~16s wait qualifies and the original screen offered no way out) and the honest **"up to 15 seconds"** expectation, which is not a revival of the wrong "about 5 seconds" line cut from Home.

The old bounce+glow orb, `.loading-label` and `.loading-btn` are gone from `shared.css`, and 05's layout lives in its own file — which also closed the dangling `.home-top` / `.home-cta` bug it inherited from the original split.

**06 Result — hero photo added 2026-09-07.** A real Places-style photo now sits full-bleed across the top of the hero card (`hero-photo-example.jpg`, a night shot of Restoran Nasi Kandar Ar Rashid; the mock hero name was changed to match the photo rather than leaving them contradicting each other). Four decisions, worth not re-litigating:

1. **No text over the photo.** Legible text on a real photo needs a scrim, and a scrim is a gradient — [[visual-identity]] bans those and already carries two sanctioned exceptions, both transient motion cues. A third, on a *persistent* surface, is exactly the drift the rule exists to prevent. It's also fragile in practice: Places photos are whatever the uploader shot, so no fixed overlay colour survives a bright lit facade, a dark interior and a white-tablecloth shot.
2. **Fixed 16:10 box, `object-fit:cover`, 120px tall.** The box is fixed and the photo is cropped to it, never the reverse, or the card height changes with every result. Not taller than 120px because the name, meta and reason have to clear the fold.
3. **Inside the card, not a banner above it.** The photo belongs to the pick, so it sits within the card's rounded clip — one object on screen rather than two stacked ones.
4. **Order is name → meta → reason.** The meta row was moved *above* the reason after rendering it: `reason` is model-generated with no length cap, and a long one pushed distance and price — the two facts you actually decide on — off the first screen. The name also dropped 17px → 16px, because real Places names are long ("Restoran Nasi Kandar Ar Rashid" is typical, not a worst case) and at 17px it wrapped to three lines.

**Copy on screen 06 (2026-09-07).** Sadri asked whether "Your pick" could become something warmer like "the best we got for you", and "Also nearby" something like "nearby food you may like" — explicitly inviting a judgement rather than obedience. Resolved as three different jobs, not one:

- **Bar title is "Picked for you."** It was briefly "Your pick", which Sadri correctly caught as claiming the wrong owner — the user picked nothing, the app did, so a possessive is a small lie on the one screen that most needs to feel trustworthy. "Picked for you" says who chose and for whom, in two fewer syllables than "Recommendation". Still short, because a bar title is chrome: stable, scannable, sharing a fixed 44px row with the location chip across six screens. A sentence there would break the shared `.appbar` and force the chip to truncate for nothing.
- **Voice is split on purpose.** The bar stays neutral and factual; the first-person voice lives only in the lead sentence. Chrome shouldn't have a personality — [[apple-hig]] → Writing is wary of "we" precisely because the referent goes vague — but a recommendation can.
- **The uppercase "HERO PICK" label is gone, replaced by a sentence in the app's voice:** *"Here's the one we'd send you to."* Two reasons. The bar already said "Your pick" 20px above it, so the label was the same sentence twice in chrome voice. And this is the screen's peak moment — a warm sentence earns its space where a category label doesn't. Sentence case, one full stop.
- **No superlative.** "The best we got for you" is a quality claim the app can't substantiate: it's one model's pick from ~24 Places candidates, and the product's promise (see [[product-overview]]) is *one honest answer*, not the best one. Overclaiming on the peak screen is also what makes an app feel like marketing. Warmth without a boast is the line.
- **"Also nearby" → "Specialties nearby."** Accurate to what the section actually is: [[product-overview]] defines specialties as *different* restaurants each known for one iconic dish, labelled with `foodCategory`. "Nearby food you may like" would imply a personalisation the app doesn't do — there's no taste profile, no history, nothing to base "you may like" on.

Losing the pomegranate label doesn't break the colour-meaning rule: the hero accent still lives on the card's meta row, and the specialty chips stay pistachio. `.section-label` was removed from `shared.css` since nothing else used it.

Still crooked, and flagged rather than fixed: **the specialty chips show only the `foodCategory`** ("Ramen", "Sushi", "Satay"), so a person can't act on them — they name a cuisine, not the restaurant that serves it. That's the substance of the remaining chips work, not the styling.

**Directions is the primary action (2026-09-07).** "Take me there" is what someone wants after reading the pick, so it's the filled pomegranate button and "Find something else" drops to a ghost beneath it. Both sit in the pinned footer, not inside the card: the card scrolls, and a primary action that can scroll out of reach isn't one. Footer band is ~122px.

**Which nav app: no chooser by default.** iOS has no "default maps app" API, so the plan is to check `canOpenURL` for what's actually installed (`comgooglemaps://`, `waze://`, plus Apple Maps always) and show a short action sheet *only* when more than one is available — otherwise open it straight away. A chooser on every tap is friction on the app's one repeated action, and remembering the choice would mean a settings screen this product deliberately doesn't have. **Swift gotcha:** `canOpenURL` returns false unless those schemes are listed in `LSApplicationQueriesSchemes` in `Info.plist`, and it fails *silently* — on a device with both apps installed it just looks like neither is there.

**This button is blocked on a backend change, and so is part of the card that already shipped in the mockup.** The response carries `name` and `address` only — no `latitude`/`longitude`, no `placeId`, no `rating`. So the deep link would have to pass a text query for the nav app to re-geocode, which for a chain (and the example hero is one) sends people to the wrong branch. The `0.4 mi` and `★ 4.7` in the meta row are in the same position: the mockup is showing numbers the API doesn't return. All of it already comes back from Places Nearby Search in the backend and just isn't passed through — a passthrough change, no new calls, no new quota. Full table in [[api-contract]].

**Separators (2026-09-07).** Screen 06 now has two rules, and both run **full-bleed** — edge to edge — while the text they separate stays on the 22px content inset: one under the app bar (the `.appbar.scrolled` state) and one above "Find something else". `.content` is padded 22px, so a plain border stops short at each edge and reads as an *underline belonging to the text* rather than as a boundary between two surfaces; negative margins push the rule out and matching padding puts the content back. The shared rule for that lives in `shared.css` next to `.result-footer`.

Why the footer earns one at all: "Find something else" is a different kind of thing from everything above it — the content answers the question, this discards the answer and asks again. So it sits in its own band at the bottom rather than as one more item in the scroll, with an opaque `--bg` fill so content scrolling underneath disappears behind it instead of showing through.

Hairlines, not shadows or filled bars. iOS separates surfaces with a hairline and material ([[appbar-ui-design]] conflict #3), and [[visual-identity]] bans drop shadows — same instinct applied to chrome.

**Fallback is designed, not assumed.** [[api-contract]] says no `photoRef`, or a `photo_limit_reached` 429, falls back to the bundled generic `foodCategory` icon — never a broken image. `.hero-photo-fallback` renders that in the same 120px box so the layout is identical either way; the markup for it is in the file, commented out.

**Two problems this surfaced, both real and both open:**

- **`get_photo` returns no attribution data.** Google requires photo attributions be displayed, and the contract's response is `{photoUri}` only. The mockup has a `.photo-credit` line styled and positioned so the layout already accounts for it, with placeholder text — but the backend has to return the attribution before that line can say anything true.
- **Permanently re-hosting Places photos needs a licence check.** The pipeline downloads the image, re-encodes to WebP, stores it in Firebase Storage and caches the URL for 365 days (see [[log]], 2026-09-03). Google Maps Platform terms are restrictive about caching Places content — Place IDs may be stored indefinitely, most other content may not. Worth checking before this is a public portfolio piece, since the whole point is to show good practice.

**Still no design pass on:** the specialty chips (they're plain text chips; `foodCategory` icons exist for them per the contract) and the footer action.

## Button labels: one line, always (2026-09-07)

`.btn-primary` and `.btn-ghost` are `white-space:nowrap` — a two-line pill reads as a broken control. Default size is 13.5px; a button whose label doesn't fit drops to a smaller size on its own screen, with **11.5px as the floor**. Below that a control label stops being comfortably legible, so a label that doesn't fit at 11.5px means the *copy* is too long. Shrinking type is not a licence for long labels.

**Screen 04 was the one that didn't fit.** The pill is 198px; with the icon (16px + 8px gap) and 20px padding each side, the label gets 134px. Measured against SF Pro Rounded Bold:

| label | 13.5px | 12px | 11.5px | verdict |
|---|---|---|---|---|
| "Find me something good" | 168px | 149px | 143px | **no fit at any size** |
| "Find me a good place" | 145px | 129px | 123px | fits at 12px |
| "Find me a place" | 107px | — | — | fits at full size |

First pass dropped the icon to make room for the original copy. Sadri wanted the icon kept, so **the copy gave way instead** — which is the better outcome and the rule already written here: a label that won't fit at the floor means the copy is too long, not that the type should go smaller.

Current: icon + **"Find me a good place" at 12px**. It keeps "good", which is the actual promise (a value pick, not just any nearby restaurant). "Find me a place" is the fallback if 12px ever reads too small beside the other buttons — it fits at the full 13.5px.

Every other button was measured too and clears 13.5px comfortably: "Continue" (61px), "Directions" (69px + icon), "Open Settings" (96px + icon), "Try again" (62px + icon), and the "Find something else" ghost (127px).

**CSS can't measure text and auto-fit**, so these sizes are worked out per label rather than pretending a `clamp()` does it. In SwiftUI it becomes real adaptive behaviour — `.lineLimit(1).minimumScaleFactor(0.85)` — and the sizes above are what that will settle on, so they're worth keeping as the reference. If the Home copy ever grows, "Find me a good place" is the shorter alternative already measured; it fits at the full 13.5px.

## The app bar (04, 05, 07–09) — unified 2026-09-07, screen 06 removed 2026-09-08

Three near-identical headers had drifted apart: `.home-header` on 04, `.state-header` on 05 and 07–09, and a centred `.result-top` wordmark on 06. They are now one `.appbar` component in `shared.css`, so the top of the app never shifts as you move through it. Built against [[appbar-ui-design]] for the anatomy and [[apple-hig-components]] → Layout and organization for the platform rules.

**Slots: left / centre / right.** Partial bars are normal, and this app uses left + right only. The centre is deliberately empty — it's the overflow slot if a screen ever needs a segmented control or a search field.

**Left is the title, and it says where you are, not who made the app:**

| Screen | Title |
|---|---|
| 04 Home, 07 Location off, 08 Nothing nearby, 09 Couldn't get an answer | HungryNow |
| 05 Searching | Searching |
| ~~06 Result~~ | ~~Picked for you~~ — **no bar since 2026-09-08**, see the screen 06 section below |

Home and its states carry the wordmark because that *is* the root screen's identity; 05 and 06 name the screen instead. Explicitly **not** a centred logo on every screen: [[apple-hig]] → Branding says keep branding secondary and don't spend screen space on a logo unless it provides context. That's also the first of the five places [[appbar-ui-design]] and the HIG disagree — it recommends a centred logo for home screens, and the HIG wins.

**Right is the location chip** — status, not a control. The answer only makes sense relative to where you are, so it stays on every screen that has a location, flipping to a pomegranate-tinted "Location off" on screen 07. It truncates with an ellipsis at 50% of the bar width and can never push the title off the bar, because a real Places result can be "Kuta Selatan, Badung Regency", not just "Seminyak".

**Height is a fixed 44px** on every screen, so nothing below the bar jumps between screens.

**Flat by default, hairline when scrolled.** Bar and background are one surface; `.appbar.scrolled` adds a 1px hairline — a hairline, not the drop shadow [[appbar-ui-design]] suggests, since iOS separates with a hairline and material (the third of the five conflicts). **`.scrolled` currently has no consumer:** screen 06 was the only screen that scrolled and it no longer draws this bar. Kept deliberately for the next scrolling screen rather than deleted, so the hairline-not-shadow reasoning doesn't have to be re-derived.

## Screen 06 — restructured 2026-09-08 (the result screen)

Rebuilt eight times in one day, mostly at Sadri's direction, and several of his calls beat the version I had reasoned out. Current state and the arguments behind it:

**Edge-to-edge media, 228px, running to y=0.** From reference 010 (a travel-app detail screen). 200px of composition plus the 28px status-bar band it runs under. Full-bleed came from moving `.content`'s horizontal padding onto the individual text blocks — **a negative-margin bleed cannot escape a scrolling ancestor**, because `overflow-y:auto` forces `overflow-x` to `auto` too, so the first attempt was silently clipped. Full-bleed is now the default on this screen and the inset is explicit, which is the more robust direction.

**A three-photo snap carousel**, `scroll-snap-type: x mandatory` — mandatory, not proximity, so a photo can never rest between two. Slides are full card width, no peeking sliver. Page dots sit in the sheet, not on the photo (dots over an unpredictable Places photo need a scrim, which is banned) and are **not coloured**, per [[apple-hig-components]] → Page controls. Slide order alternates kind — exterior, food, wide street — because two facade shots adjacent read as a duplicate-image bug, which is a sort rule for the backend, not just an arrangement here.

**No app bar.** Its two slots moved into the sheet as an eyebrow row: "Picked for you" leading, location chip trailing, same left/right logic the bar used. This is what lets the photo reach the top of the screen without any app text over it, and it puts the location next to the thing it qualifies. A recorded exception to the unification, not drift — 06 is the destination screen, and shedding chrome on arrival at a detail view is the platform convention. Accepted cost: the bar disappears on the 05 → 06 transition.

**The status bar floats on the photo**, absolutely positioned so it consumes no layout height, with `preferredStatusBarStyle` to be computed at runtime from the photo's top band (Sadri's idea, and better than my y=28 compromise — screen 02 guarantees legibility by *authoring* a pale top strip, which only works for assets we control). Four traps for the Swift side are written into the screen file; the residual ambiguous-photo case is accepted and documented rather than papered over.

**An overlapping sheet, transparent except where it crosses the photo.** It rises 36px over the media with a 28px top-right corner. Only that overlap band is opaque — below the photo there is nothing to hide, and an opaque fill there was what blocked the `.softbg` tint and produced a visible seam. Took three attempts to get right; the two wrong versions and why they were persuasive are recorded in the screen file.

**Facts as value-over-label, not chips.** `.fact-row` / `.fact` in `shared.css`, fixed order (distance, price, rating), reused on screen 08. The first build used outlined pills and **broke the "no pill everything" rule already in [[visual-identity]]** — Sadri caught it, the review the day before had missed it, and the rule has since been sharpened with an operative test: *a fact is text, not an object*. `metric-chip-row` (adopt item 1) survived the rendering change untouched, which is the proof the pills were never part of it; conflating "component" with "chip" is what produced them.

**Rating confidence context — added 2026-09-16.** The rating column keeps the score as its primary value and uses the review count as the secondary label (`star.fill 4.9` / `1.5K reviews`). The filled star uses the hero-accent token, matching [[visual-identity]]'s existing iconography rule; gold was rejected because it would introduce a third accent and break palette swapping. This adds confidence context without creating a fourth fact or competing with distance and price. If the count is unavailable, the native view falls back to the existing `Rating` label.

**Specialty list, not a chip row.** Place name primary with `foodCategory` as glyph + text below it (`origin-tag`). This needed **no backend work** — `name`, `address`, `reason` and `description` were already returned for every specialty and were being discarded, which is the opposite of the usual gap. `clipped-scroll-hint` was **rejected** here: `specialties` is schema-locked at 2–3 items, so a clipped card would be a lie about scrollability, and [[apple-hig-components]] → Layout and organization wants a list rather than a collection for text-only content.

**Specialty decision context and actions — added 2026-09-16.** Each specialty now has one compact metadata line containing an outlined specialty-accent star and rating, review count, and per-person price range. It stays as text with middle-dot separators rather than becoming three chips. The outline differentiates these secondary picks from the hero's filled star. Beneath it, one borderless action row provides separate `Details` and `Directions` text actions with 44pt minimum tap areas; neither is boxed or pill-shaped, and the restaurant row itself is not tappable. Details navigates to the shared full-screen restaurant-details destination; Directions hands off to navigation. The Directions action uses a simple filled navigation pointer (`location.fill` in native SwiftUI). Values in the HTML are design fixtures, not validated live restaurant data. The native version needs rating, review count, price range, `placeId`, and coordinates in each specialty response before porting the metadata and handoffs.

**“Why this place” is permanently visible — revised 2026-09-17.** The explanation is core evidence for deciding whether to follow the recommendation, not advanced information, so the disclosure control was removed. The former lead sentence and hidden supporting sentence are one concise paragraph under a noninteractive heading; this removes a tap and avoids showing two overlapping reasons. Keep the native copy short enough to scan, but never truncate the underlying accessibility value.

**Full-screen in-app Place Details — revised 2026-09-16.** A low-emphasis, unboxed row after “Why this place” reads “Restaurant details” with the supporting line “Photos, hours, reviews and more.” It navigates to `screen-06a-place-details.html`, a reusable full-screen destination with a conventional Back control rather than a draggable sheet. The opening status bar, title bar, and HungryNow context form one surface; the centered `Restaurant details` title and its hairline appear after 36px of scroll. HungryNow leads with the app-generated “Why this one” context, plate-and-clock motif, and primary Directions action; a bordered provider region below retains `Google Maps` attribution and approximates the standard themed component. The HTML deliberately omits fixed gallery fixtures: **native implementation must embed `GooglePlacesSwift.PlaceDetailsView` with `.media()` and `.reviews()` (or `allContent`) and let Google own the photo collage/gallery, image count, review count, ordering, incremental loading, and attribution. Never render an app-owned photo carousel or raw `GMSPlace.reviews` cards, never add app-owned review pagination, and never promise all or unlimited provider content because the UI Kit exposes no count/limit contract. If the package or the dedicated restricted iOS Places key is missing, stop, tell Sadri what must be installed/configured, and do not create a mock native substitute or reuse the Firebase/server key.** Loading/quota-error states stay at screen level.

**One-row footer, 74px.** Directions flexes to fill and uses the same simple filled navigation-pointer glyph as the specialty Directions actions; the secondary is a 34px icon-only button using a two-arrow circlepath — deliberately *not* screens 08/09's single-arrow refresh, since this swaps the answer rather than retrying a request. Its `.accessibilityLabel` is mandatory, not optional. Kept pinned rather than dropped into the flow: a primary action that can scroll out of reach isn't one.

**`.hero-lead` was cut** ("Here's the one we'd send you to.") to buy fold clearance. The eyebrow absorbed its job, so the slot now holds one statement instead of two — and it disposed of the "we" referent problem from the mockup review by deleting the sentence rather than resolving it. If the lead ever returns, that argument returns with it.

**The general lesson from the day:** this screen shed the app bar, the scrolled hairline and (briefly) the softbg, and needed its status bar pulled out of the flex flow. Four shared rules that were correct on eight screens and wrong on the ninth once it acquired a photograph. **A screen built around a photograph is a different kind of screen and inherits less from the shared set than the others do** — worth expecting rather than rediscovering per rule.

## The soft background (04, 05, 06, 07–09) — unified 2026-09-07

Two blurred accent circles — pomegranate top-right, pistachio lower-left — behind every in-app screen, as one shared `.softbg` component. They are what stops these screens reading as plain white, so having them on some screens and not others made the flow feel like two different apps.

**Screens 05 and 06 never had them.** Both predate the pattern, which arrived with screen 04, and the app-bar pass didn't catch it because the bar and the background are separate components. Sadri spotted it. `.home-shapes` (04) and `.state-shapes` (07–09) were the same rules under two names and are now both `.softbg`.

It sits as a sibling of `.content` inside `.screen`, absolutely positioned — which matters on screen 06, where it stays put while the content scrolls over it rather than scrolling away. Positions dodge the middle of the screen on purpose, since screen 05's radar and screen 04's illustration both live there. Screen 02 keeps its own `.welcome-bg` (four circles, tuned to the illustration) rather than being forced into this.

**The general lesson, worth applying to the next drift:** the flow is only as consistent as its *shared* components. Anything defined per-screen — even identically — will drift, and it drifts silently because each screen looks fine on its own. Both fixes this session (app bar, soft background) were the same bug found twice.

## Edge-case states (07–09, designed 2026-09-07)

All three are **inline states, not alerts.** HIG's Feedback pattern reserves an interruptive alert for something critical and actionable; none of these qualify. All three keep Home's header so they read as a state of Home rather than a different app, and all three follow HIG's Writing rules — say what's wrong and what to do about it, no "we", no "oops", no blame, and never a bare dead end without a next action.

**07 Location off** — the only genuinely unrecoverable one: Home's single button physically cannot work, so in this state Home doesn't show that button at all, it shows this. Primary action is a deep link to Settings (HIG's Settings pattern: push only the rarest, most global option out to the system Settings app, with a deep link to get there), plus the two exact taps to look for once there, since "Open Settings" drops people at a screen with several rows. The location chip flips to a pomegranate-tinted "Location off" instead of a city name. **No "Not now"** — dismissing would return to a Home screen whose only button can't work, which is the very thing this screen replaces.

**08 Nothing nearby** — maps `404 no_results`. Framed as an empty state, not a failure: nothing broke, there is simply no food inside the search radius. Names the radius explicitly (1.5 km, matching the backend) because that's the fact that makes the situation make sense, and offers "Try again" since the honest fix is to move.

**09 Couldn't get an answer** — one state for every retryable failure: `places_lookup_failed`, `recommendation_failed`, and any transport-level error. No error code shown to the user. Copy covers both plausible causes in one sentence (their connection, or the service) rather than guessing wrong.

**Recovery illustration direction, revised 2026-09-15:** Screens 07–09 use object-only clusters rather than the recurring traveler. Each composition has one dominant state symbol plus a compact set of food/search objects, preserving the established rounded illustration style without making utility states feel like narrative scenes. No people, faces, hands, limbs, mascots, or anthropomorphic objects.

**Recovery layout, revised 2026-09-15:** The illustration region flexes to consume all available space between the app bar and the recovery copy. Copy and supporting facts/steps stay beneath it, while the footer action remains pinned to the bottom thumb zone. Screens 07–08 use a hairline above that fixed footer to distinguish the recovery action from the scrollable guidance, matching the result screen; Screen 09 remains unchanged. Compact-height screens retain a 120px minimum illustration region and can scroll the main content rather than displacing the footer.

**Open disagreement with [[api-contract]]:** that page says map `429`/`502` both to a generic "try again" state. For `502` that's right. For `429` `daily_limit_reached` it isn't — the cap is for the whole day, so "Try again" is a button that's guaranteed to fail, possibly for hours. Same for `photo_limit_reached`. That case needs its own copy ("back tomorrow", no retry button, or a retry that's disabled) — flagged as an open item below rather than silently mocked, since it's a product decision (and a portfolio-honesty one: a demo that hits the cap looks broken).

## Illustrations

Style locked in: **flat 2D cartoon, bold varied-weight outlines, no gradients, no 3D, palette-limited**. The 3D/clay style was considered and argued against — it contradicts the "no gradients/shadows" spec, is the strongest current AI-generated visual tell, and would force 3D assets across every illustrated state.

Prompt rules that actually matter (learned the hard way):
- Every prompt must carry: *"no text, letters or written characters anywhere"* — generators produce garbled fake signage otherwise. The current Welcome art has this problem; the banner crop hides most of it.
- Every prompt must carry: *"square 1:1, subject small and fully contained in the center, wide empty margins on all four sides, nothing touching the frame edges."* Generators ignore "generous padding" but respond to "zoomed out, small in frame." The first attempt was unusable because the scene ran off the edges.
- Palette clause verbatim: pomegranate red `#A6243D`, pistachio green `#8FA876`, deep aubergine `#2B1512` outlines, warm off-white `#F7F1EF`, plus *"no browns, tans or golds"* (a stray gold crept into the steamer in the current art).
- **Fills, not outlines:** state explicitly that *every large shape is filled with a solid flat colour from the palette, nothing left as bare white outline*, and name the fills for the biggest objects. Without it, generators hand back line art with white interiors and the result reads as a colouring-book page. Learned on the first Welcome attempt.
- **Density comes from floating props:** four or so oversized dishes, six or seven scattered solid dots at varying sizes, a few motion arcs and sparkles. These fill the frame without adding scenery, which is the thing that invents fake signage. Do not ask for an empty picture when what is wanted is a picture with no *scenery*.
- **Character continuity:** paste the same character description every time. Since 2026-09-07 the description is no longer aspirational — it is transcribed from the delivered Home art, which is now the reference asset every later illustration must match:

> a young traveler with a round head and soft chunky rounded limbs, short curly near-black hair in soft rounded clumps (deep aubergine #2B1512, same as the outlines), peach skin, plain white short-sleeve t-shirt, olive-green trousers, dark red shoes, a rounded red backpack worn on both shoulders, and a green rolling suitcase with rounded corners

  Welcome = being handed food on arrival. Home = same traveler undecided among the carts (delivered). Same character across screens is what makes it read as one illustrated world rather than assorted stock art. *(The earlier description said "messy dark-red hair" — the generated art came back near-black and that version is now the canon, so the wording was corrected to match reality rather than the reverse.)*

**Home illustration: done (2026-09-07).** Generated from the rounded prompt below, then background-removed and dropped in as `home-illustration.png`. It reads as intended — the traveler mid-shrug between two carts with four dishes and motion arcs circling their head, all rounded shapes, aubergine outlines, no letterforms anywhere.

How the cut was done, in case it needs redoing: flood fill inward from all four edges on the near-white background with a ±26 tolerance, so only background actually connected to the edge is removed and enclosed light areas (the white t-shirt, the cream noodle bowl, the wrap) are left intact; then a 0.7px Gaussian feather on the alpha channel to kill the anti-aliasing fringe, crop to the content bounding box with 10px padding, and pad back out to square so `object-fit:contain` centres it. Verified by compositing the result onto the real `#F7F1EF` screen background at final size — no halo, no orphaned pixels.

Because the PNG is transparent, screen 04's art container lost its fill and radius entirely: it's now just a 216×216 sizing box, so the art floats on the screen background and over the decorative blurred circles rather than sitting in a visible tile.

**Two palette deviations, accepted rather than fixed:** the skin tone is a peach that isn't in the token set (unavoidable — the palette has no skin colour, and the Welcome art has the same peach, so it's at least consistent), and the fried egg yolk is a small yellow that technically breaks the "no golds" clause. Both are small and neither reads as a stray brand colour. Worth revisiting only if the yolk stands out at final size on device.

### Supergraphic mosaic prompt (screen 02) — added 2026-09-07

Sadri's verdict on the first hand-built CSS version: **"very rigid."** Correct — a uniform 4 × 3 grid of identical 68 × 80 cells is rigid by construction. Reference 005's mosaic works because its cells vary in size and a shape or two overflows its own cell. So the mosaic becomes a generated asset instead, and *irregularity is the thing the prompt has to buy.*

**Two prompt rules from this page are deliberately inverted for this asset**, and both inversions are the point:

1. **Edge bleed is required, not forbidden.** Every other prompt here says "nothing touching the frame edges" because the first Welcome attempt was amputated by the generator. A supergraphic is *defined* by being larger than its frame — cells must be cut in half at the left and right edges. The margin rule still applies to the character illustrations; it does not apply here.
2. **Uniformity is the failure mode**, not composition drift. Ask explicitly for unequal cell sizes and a hand-composed rhythm, or the generator returns a tidy checkerboard — which is what the CSS version already was.

The palette clause uses **pre-composited solid hexes** rather than the `--sg-*` alpha tints, because a generator cannot produce alpha. These are those tints flattened onto `#F7F1EF`, so quantising the delivered image to them lands exactly on-token:

| Token | Alpha value | Solid equivalent for the prompt |
|---|---|---|
| `--bg` | — | `#F7F1EF` |
| `--elevated` | — | `#F0E2DE` |
| `--sg-hero-1` | `rgba(166,36,61,.14)` | `#ECD4D6` |
| `--sg-hero-2` | `rgba(166,36,61,.28)` | `#E0B8BD` |
| `--sg-spec-1` | `rgba(143,168,118,.22)` | `#E0E1D4` |
| `--sg-spec-2` | `rgba(143,168,118,.42)` | `#CBD2BC` |
| `TextPrimary` | — | `#2B1512` (icon lines only) |

**The prompt:**

> Flat 2D vector mosaic in a soft rounded style — a modular grid of solid colour blocks and simple food icons, like a decorative tile wall. **Irregular grid, not uniform:** cells of clearly different sizes, some square, some twice as wide, some twice as tall, a few small ones tucked between them, arranged in a loose hand-composed rhythm — never a regular repeating checkerboard, never all the same size. Roughly 14 to 18 cells. About half are plain solid colour blocks; the rest hold one simple centred icon each. Icons, one per cell and no repeats: a round steaming noodle bowl, a location pin, a skewer of satay, a rounded cup, a crossed fork and spoon, a domed street-cart awning, a round plate seen from above, a soft rolled flatbread wrap, three short curved steam lines. Geometric cells: quarter circles filling a cell corner, half circles sitting on a cell edge, full circles, and one or two cells split diagonally. Everything built from circles, ovals and generously rounded rectangles with rounded stroke caps and joins — no sharp corners, no hard points anywhere. **A few shapes deliberately overflow their own cell into the neighbouring one**, so the grid does not read as rigid. Cells butt directly against each other — no gaps, no gutters, no visible grid lines, no borders between them. **The composition must run right off the left and right edges of the canvas with cells cut in half at both sides — do not centre it, do not leave margins; the edge bleed is intentional.** The top fifth of the image must use only the palest colours — warm off-white and the two lightest tints — with no dark blocks and no icons in that strip, because interface text sits over it. Absolutely flat: no gradients, no shading, no drop shadows, no highlights, no texture, no paper grain, no glow, no 3D. Palette limited to exactly warm off-white #F7F1EF, warm blush #F0E2DE, pale rose #ECD4D6, rose #E0B8BD, pale sage #E0E1D4, sage #CBD2BC, and deep aubergine #2B1512 used only for icon lines. No browns, no tans, no golds, no blues, no greys. Every block is a solid flat fill from that palette — nothing left as a bare white outline. No text, letters, numbers or written characters anywhere — no signage, no labels, no menus. Wide landscape canvas, 3:2.

**If it comes back over-decorated,** cut the icon count to five and raise the number of plain colour blocks. Density is not the goal here; the character illustrations needed floating props to fill a frame, a mosaic fills its frame by definition.

**Post-processing on delivery** (the part that protects the spec rather than trusting the generator):
1. **Quantise every pixel to the seven palette hexes.** This is the important step — it kills any gradient, soft shadow or off-palette drift the generator sneaks in, and lands the asset exactly on-token. Generators are especially prone to adding soft shadows *between* tiles, which is precisely what [[visual-identity]] bans.
2. Crop to the band's 272 × 200 aspect (1.36:1) from the 3:2 source, keeping the bleed at both sides.
3. Verify the top strip really is pale — measure it, don't eyeball it — and repaint it if the generator ignored that clause.
4. Drop it into `.sg` as a single `<img>` replacing the CSS grid, keeping the `-15px` offset and `aria-hidden`.

**Reversibility:** the CSS grid version stays in git history and the four `--sg-*` tokens stay in `shared.css` either way, so if the generated mosaic disappoints, the hand-built one is one revert away — and it is still the only zero-asset-cost option.

### Home illustration prompt (screen 04)

**Rounded, not angular** (Sadri, 2026-09-07). The art was reading sharp-cornered against an app built entirely on rounded language — SF Pro Rounded, 100px pill buttons, rounded cards — so the shape vocabulary is now stated in the prompt instead of left to the generator: circles and soft rounded rectangles, rounded stroke caps and joins, no sharp corners or hard points anywhere.

**The container no longer forces the composition.** Screen 04's art box was `object-fit:cover` with an 18px radius; it is now `object-fit:contain` with a 34px radius and a background fill, so any aspect ratio or slightly off-centre composition fits whole instead of being cropped to fit. The margin clause is therefore softened from "nothing touching the frame edges" to generous-but-organic breathing room. It is not dropped entirely — it exists because the first illustration attempt was genuinely unusable from edge-bleed, where the subject ran off its own canvas. That is a generator failure, not a container one, and `contain` cannot rescue a subject the generator already amputated.

*(Correcting an earlier claim on this page: the box did **not** clip ~8% of the art. A square source in a square box under `cover` clips nothing — the placeholder is 560×560. Clipping only ever happened if the generated file came back non-square, which `contain` now also handles.)*

**Primary — the shrug at the crossroads.** The moment being drawn is *indecision*, not eating. Food appears as choices around the character, none of them chosen yet.

> Flat 2D cartoon illustration in a soft rounded style. Every shape built from circles, ovals and rounded rectangles — rounded stroke caps and joins, generously rounded corners, no sharp corners, no hard points, no rigid straight angles anywhere. Bold varied-weight outlines, no gradients, no shading, no 3D, no drop shadows, clean vector look. A young traveler with a round head and soft chunky rounded limbs stands among a few street-food carts, caught mid-shrug — arms out, palms up, head tilted, eyebrows raised, a big open-mouthed "where do I even start?" grin. Three or four little food carts sit loosely around them with rounded domed awnings, and above each one floats a single oversized rounded dish: a round steaming noodle bowl, a plump skewer of satay, a soft rolled flatbread wrap, a round bowl of rice with a fried egg. A few short curved motion lines and two small round sparkles arc outward from the traveler's head to suggest a spinning choice. The traveler: young, messy dark-red hair in soft rounded clumps, white t-shirt, olive-green trousers, rounded red backpack, small green rolling suitcase with rounded corners beside one leg. Loose, playful, hand-arranged composition — the traveler roughly central but slightly off-centre is fine, nothing rigidly symmetrical. Zoomed out with comfortable breathing room around the scene; the subject may sit a little low or to one side but must stay whole and unclipped. Flat warm off-white background #F7F1EF. Palette limited to pomegranate red #A6243D, pistachio green #8FA876, deep aubergine #2B1512 for all outlines, and warm off-white #F7F1EF. No browns, no tans, no golds. No text, letters, numbers or written characters anywhere — no signage, no labels, no menus.

**Alt — the overhead fork in the road.** Punchier as a thumbnail (reads as a shape, not a scene), weaker on character continuity since the face barely shows. Worth generating both and picking.

> Flat 2D cartoon illustration in a soft rounded style — circles, ovals and rounded rectangles only, rounded stroke caps and joins, no sharp corners or hard points anywhere. Bold varied-weight outlines, no gradients, no shading, no 3D, no drop shadows. Top-down view of a small round plaza where three softly curving streets meet. A young traveler with a round head and chunky rounded limbs stands near the middle of the plaza looking up at the viewer, arms out in a shrug. Each street ends in one oversized rounded dish sitting like a signpost — a round steaming noodle bowl, a plump skewer of satay, a round bowl of rice. A few small round potted plants and two rounded domed awnings edge the plaza. The traveler: messy dark-red hair in soft rounded clumps, white t-shirt, olive-green trousers, rounded red backpack, green rolling suitcase with rounded corners. Loose organic composition, the plaza roughly centred but a little off-centre is fine, zoomed out with comfortable breathing room, the whole scene unclipped. Flat warm off-white background #F7F1EF. Palette limited to pomegranate red #A6243D, pistachio green #8FA876, deep aubergine #2B1512 outlines, warm off-white #F7F1EF. No browns, no tans, no golds. No text, letters, numbers or written characters anywhere.

**Negative prompt** (for generators that take one): `text, letters, words, numbers, signage, labels, menus, watermark, gradients, soft shading, drop shadows, 3D render, clay style, glossy plastic, photorealistic, brown, tan, gold, beige, sharp corners, hard angular shapes, pointed edges, rigid geometric layout, symmetrical grid, subject cropped or cut off at the edge, busy background, extra limbs, distorted hands`

**Why no thought bubble:** an obvious speech/thought balloon is the one composition generators reliably fill with garbled fake lettering even when told not to. The motion lines and sparkles carry the same "deciding" meaning without inviting text.

**Accept/reject check before dropping the file in:** no letterforms anywhere (zoom in on awnings and carts — that is where they appear); the whole subject is present, not cut off (off-centre is fine, amputated is not); shapes read rounded, not angular; outlines are aubergine, not black; no stray gold or brown; the traveler is recognizably the same person as in the Welcome art. Save the background-removed result as `output/mockups/home-illustration.png` (transparent, any aspect ratio) and keep the full-resolution version as `output/illustration-home-crossroads-fullres.png`.

**Knock-on decision, not yet made:** if rounded shape language is right for Home, the Welcome banner art becomes the odd one out and should eventually be regenerated the same way. It is already on the list for the no-text and no-gold clauses, so folding all three into one regeneration is the cheap path.

### Welcome illustration prompt (screen 02) — SUPERSEDED 2026-09-07

> Screen 02 no longer uses an illustration; it uses the geometric supergraphic described above. `welcome-banner.png` is kept in `output/mockups/` in case the decision is reverted, and this prompt is kept so it could be regenerated — but it is not the current design.

**Delivered 2026-09-07** as `welcome-banner.png` (option A, floating transparent PNG), on the second generation. The layout was rebuilt around it — see the 02 Welcome entry above.

**Prompt lesson worth keeping:** the first version of this prompt produced art Sadri correctly called too plain, and the cause was my own over-correction. Two clauses did the damage. "Completely empty background, no scenery" plus "two figures and one cart only" removed the floating dishes, scattered dots and motion arcs that give the Home art its energy — leaving two figures standing on an invisible line. And nothing in the prompt said the shapes had to be *filled*, so the awning, cart, counter and bowl all came back as bare white outline, i.e. half the picture read as a colouring-book page. **Empty of scenery is not the same as empty of elements** — scenery is what grows fake signage, floating props and dots cannot, so density and safety are separable and I had collapsed them. The fixed prompt states outright that every large shape carries a solid palette fill, names the awning red and the cart green, and asks for four floating dishes, six or seven scattered dots and motion arcs. That is the version below.


Written 2026-09-07 to bring the Welcome art up to the delivered Home art's style. It replaces `welcome-banner.jpg`, which is the last remaining piece of the old look — sharper shapes, a stray gold, and garbled fake signage that the current crop only partly hides.

**A layout decision came with this. Option A was chosen and built.** Both options are recorded because the reasoning still applies to any future illustration:

- **A — floating, transparent (recommended).** Same treatment as Home: the art is a background-removed PNG sitting on the screen background, with the decorative blurred circles showing through behind it. Consistent with screen 04, immune to both failure modes this art has historically hit (edge-bleed and fake signage in background scenery), and the cut-out method is already proven. Costs the full-bleed banner: screen 02's `.welcome-banner` block and its "full-bleed on purpose" rationale go away, and screen 03's dimmed copy of it has to change to match.
- **B — full-bleed banner (keeps today's layout).** Art runs edge to edge across the top 224px, no CSS change. But it needs deliberate, composed edge bleed, which is the opposite of every containment clause that exists because of the first failed attempt, and a background scene wide enough to fill the banner is exactly where generators invent lettering.

Prompt for A, the recommended one. Scene is **arrival** — the traveler is being handed food, the moment Home has not reached yet:

> Flat 2D cartoon illustration in a soft rounded style. Every shape built from circles, ovals and rounded rectangles — rounded stroke caps and joins, generously rounded corners, no sharp corners, no hard points, no rigid straight angles anywhere. Bold varied-weight outlines, no gradients, no shading, no 3D, no drop shadows, clean vector look. A young traveler has just arrived and is being handed a round steaming bowl of noodles across the counter of a small street-food cart, receiving it with both hands, head tilted up, eyes happy and crinkled, a big open-mouthed delighted grin. The vendor is a friendly round-faced figure behind the cart, visible from the chest up, one arm extended offering the bowl, the other resting on the counter. The cart has a rounded domed awning and softly rounded wheels, with two or three small rounded dishes set along its counter. A few small round sparkles and two short curved motion lines arc above the bowl to suggest steam and delight. The traveler: a young traveler with a round head and soft chunky rounded limbs, short curly near-black hair in soft rounded clumps, peach skin, plain white short-sleeve t-shirt, olive-green trousers, dark red shoes, a rounded red backpack worn on both shoulders, and a green rolling suitcase with rounded corners standing beside one leg. Two figures and one cart only — no crowd, no buildings, no street furniture behind them. Loose, playful, hand-arranged composition, roughly centred but slightly off-centre is fine, nothing rigidly symmetrical. Zoomed out with comfortable breathing room; both figures whole and unclipped. Flat warm off-white background #F7F1EF, completely empty — no scenery, no background objects. Palette limited to pomegranate red #A6243D, pistachio green #8FA876, deep aubergine #2B1512 for all outlines, and warm off-white #F7F1EF, plus peach skin. No browns, no tans, no golds, no yellows. No text, letters, numbers or written characters anywhere — no signage, no labels, no menus, no prices.

For B, take the prompt above and swap the composition clauses: replace *"Zoomed out with comfortable breathing room; both figures whole and unclipped"* with *"wide horizontal 3:2 composition filling the frame edge to edge, the cart's awning deliberately running off the top edge and the counter running off both sides, the traveler's face and the bowl kept fully inside the frame and well clear of every edge."* Keep the empty-background and no-text clauses exactly as they are — they are what stop the invented signage. Then crop to 620×820-ish for `object-fit:cover`, matching today's file.

**Negative prompt** (same as Home, plus the specifics this scene invites): `text, letters, words, numbers, signage, labels, menus, prices, watermark, gradients, soft shading, drop shadows, 3D render, clay style, glossy plastic, photorealistic, brown, tan, gold, yellow, beige, sharp corners, hard angular shapes, pointed edges, rigid geometric layout, symmetrical grid, crowd, extra people, buildings, background scenery, subject cropped or cut off at the edge, extra limbs, distorted hands`

**Why the background is specified as completely empty:** every previous problem with this particular illustration came from background scenery. The fake signage appears on background stall banners, and the stray gold appeared in a background steamer. An empty ground also makes the cut-out trivial and matches how Home ended up working.

**Note on the yellow ban:** Home's delivered art has a small yellow egg yolk, accepted as a minor deviation. Don't repeat it here — a second instance stops being an exception and starts being a fourth palette colour.

**After generating:** run the same accept/reject checks as Home (no letterforms, nothing amputated, rounded not angular, aubergine outlines, same character), then background-remove with the method recorded above, and save as `output/mockups/welcome-banner.png` plus `output/illustration-welcome-arrival-fullres.png`. Do not overwrite `welcome-banner.jpg` or `illustration-welcome-banner-fullres.png` until the new art is actually chosen — keeping the old files makes the before/after judgeable.

## Open items

- ~~Regenerate the Welcome art~~ — done 2026-09-07, `welcome-banner.png`, and screen 02's layout rebuilt around it.
- **Palette drift to decide on.** Three small non-palette colours are now shipping in the two illustrations: peach skin (unavoidable, the token set has no skin colour, and it is at least consistent across both), the yellow egg yolk in the Home art, and browns/tans in the Welcome art's satay skewer and flatbread wrap. The browns are the awkward one — "no browns, tans or golds" was an explicit clause, and five rounds of palette elimination were spent avoiding exactly this kind of drift. Options: accept them as incidental food colours and write that into [[visual-identity]] as a sanctioned exception, or regenerate with those two props swapped for palette-coloured dishes. Not urgent, but it should be a decision rather than an oversight.
- ~~Design pass on the rest of screen 06~~ — done 2026-09-08, see the screen 06 section above. The whole screen was restructured; `foodCategory` icons are in the mockup but the bundled icon set for real categories is not built.
- **`get_photo` must return Google's photo attributions.** Required by Google, currently absent from the response; screen 06 has the credit line laid out and waiting. Backend change, not a design one.
- **Check the licence position on permanently re-hosting Places photos** (365-day cached WebP copies in Firebase Storage). Maps Platform terms restrict caching Places content beyond Place IDs. Real exposure for a portfolio piece whose pitch is good practice.
- **Decide whether the searching animation ships as Lottie or as native SwiftUI shapes.** Mockup is hand-built SVG/CSS (see 05 above). Lottie costs the `lottie-ios` dependency plus commissioned artwork; native costs nothing extra and already matches the palette. Only worth revisiting if the animation gets more elaborate than a radar sweep.
- ~~Mock the three edge-case states~~ — done 2026-09-07, screens 07–09.
- ~~Decide the Welcome/Permission merge question~~ — decided 2026-09-07, merged into screen 02.
- **Decide the `daily_limit_reached` / `photo_limit_reached` state** (see the disagreement with [[api-contract]] above) — a day-long cap can't share the "Try again" screen. Either its own state, or raise the cap before the portfolio demo.
- Move remaining per-screen layout rules out of `shared.css` into their own screen files — 01, 05, 06 still have some.
- ~~Bug: screen 05 referenced `.home-top`/`.home-cta` from screen 04's file~~ — fixed 2026-09-07 by the 05 rebuild.
- **Screen 06 is the only screen anyone has actually looked at.** Sadri rendered it from screenshots during the 2026-09-08 session, which is how four separate defects were caught (the bleed being clipped, the seam, the flat ground, the pills). **Screens 02, 03 and 08 have all changed and still have not been seen by anyone.** The mockups are only viewable by opening them from Finder — the files link `shared.css` and their images relatively, so no in-app preview can resolve them. **A self-contained build (CSS inlined, images as data URIs) is what makes these reviewable at all, and it should exist before the next visual change.**
- **Verification note (2026-09-07):** markup was checked programmatically (per-file `<div>`/`<span>` balance, every referenced class defined, every image path resolving) but *not* rendered in a browser this session — no headless browser was available in the sandbox and Chrome wasn't responding. Screen 02's fit was worked out arithmetically instead (the budget comment sits in its `<style>` block); it should be eyeballed once.
- No dark-appearance mockups exist yet — [[visual-identity]] specifies dark fully, but nothing has been drawn in it, and the portfolio demo still needs a decision on which appearance to record.
