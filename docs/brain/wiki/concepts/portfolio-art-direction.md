# Portfolio art direction — making HungryNow eye-catching without breaking it

**Status:** decisions made 2026-09-07. This page does **not** replace [[visual-identity]] — that spec stays locked. This page closes three of its open gaps (food photography treatment, default palette/appearance for portfolio capture, app icon motif) and answers a separate question Sadri raised: the app is going in his portfolio, so how does it become as eye-catching as possible?

Prompted by two Pinterest/Dribbble references studied during design (the reference files themselves are not part of this vault). HIG check run against `apple-hig.md` → Foundations (App icons, Branding, Images, Color, Materials/Liquid Glass, Dark Mode, Motion).

---

## The core finding: HungryNow cannot buy the reference look, and shouldn't try

Both references are **carried by art-directed photography**. One shoot, one grade, consistent lighting, hand-picked crops. Strip that out and the layouts are ordinary. That is where roughly half their visual impact comes from.

HungryNow structurally cannot have it. Its images are **Google Places photos — uploaded by strangers**. A lit facade at night, a dark interior, a flash-lit plate, a white-tablecloth wide shot, something blurry. There is no crop, no grade, and no overlay colour that survives all of those, which [[app-mockups]] already found the hard way when the hero photo went in (hence: photo at the top of the card, no text over it, ever).

So the reference aesthetic is **unreachable, not merely unchosen**. Chasing it produces the worst outcome: a design that looks like it was *meant* to be photography-led and isn't quite pulling it off.

**Reasoning corrected 2026-09-07 (same day), by a third reference.** `visual-ref-travel-app-illustrated.md` reaches the same premium travel-app feel with **no photography at all** — its alpine hero images are illustrations. So the requirement was never photography; it is **one consistent art direction across every image**, and illustration satisfies it just as well.

The conclusion below survives the correction and is in fact strengthened, but the limit is now precise. That app can illustrate its *content* because "Swiss Alps" is a generic destination. HungryNow's content is a **specific named restaurant** — you cannot illustrate a business you've never seen, and you cannot commission one illustration per Places result. So the split is fixed:

- **App-owned surfaces** (welcome, home, searching, empty/error states) → illustration, one consistent style. Already in place.
- **The recommendation itself** → an unretouched Places photo, treated as evidence rather than decoration.

That is not a compromise between two looks. It is the only arrangement available, and framing the photo as evidence is what makes it read as product-grade rather than mockup-grade.

The counter-position, and the one this page commits to: **HungryNow's illustration-led identity is the stronger portfolio play regardless.** Original artwork plus a five-round palette decision demonstrates design judgment. Beautiful borrowed photography demonstrates image sourcing. For an audience of clients *and* hiring managers, the first is the harder thing to fake and the better thing to be seen doing.

## The portfolio thesis: look shipped, not look beautiful

Sadri's stated goal was "as eye-catching and interesting as I can." Reframing it, because the literal version is a trap for a developer's portfolio:

Dribbble-grade stills are now cheap — anyone can generate them, and reviewers know it. What is scarce is a **working app that also looks good**. So the target is not "prettiest static screen"; it is *this is obviously real, and whoever built it has taste.*

That reframe changes what to put in the portfolio, and it favours things HungryNow already has:

- **Keep the long, real restaurant name.** "Restoran Nasi Kandar Ar Rashid" wrapping to two lines is a credibility signal. Mockups always have short invented names.
- **Keep the photo attribution line visible.** Nobody fakes a Google attribution requirement.
- **Include one edge-case screen in the portfolio set** — permission-denied or no-results (screens 07-09, already built). This is the single strongest "this is real" signal available, because concept shots never have error states. Both filed references lack them entirely.
- **Lead with motion, not stills.** See the app icon and capture decisions below.

## Decision 1 — Food photography treatment

Closes: *"Real food photography treatment (crop ratio, grading/filter) not yet decided."*

**No grade, no filter, no vignette, no unified colour treatment.** This is a decision, not a deferral.

Reasoning: a grade only reads as intentional when applied to a consistent source. Applied across Places photos it will flatter maybe a third of them and visibly damage the rest — a warm grade on an already-orange night shot, a lifted-shadow curve on a dark interior. A half-working grade looks like a bug, and it is worse than no grade. [[visual-identity]] already bans "stock-photo-style food imagery with a heavy filter"; this extends the same logic to the honest reason.

