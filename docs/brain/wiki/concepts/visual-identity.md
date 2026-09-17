# Visual Identity — "Pomegranate & Pistachio" (primary) / "Rust & Mustard" (backup)

**Status:** direction locked (2026-09-04). Primary palette: **Pomegranate & Pistachio**. Backup palette, built to the same standard and swappable at any time: **Rust & Mustard**. Not yet implemented in SwiftUI — this is the spec the "Visual polish pass" checklist item should build from. **Supersedes both earlier directions** ("Night Ledger"/"Charcoal Ledger", then "Golden Hour"/"Night Market") — see Revision history below.

## Why this exists

HungryNow is a portfolio piece as much as a product (see [[product-overview]]). A generic look actively hurts it — a rounded-card, soft-shadow, purple-gradient UI reads as "AI-generated" the instant a client or reviewer sees it, and undercuts the "AI-scalable, well-documented" pitch this whole project is meant to demonstrate. This page exists so the visual direction is a deliberate, documented decision, not whatever the default look would have been.

## Revision history

1. **Night Ledger / Charcoal Ledger** (ink navy, brass, parchment, New York serif) — avoided the generic-AI-look problem but read too dark and formal for a quick, reassuring "where do I eat right now" tool.
2. **Golden Hour / Night Market** (warm sand/cocoa, marigold + teal) — fixed the tone problem, but the neutral base (warm cream + espresso brown) turned out to be exactly the muted, warm-neutral palette a lot of AI-generated tools default to. Not distinctive enough for a portfolio piece meant to prove design judgment, not just "not ugly."
3. **Five rounds of direction options** (15 palettes shown total, comparison HTML for each round in `output/`) converging on two finalists that survived every elimination round: jewel-toned/fruit-forward **Pomegranate & Pistachio**, and grounded/spice-forward **Rust & Mustard**. Every palette that included blue, teal, or navy got eliminated across three separate rounds — that hue family is confirmed off the table for this project.

Sadri picked **Pomegranate & Pistachio** as primary and asked to keep **Rust & Mustard** as an equally real, ready-to-swap backup — not just a note in a "what we considered" section — so the palette can change mid-development without a redesign. See Architecture below for how that's built so the swap is genuinely low-cost.

## Architecture: how the palette stays swappable

Both palettes are specified against the **same semantic token names** — `Background`, `Elevated`, `TextPrimary`, `TextSecondary`, `HeroAccentSurface`, `HeroAccentText`, `SpecialtyAccentSurface`, `SpecialtyAccentText`, `Hairline` — each with explicit light and dark values, defined once as dynamic `Color` assets in the Xcode Asset Catalog (per `apple-hig.md` → Color: "prefer system/semantic colors... provide light + dark variants for any custom color"). No view ever references a hex value or a palette name directly — every view only ever says `Color("HeroAccentSurface")` etc.

This means: **switching from Pomegranate & Pistachio to Rust & Mustard later is a matter of pasting the Backup column's hex values into the same eight colorset assets** — zero SwiftUI code changes, no view touched, no rebuild of the design system. This is the same dependency-inversion instinct the rest of the codebase already uses (ViewModels never touch Moya directly, only a protocol) applied to design tokens instead of services. This is a swappable *build-time* choice, not a runtime toggle — the app ships with one active palette at a time; there's no in-app theme switcher, which would be real added engineering with no clear product reason for an end user to want it.

Recommended: keep both hex tables below in this doc as the source of truth, and additionally keep a `Theme.swift` (or similar) comment block listing both value sets side by side right next to the Asset Catalog, so a future "let's actually try Rust & Mustard for a week" swap doesn't require re-opening this page to find the numbers.

## Color system — the shared idea

Both palettes carry the same product-meaning convention, unchanged since Night Ledger because it keeps working: two accent colors, each reserved for exactly one thing.
- **Hero accent** — reserved exclusively for the hero recommendation (the one best-value pick). Never used for anything else.
- **Specialty accent** — reserved exclusively for the specialty row (the secondary, exploratory picks). Never used for anything else.

Color alone still signals which of HungryNow's two recommendation types the user is looking at, before they read a word.

### PRIMARY — Pomegranate & Pistachio

Deep pomegranate red (hero) against soft pistachio green (specialty) — a jewel-toned fruit-and-nut pairing that reads upscale-restaurant rather than candy-bright, on a warm blush-gray neutral.

**Light**

| Token | Hex | Usage | Contrast vs. base |
|---|---|---|---|
| TextPrimary (Aubergine) | `#2B1512` | Primary text | 15.41:1 |
| Background (Blush) | `#F7F1EF` | Page background | — |
| Elevated | `#F0E2DE` | Card/sheet surface | 13.65:1 (aubergine on it) |
| TextSecondary (warm brown) | `#6B564F` | Secondary text (reasoning, meta) | 6.12:1 |
| HeroAccentSurface (Pomegranate) | `#A6243D` | Fills, icon tint — large/graphical use | 6.39:1 |
| HeroAccentText (Pomegranate, deep) | `#8A1E33` | Hero accent as text, icon glyph, border | 8.12:1 |
| SpecialtyAccentSurface (Pistachio) | `#8FA876` | Fills, icon tint — large/graphical use only | 2.34:1 (decorative fill; pair with dark text, not standalone) |
| SpecialtyAccentText (Pistachio, deep) | `#4F6A38` | Specialty accent as text, chip border | 5.44:1 |
| Hairline | `#E7D9D4` | Dividers, card borders | 1.23:1 (expected; decorative only) |

**Dark**

| Token | Hex | Usage | Contrast vs. base |
|---|---|---|---|
| TextPrimary (Blush) | `#F5E7E2` | Primary text | 15.00:1 |
| Background (Wine-black) | `#241016` | Page background | — |
| Elevated | `#301A22` | Card/sheet surface | 13.43:1 (blush on it) |
| TextSecondary (dusty rose) | `#C7A9A0` | Secondary text | 8.28:1 |
| HeroAccentSurface/Text (bright Pomegranate) | `#F58396` | Buttons, hero icon, emphasis text at 17pt+ | 7.38:1 |
| SpecialtyAccentSurface/Text (bright Pistachio) | `#B9CC9E` | Chip borders/text at 17pt+ | 10.51:1 |
| Hairline | `#4A2B34` | Dividers, card borders | 1.45:1 (expected; decorative only) |

### BACKUP — Rust & Mustard

Burnt rust red-orange (hero) against mustard gold (specialty) — a grounded spice-market duotone on a neutral warm gray, reading more grown-up and less sweet than the primary.

**Light**

| Token | Hex | Usage | Contrast vs. base |
|---|---|---|---|
| TextPrimary (Charcoal) | `#241C15` | Primary text | 15.00:1 |
| Background (warm gray) | `#F4F2EE` | Page background | — |
| Elevated | `#EAE5DC` | Card/sheet surface | 13.37:1 (charcoal on it) |
| TextSecondary (gray-brown) | `#5C5346` | Secondary text | 6.75:1 |
| HeroAccentSurface (Rust) | `#C1440E` | Fills, icon tint — large/graphical use | 4.58:1 |
| HeroAccentText (Rust, deep) | `#A2380C` | Hero accent as text, icon glyph, border | 6.04:1 |
| SpecialtyAccentSurface (Mustard) | `#D9A404` | Fills, icon tint — large/graphical use only | 2.03:1 (decorative fill; pair with dark text, not standalone) |
| SpecialtyAccentText (Mustard, deep) | `#8A6200` | Specialty accent as text, chip border | 4.91:1 |
| Hairline | `#E1DAD0` | Dividers, card borders | 1.24:1 (expected; decorative only) |

**Dark**

| Token | Hex | Usage | Contrast vs. base |
|---|---|---|---|
| TextPrimary (warm off-white) | `#F3EEE4` | Primary text | 15.21:1 |
| Background (warm charcoal) | `#1E1811` | Page background | — |
| Elevated | `#2A2318` | Card/sheet surface | 13.43:1 (off-white on it) |
| TextSecondary (tan) | `#BDB29E` | Secondary text | 8.40:1 |
| HeroAccentSurface/Text (bright Rust) | `#E8703A` | Buttons, hero icon, emphasis text at 17pt+ | 5.70:1 |
| SpecialtyAccentSurface/Text (bright Mustard) | `#F0C23D` | Chip borders/text at 17pt+ | 10.46:1 |
| Hairline | `#3D3527` | Dividers, card borders | 1.45:1 (expected; decorative only) |