Specification:

| Property | Decision |
|---|---|
| Crop | 16:10, `object-fit: cover`, centred — as already built on screen 06 |
| Box | Fixed height (120px in mockup) so card height never varies per result |
| Position | Full-bleed across the **top** of the card, inside its rounded clip |
| Text over photo | **Never.** A scrim is a gradient, and a gradient on a persistent surface is the drift [[visual-identity]]'s rule exists to stop |
| Grade / filter | None |
| Edge treatment | 1px inner `Hairline` border, so a photo with a white or blush background doesn't visually bleed into `Elevated` |
| Format | JPEG/HEIC with an **embedded sRGB profile**, @2x and @3x assets — per `apple-hig.md` → Images |
| Fallback | Bundled `foodCategory` icon filling the identical box (already specified in [[api-contract]]) |
| Attribution | Required and already laid out — blocked on the backend supplying it |

The one thing to fix: photo quality is now a **selection** problem, not a treatment problem. If Places returns several photos, prefer the one with the largest dimensions and a landscape aspect closest to 16:10 rather than simply taking the first. That is a cheap backend change and it does more for how the app looks than any filter would.

## Decision 2 — Default palette and appearance for portfolio capture

Closes: *"No default-appearance recommendation for portfolio screenshots/demo video."*

**Palette: Pomegranate & Pistachio.** No debate needed — it is the primary, and Rust & Mustard exists as a swap, not a second identity to maintain in parallel.

**Appearance: split by artifact, deliberately.**

- **Demo video → Dark.** The two motion moments both live on darkness. The radar sweep is a pomegranate conic gradient at ~34% alpha; on blush `#F7F1EF` that reads as a faint pink smear, and on wine-black `#241016` it reads as a genuine scanning beam. Same for the hero-reveal pulse-glow. The video's job is the wow moment, so it should be shot where the wow actually lands.
- **Stills → Light,** led by screen 06. Blush is the distinctive thing here and the visible result of five rounds of palette elimination. Portfolio galleries are saturated with dark-mode shots; a warm jewel-toned light palette stands out precisely because it's rarer.
- **Include exactly one dark still.** Not for looks — as proof. A correct dark appearance says the semantic-token work in [[visual-identity]] was actually done, and that reads to a technical reviewer as competence, not decoration.

**Honest cost:** this splits appearances across artifacts, and a purist would call that inconsistent. Each artifact is internally consistent, which is what matters, and the alternative — shooting everything light — throws away the app's best motion moment. If Sadri would rather have one appearance across everything, **shoot everything Dark**; the loss is the blush palette's distinctiveness, which is the smaller loss of the two.

## Decision 3 — App icon motif

Closes: *"App icon artwork not yet built... genuinely undecided between the two palettes' natural icon motifs."*

**Decision: a location pin with a single concentric arc, hero-accent on blush.** Not the sunburst, not the pomegranate.

Reasoning, in order of weight:

1. **A portfolio reviewer sees the icon with zero context.** Product meaning beats palette reference. The pin-and-arc says *find a place near me*, which is what the app does.
2. **It creates icon-to-app continuity** with the screen 05 radar — the same visual language in the icon and the app's most distinctive screen. Reviewers notice that kind of coherence, and it is a design-judgment signal rather than a decorative one.
3. **The sunburst says nothing.** It is generic and unrelated to food or recommendation.
4. **The pomegranate is a trap.** It references the *palette's name*, which no user or reviewer knows, and it reads as a fruit or grocery app. It would be the more distinctive mark and the less honest one.

Build constraints from `apple-hig.md` → App icons: built in **Icon Composer** as layers (background = blush; foreground = pin + arc), so the system generates light/dark/clear/tinted variants and applies Liquid Glass highlights; **crisp edges only** — no feathering, it breaks the system-drawn highlights; content centred so corner masking doesn't truncate it; **no text**; one concept; must read at 29pt. Do not swap core elements between variants.