All primary-text pairs clear both WCAG AA (4.5:1) and the HIG's 7:1 aspirational target for custom dark-mode pairs (`apple-hig.md` → Dark Mode) in both palettes. Both palettes' dark-mode hero accents were specifically tuned to clear 7:1 (Pomegranate at 7.38:1, Rust needed less tuning at... actually Rust sits at 5.70:1 — kept at 17pt+/emphasis-only use rather than further brightened, since pushing it past 7:1 started reading orange rather than rust). Both light-mode specialty-accent surface fills (Pistachio 2.34:1, Mustard 2.03:1) are intentionally sub-4.5:1 — icon tints and chip fills meant to sit under dark text or as large graphical elements, never as small text alone, same convention used since Night Ledger's brass-surface color.

### Rejected: a pure-white surface token (`--raised`), 2026-09-07

Tried and removed the same day, recorded because the reasoning is reusable. Screen 02 inverted the usual arrangement — its ground is `Elevated` — so a card on it needs a surface brighter than `Background`, and `Background` vs `Elevated` is only **1.13:1**. Pure white would have given 1.26:1, so on the measurement it was the better card.

**At real size it read as a bright sticker pasted onto the screen.** This palette is deliberately warm; pure white is neutral, and the mismatch is obvious the moment you look at it and invisible in a contrast table. Sadri caught it. **A contrast ratio is not a temperature judgement** — that is the transferable lesson, and it applies to every future surface decision here.

The card uses `Background` with a `Hairline` border instead.

**The systemic finding that came out of it, which does matter:** 3:1 is the threshold for a surface boundary carried by tone alone, and **no light-mode surface pair in either palette reaches it** — `Background`/`Elevated` is 1.13:1, and even white on `Elevated` is only 1.26:1. So in this palette **cards need a border or a separator, not just a tone step.** Design accordingly rather than expecting elevation to read on its own.

### Decorative tint tokens (not part of the reserved accent system)

The mockups have always carried two decorative tints that this page's token list omitted — `--hero-fill: rgba(166,36,61,.10)` and `--spec-fill: rgba(143,168,118,.16)` — used for the blurred soft-background circles. Screen 02's supergraphic (2026-09-07) added four stronger ones, because the existing two are tuned to sit invisibly *behind* content and a mosaic built from them would read as a grey rectangle:

| Token | Value | Used by |
|---|---|---|
| `--sg-hero-1` | `rgba(166,36,61,.14)` | screen 02 supergraphic cells |
| `--sg-hero-2` | `rgba(166,36,61,.28)` | screen 02 supergraphic cells, dot |
| `--sg-spec-1` | `rgba(143,168,118,.22)` | screen 02 supergraphic cells |
| `--sg-spec-2` | `rgba(143,168,118,.42)` | screen 02 supergraphic cells |

**Why this does not break the accent reservation.** The rule above reserves the *saturated* accent — `HeroAccentSurface` / `SpecialtyAccentSurface` — to identify hero vs specialty content. Screen 02 contains no recommendation of either kind, so a tint there cannot be mistaken for one; there is nothing on that screen to confuse it with. The saturated accents remain reserved exactly as specified, and screen 02's motif line art is drawn in `TextPrimary` rather than in either accent, specifically to keep it that way.

All six are **alpha over `Background`**, so they composite correctly in both appearances without separate light/dark values. A palette swap to Rust & Mustard must edit all six alongside the main table.

**Counts to fix while implementing:** the Architecture section says "eight colorset assets"; this page actually names **nine** semantic tokens, and the six decorative tints bring the real total to **fifteen**. Get the number right before building the Asset Catalog — each one is a `.colorset` created by hand.

Implementation note: define all sixteen values (8 tokens × light/dark, × 2 palettes if both get built) as semantic/dynamic `Color` assets in an Asset Catalog. The system Dark Mode setting drives which appearance shows within whichever palette is active; there is no in-app light/dark toggle, per HIG.

## Typography — one family, not three