**The known trade-off, stated so it can be overridden:** pin-and-arc is a common motif in nearby/discovery apps — it wins clarity and loses distinctiveness. The pomegranate wins distinctiveness and loses clarity. Given both audiences arrive with no context, clarity wins. If Sadri disagrees, the fallback is a pomegranate whose silhouette is *also* readable as a pin — but "clever mark" solutions usually fail at 29pt, so this should be tested at size before being chosen, not chosen and then tested.

### Revised 2026-09-08 — the pin-and-arc had no food in it, and that was an error, not a trade-off

Sadri's objection on seeing the artwork: the mark says nothing about food. He is right, and the reasoning above is where it went wrong. Point 1 justified the pin with *"the pin-and-arc says find a place near me, which is what the app does."* **The app does not find places.** [[product-overview]] defines it as one screen with one button labelled **"I'm Hungry"** — a decision tool for someone who wants to eat, where location is the *mechanism*, not the promise. The old decision optimised the icon for the mechanism. Point 4 also over-generalised: it correctly rejected the *pomegranate* for reading as a grocery app, and then quietly treated all food imagery as carrying that risk, which is not the same claim.

**The governing constraint, found by drawing it (nine candidates, `output/icon/`):**

> **Food, place, one shape, legible at 29pt — you get three.**

Detail small enough to sit inside a pin's counter measures roughly 2pt at 29pt and disappears. So the food signal cannot be an addition *inside* the mark; it has to live in the **silhouette**. That leaves two honest routes, and both are drawn:

| | Mark | Gets | Gives up |
|---|---|---|---|
| **Recommended** | **Fork-pin** — one closed path: three tines on top, body converging to a pin's point | Food *and* place fused in a single outline; no counter, so nothing to go opaque-wrong in the tinted/clear variants | Distinctiveness — it is a compound mark, and compound marks read slower than simple ones |
| Alternative | **Bowl & ping** — rimmed bowl, one arc above doing double duty as steam and as screen 05's radar sweep | The most food-legible mark drawn, and the safest small (two fat forms, nothing fine); keeps the radar continuity | "Near me" entirely — carried only by app context |

**Still pending Sadri's pick.** Superseded artwork stays on disk as the fallback (`app-icon-foreground-pin-arc.svg`).

**Six shapes were drawn and rejected. Recorded so nobody redraws them** — each failure is a geometric fact rather than a taste call, and the mockup page carries tiles for the first four:

1. **A bowl-shaped void as the pin's counter → a mouth.** A flat-topped hole inside a circle reads as a smile; the pin becomes a face.
2. **A bite out of the pin's head → two overlapping blobs**, not a bite, plus an unwanted Apple-logo comparison.
3. **A bowl with the arc touching its rim → a picnic basket.** The arc becomes a handle. This is the grocery-app trap point 4 was actually right about, arriving by a different route; the arc needs real clearance from the rim.
4. **A fork-pin with a flared belly → an arrowhead.** The widest point must be the tine shoulder itself, with no bulge below it.
5. **A bowl tapering to a point → a shield/badge.**
6. **Tine slots cut into a *round* pin head → starved outer tines** (~28 units wide), because the circle curves away from them. The fork head has to be a flat-topped block. Not a style preference.

**Constraint added to the build rules:** the fork-pin's smallest feature is its 46-unit tine gap — **1.30pt at 29pt**, and that gap *is* the food signal. Do not narrow it, and do not add a fourth tine: four tines force the gaps to 40 units (1.13pt) and they close. This is now the binding dimension in the icon, replacing the old counter radius.

**Unchanged by this revision:** the palette (`#A6243D` on `#F7F1EF` light, `#F58396` on `#241016` dark), the layered Icon Composer build, crisp-edges-only, no text, one concept, centred content, no element-swapping between variants — all the `apple-hig.md` constraints in the paragraph above still apply verbatim. Pistachio still appears nowhere: an icon has no hero/specialty distinction to encode, so it would be ornament. And the pomegranate is **not** revived by this — the objection to it was never "food is wrong," it was that a pomegranate references the palette's name, which nobody outside this vault knows.

### Revised again, same day — three components: food + time + place

Sadri asked whether "now" could be in the mark too, giving three components. **It can. Drawn as `app-icon-foreground-fork-clock-pin.svg` and it survives 29pt:** food in the three tines, **time in a clock counter set into the body**, place in the taper to a point. The clock works because it sits at the body's *widest* part, where there is room for a 256-unit face — the same reason the earlier counter-based attempts failed is why this one succeeds. Nothing sits inside the old pin's counter, because nothing can.