Unchanged from the Golden Hour revision, since the palette was the only thing in question this round: **SF Pro Rounded is the only typeface**, used for every role — zero-cost system font (no licensing, no bundling, full Dynamic Type support), reads warm and human rather than editorial.

Tabular numerals (price tier, rating, distance) use `.monospacedDigit()` within the same rounded family rather than a separate monospace typeface:

| Role | SwiftUI |
|---|---|
| All text | `Font.system(_:design: .rounded)` |
| Numerals (distance, price tier, rating) | same rounded font + `.monospacedDigit()` view modifier |

Suggested text-style mapping (iOS Dynamic Type scale), kept to 4 sizes / 2 weights as the ceiling:

| Element | Text style | Weight |
|---|---|---|
| "I'm Hungry" screen headline | Large Title | Semibold |
| Hero restaurant name | Title 2 | Semibold |
| Specialty restaurant name (row) | Headline | Semibold |
| "Why this pick" reasoning | Body | Regular |
| Button label | Headline | Semibold |
| Section label ("Also nearby") | Caption 1 | Medium, `.textCase(.uppercase)`, tracked |
| Distance / price / rating | Footnote | Regular, `.monospacedDigit()` |

No Ultralight/Thin weights anywhere — Regular/Medium/Semibold only.

## Iconography

SF Symbols only, rounded rendering where available, monochrome or hierarchical — no custom icon set, no filled-emoji stand-ins. `mappin.and.ellipse` for distance, `star.fill` (hero-accent-tinted, hero only) / `star` (outline, elsewhere) for rating. Filled/tinted symbols stay reserved for the hero card specifically — everywhere else stays outline, so the hero pick is visually louder without adding a third accent color.

## Motion

Per `apple-hig.md` → Motion: purposeful only, brief, skippable, never the sole channel for important information. Unchanged from the Golden Hour revision:

- **Tap → loading:** the search/location icon does a gentle SF Symbols bounce (built-in "bounce" animation) while a soft hero-accent glow pulses behind it.
- **Loading → hero reveal:** a brief (≈0.2–0.3s) scale-and-fade "pop" (98% → 100% opacity+scale).

Both must degrade to a plain crossfade with no bounce/pop/glow when Reduce Motion is on.

## App icon (concept, not built)

Not yet built in Icon Composer — flagged in Gaps below. Concept carried over and re-colored: a single flat geometric mark (still under consideration — either the "sun/burst" concept from Golden Hour, re-colored in hero-accent-on-background, or a simplified pomegranate/seed motif if the primary palette sticks) — crisp edges, centered content, one clear concept, consistent across light/dark/tinted/clear variants, per HIG App Icons rules.

## What this deliberately avoids

- No gradients, no glassmorphism/glow-as-decoration, no soft drop shadows on cards.

  **Two sanctioned exceptions, both transient motion cues on the loading screen, neither persistent decoration:**
  1. The hero-accent pulse-glow behind the loading icon (from the original spec).
  2. **The searching radar's sweep arm** (added 2026-09-07 at Sadri's request): a 90° conic gradient from pomegranate `#A6243D` at ~34% alpha down to fully transparent, brightest at the leading edge and fading behind it. A flat translucent sector was built first specifically to honour this rule, and it didn't read as a radar — the trailing fade *is* the thing that says "scanning." See [[app-mockups]] → 05 Searching.

  The line the rule is actually drawing: a gradient that exists only while something is in motion, and disappears when it finishes, is a motion cue. A gradient sitting on a card, a button or a background is the "AI-generated look" this page exists to avoid. Exceptions get added here, not decided ad hoc in a screen file.
- No purple-as-primary-brand-color, no default Material/Cupertino blue as an accent.
- **No blue, teal, or navy anywhere in the accent system** — confirmed off the table after three separate rounds where every blue-inclusive option was eliminated.
- No literal red/orange/green food-app palette, no muted warm-cream-and-earth-brown "generic AI tool" palette (this is specifically what Golden Hour got cut for).
- No fully rounded "pill everything" — corners stay modest and consistent.

  **Sharpened 2026-09-08, after this rule was broken.** Screen 06's fact row was built as three `border-radius:100px` outlined chips, and screen 08's radius note as a fourth — while this line was already on the page. Sadri caught it on sight: *"I still don't like chip mode. Is chip like AI always using it when create UI/UX, I'm already bored see the chip style."* The mockup review that ran the day before also missed it, so the rule as worded was not doing its job.

  **The operative test: a fact is text, not an object.** Distance, price, rating, a search radius — these are values to read, and wrapping each one in an outlined capsule turns four words into four drawn objects competing with the content. If a thing is not tappable and not a discrete entity, it does not get a container. State it as a value with a caption, or as separated text.

  Where a pill is still correct, so this doesn't get over-applied:
  - **Buttons.** A capsule button is a real iOS convention, not a default.
  - **The app bar's location chip.** It floats with nothing around it to anchor against, so it needs an edge to sit in — and it is genuine status, one discrete thing.

  Why it matters beyond taste: pills on the fact row and pills in the specialty list made **the hero card and the specialty rows read as the same kind of object**, since both were outlined shapes on hairlines. Removing them leaves the hero card as the only filled surface on screen 06, which is `elevation-as-selection` ([[reference-adoption]] item 5) doing the hero/specialty work instead of colour carrying it alone.

  Note also what the failure was *not*: `metric-chip-row` ([[reference-adoption]] item 1) is still adopted. Reference 008's discipline is one treatment reused in the same position — a rule about **consistency, not about rounded rectangles**. Conflating "component" with "chip" is what produced the pills; the component survived the rendering change untouched. Options compared in `output/mockups/variants-fact-row.html`; Sadri chose value-over-label for facts and glyph + text for the specialty category.
- No stock-photo-style food imagery with a heavy filter.
- No generic circular spinner for loading.
- No more than one typeface family, no italics or condensed variants used decoratively.
- No custom light/dark toggle — the system setting is the only control. No in-app palette switcher either (see Architecture) — palette choice is a build-time decision, not a runtime feature.

## Open gaps

**See also [[reference-adoption]]** (2026-09-07) — eight external UI references filtered against this spec. It changes nothing here: every conflict was resolved in this page's favour and recorded there. It does supply the wording fix for the colour-alone problem below, and it adds a pre-ship defect checklist.

**Three of these were closed on 2026-09-07 in [[portfolio-art-direction]]** — that page decides them and gives the reasoning; this page keeps the summary so the spec stays readable on its own.

- ~~App icon artwork motif undecided~~ → **decided: location pin + one concentric arc, hero-accent on blush**, layered in Icon Composer. Chosen over the sunburst (says nothing) and the pomegranate (references the palette name, reads as a fruit/grocery app). Gives icon-to-app continuity with screen 05's radar. Artwork still not built. Must be tested at 29pt.
- ~~Real food photography treatment undecided~~ → **decided: no grade, no filter, no vignette.** Places photos come from strangers and no single treatment survives a lit facade, a dark interior and a white-tablecloth shot alike; a half-working grade looks like a bug. 16:10 `cover` crop in a fixed box, full-bleed at the card top, never any text over it, 1px `Hairline` inner border, sRGB profile embedded, @2x/@3x. New backend ask that came out of it: prefer the largest/closest-to-16:10 photo rather than the first.
- ~~No default appearance for portfolio capture~~ → **decided: Pomegranate & Pistachio; demo video in Dark** (the radar sweep and the reveal glow only read on wine-black, not on blush), **stills in Light** led by screen 06, plus exactly one dark still as proof the semantic-token work was done. Fallback if one appearance is preferred throughout: shoot everything Dark.
- **Wording risk flagged, not yet fixed:** the Color-system section above says "colour *alone* signals which recommendation type" — `apple-hig.md` → Color prohibits colour as the only signal. The implementation is fine (fill-vs-outline symbols, size and placement all differentiate), so this is a rewording job, but it's a claim a reviewer reading this vault as a work sample would catch.
- Neither palette has been turned into an Xcode Asset Catalog `.colorset` yet — first concrete step of "Visual polish pass," and the moment the token-swap architecture above actually gets built (not just specified).
- Decide whether to build out both palettes' Asset Catalog entries now (so swapping really is copy-paste) or only Pomegranate & Pistachio initially with Rust & Mustard's values kept here as a documented fallback to type in later — affects how literally "swappable at any time" this ends up being in practice.