**The 29pt budget, now nearly spent.** The binding dimension moved off the tine gaps:

| Feature | Units | At 29pt | |
|---|---|---|---|
| Clock hand stroke | 42 | **1.19pt** | thinnest — sets the icon's floor |
| Wall, clock edge to outline | 45 | 1.27pt | closes up if the clock grows |
| Tine gap | 52 | 1.47pt | the food signal |
| Clock counter, diameter | 256 | 7.25pt | comfortable |

So: **don't thin the hands, don't enlarge the clock, don't add a fourth tine.** Verified by render at 340/120/87/58px.

**Two construction traps, both hit and both fixed — they will recur for anyone editing this path:**

1. **The outline must be ONE continuous subpath** tracing tines and body together. Drawing the tines as separate rectangles overrunning the body top means those overlaps hit `fill-rule="evenodd"` parity 2 and become **holes** — white slivers across every tine join. This shipped in the first render and was only visible in it.
2. **The clock hands must be ONE connected L polygon.** Two capsules meeting at the clock's centre overlap there, parity 4, punching a hole straight through the middle of the face.

**The argument against three, recorded because it is a strategy call and not a drawing problem:** the icon never appears without the word **HungryNow** directly beneath it. "Now" is therefore *already stated, in letters*, by the label — so a third of the icon's complexity budget restates the one component the user can already read, while food and place are not in the name at all. Three components also strains HIG's "embrace simplicity — a single clear concept beats a busy composition," and the clock is a real hole in the artwork, meaning one more place the system's recolouring shows through in the clear and tinted variants. The two-component fork-pin has **no counter at all**, which is the quiet reason it is the more robust mark.

**Sadri's pick is still the open item, now three ways:** three components (`-fork-clock-pin`), two (`-fork-pin`), or food-forward (`-bowl-ping`), with `-pin-arc` as the fallback. All four are on disk and on the mockup page.

## What to steal from the two references anyway

The visual layer transfers even when the photography doesn't:

| From the references | How it applies here |
|---|---|
| Accent reserved **exclusively** for actions, never decoration (Japan ref) | Stricter than the current spec. HungryNow's accents are reserved by *meaning* (hero vs specialty); tighten so neither ever appears as ornament |
| Selection shown by **size and elevation**, not colour | Useful on the specialty chips — keeps both accents free for meaning |
| Plain, unstyled type over rich imagery | Already the case. Do not add type effects |
| One consistent corner radius everywhere | Already specified — hold the line |
| Asymmetric whitespace: tight inside cards, generous between sections | Worth an explicit pass on screen 06 |

And what not to take: both references' novel layouts, the broken stepper, the fake radar encoding, the splash gate. `apple-hig.md` → Branding is explicit that a launch screen must not be a branding moment — HungryNow already does this correctly with screen 02 as the welcome, and the Japan reference gets it wrong.

## One wording risk found in [[visual-identity]]

That page says *"Color alone still signals which of HungryNow's two recommendation types the user is looking at."* `apple-hig.md` → Color says never use colour as the **only** signal, because of colour blindness.

In practice the spec is fine — fill-vs-outline SF Symbols, size, and position all differentiate hero from specialty, so there are redundant channels. But the sentence as written claims the thing the HIG prohibits, and a reviewer reading this vault as a work sample would notice. Worth rewording to "colour reinforces, alongside fill weight and placement" rather than leaving a claim the implementation doesn't actually need.

## See also

[[reference-adoption]] — the per-technique filter across all eight references, written after this page. It corroborates the portfolio thesis here with evidence rather than judgement: **none of the eight references shows a loading, empty or error state (8/8)**, so the screens HungryNow has already built are exactly what the reference genre cannot show.

## Open items

- The demo-video appearance decision assumes the radar sweep stays. If the searching animation is rebuilt as Lottie vs native SwiftUI shapes (open checklist item), re-check that the sweep still reads on dark before shooting.
- Photo *selection* logic (prefer largest/closest-to-16:10) is a new backend ask, not yet on the checklist.
- Icon must be tested at 29pt before it is considered done — both candidate motifs, if the pomegranate is revisited.
