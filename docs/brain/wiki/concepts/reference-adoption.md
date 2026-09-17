# Reference adoption — what the eight visual references change about HungryNow

**Status:** synthesis complete 2026-09-07. Eight UI references were collected, catalogued and ranked, then turned into the decisions below. The reference catalogue and the synthesis method behind it are not part of this vault; what survives here are the decisions they produced, which is what this app is built on.

This page is the **filter**, not a new spec. [[visual-identity]] stays locked; [[portfolio-art-direction]] stays as written. Everything below is run against those two, and where a reference conflicts with a locked decision, **the locked decision wins and the conflict is recorded rather than reopened**. HIG check per root `CLAUDE.md` was run this session across `apple-hig.md` → Foundations (Layout, Materials, Color, Typography, Accessibility, App icons, Branding, Dark Mode, Motion, Writing).

---

## The strategic finding, before any individual technique

**Not one of the eight references shows a loading, empty, or error state. 8/8, no exceptions.** Six of eight also ship unlabelled icon-only controls, and seven of eight use decorative rather than real number formatting.

HungryNow already has screens 05 (searching, with the radar sweep), 07, 08 and 09 (permission denied, no results, network failure) **built**. So the app's most distinctive assets are precisely the things the entire reference genre omits — because a static shot has no reason to draw them and no way to show them off.

That reframes the portfolio thesis in [[portfolio-art-direction]] from a judgement into an observation with evidence behind it: *looking shipped is the differentiator, and it is cheap for this project because the work is already done.* Concrete consequence — one edge-case screen belongs in the portfolio set, and the searching animation belongs in the demo video, not the stills.

Second finding, from the "most systematic" ranking in the catalog: **the prettiest references and the most reusable ones are almost inversely correlated.** Reference 008 (Anastasia Golovko's hiking app) is the least showy and by far the most useful, because it's the only one carrying an actual component system. It is the model to follow; 002, 004 and 007 are individual compositions with nothing that generalises.

---

## Adopt

### 1. Systematise the metric chip row — `metric-chip-row` (008, 004)
**Highest-value adoption in the set.** Reference 008 uses one chip component — duration · distance · group size — in identical treatment and identical position on all three screens. Not decoration re-invented per screen: a component.

Screen 06 already has a meta row (distance, price tier, rating). Make it the same thing: **one component, fixed field order, reused wherever facts appear**, including the specialty row and any future screen. Field order should put the two facts people actually decide on first — [[app-mockups]] already found that a long model-generated `reason` pushed distance and price off the first screen, which is the same lesson arriving from the other direction.

Compatible with [[visual-identity]] as-is: chips are flat fills with a hairline, no gradient, no shadow.

### 2. `inline-read-more` for the reason text (004)
The `reason` field is model-generated with no length cap, and [[app-mockups]] recorded the overflow problem. Reference 004 truncates body copy with an inline "Read more". **This is the only thing in eight references that solves a problem HungryNow already documented.** Adopt: clamp `reason` to a fixed line count with an inline expand affordance.

### 3. Fix the specialty chips using `origin-tag` (008)
[[app-mockups]] flagged that the specialty chips are unactionable because they name a `foodCategory` — a cuisine — rather than the restaurant serving it. Reference 008 shows the correct shape: **the named thing is primary, and the category is a small consistent tag attached to it.** Invert the current chips: restaurant name primary, `foodCategory` as the tag. That also makes the existing `foodCategory` icon plan meaningful instead of decorative.

### 4. `value-hierarchy` as an explicit principle (008)
008 builds depth from lightness inside a single hue — two ground tones plus a dark emphasis — rather than adding accents. [[visual-identity]] already has `Background`, `Elevated` and `Hairline` tokens that do exactly this. Adopt as a stated rule: **depth comes from the existing surface tokens, never from a new accent colour.** This protects the hero/specialty accent reservation, which is the whole point of the colour system.

### 5. `elevation-as-selection` (002) — and it fixes a real flaw
002's discipline is that selection is expressed by size and elevation, *keeping colour free to carry meaning*. That is the answer to the wording problem already flagged in [[visual-identity]]'s open gaps: the spec claims "colour alone signals which recommendation type", which `apple-hig.md` → Color prohibits. Adopt the framing — **hero vs specialty is signalled by size, position and symbol fill weight, with colour reinforcing** — and reword accordingly. No visual change needed; the implementation already does this.

### 6. `clipped-scroll-hint` (5/8 — 003, 005, 006, 008)
The most-corroborated honest technique in the set. The specialty row should **clip the last chip at the screen edge** rather than fitting neatly. It signals scrollability truthfully and costs nothing. Note the distinction reference 006 got wrong: clip a *card*, never a *word* — a half-visible card reads as "more this way", a half-visible word reads as broken.

### 7. Shape treatment for screen 02 — `text-driven-shape` + `asymmetric-corner-radius` (006)
Compatible with every locked ban: flat colour fills, no gradient, no blur, no shadow. And per the cheapest-to-build ranking, 006 is the only reference with **zero asset production cost**. Build any shape as the `.background()` of its text container so Dynamic Type and Indonesian strings grow the panel instead of overflowing it.

### 8. Adopt 008's ambient-data *test*, not its weather widget
008's weather block earns its place because for a hiking app weather changes the decision. The reusable test: **does this ambient datum change what the user does?** Applied here: weather doesn't; **"open now" does** — a closed restaurant makes the entire recommendation worthless. Places returns opening hours. This was a candidate backend passthrough alongside the `latitude`/`longitude`/`placeId`/`rating` gap already in [[api-contract]], and arguably a more important one, since a wrong-but-open pick beats a perfect-but-closed one. **Adopted and implemented 2026-09-17:** Places API now requests `currentOpeningHours`, `regularOpeningHours`, and `utcOffsetMinutes`; the Cloud Function dynamically evaluates schedules at request time against the restaurant local timezone, filters closed restaurants before Gemini, and prompts Gemini to prioritize open places.

---

---

## Reference 009 — a travel-app detail screen (added 2026-09-08)

Sadri found a ninth reference (an #inktoberui travel app, deep-green, two screens) and asked whether it fits. Recorded here rather than reopening the catalog, because it changed exactly one thing.

**It corroborates two adopt items rather than adding any.** Its Distance / Temp / Elevation block is value-over-label — the rendering Sadri had independently chosen hours earlier for the fact row (item 1). Its Description ends in "Read More" — item 2, built the same day. Two of the three highest-value adoptions now have a ninth independent vote.

**It is also 9-for-9 on the strategic finding.** No loading, empty or error state anywhere in it, and its search icon, tab bar and circular primary action are all unlabelled icon-only controls. Both tallies hold.

**Adopted: the asymmetric corner on screen 06's media.** Its hero image carries one large radius and three tight ones — `asymmetric-corner-radius` (item 7), which screen 02's purpose card already uses. Compatible with every ban: no gradient, no shadow, no overlay, zero asset cost. Applied to screen 06's media viewport, bottom-right, 28px.

**The rule that came out of applying it twice: the constant is the corner, not the number.** Large radius always bottom-right; the value scales with the surface (34px on screen 02's ~108px card, 28px on screen 06's 120px media). A shared radius token would force one number onto two differently sized shapes, which is what makes an asymmetric corner look arbitrary rather than drawn.

**Rejected: the side thumbnail rail**, which was the part Sadri was most interested in. Four reasons, in order of weight:

1. **It occludes the photo** — the thumbnails sit *on* the image and cover roughly 19% of it, including the right edge. A 20px peeking sliver had already been rejected on screen 06 for taking space from the one element that tells you what the place looks like; this takes four times that.
2. **It only works because of the photography.** The reference's photo is a wide landscape with clean pale sky exactly where the thumbnails land. Real Places photos here are a dark storefront at dusk, a plate of noodles, a car park — and the white borders and drop shadows that would make thumbnails readable over that are both banned by [[visual-identity]].
3. **It duplicates the page control's job with a second mechanism**, and leaves the behaviour undefined: tap to swap or scroll? What happens at ten photos, or one? The reference has exactly four and never has to answer. This is [[pinterest-refs-vs-hig]]'s rule exactly — steal the visual layer, never the interaction layer.
4. Its footer's circular arrow is unlabelled and icon-only, which is the defect 7 of 9 references now ship; screen 06's labelled "Directions" pill already solved it.

**The compatible version, offered and not taken (yet):** a thumbnail row *below* the photo replacing the dots — previews without occlusion, works at any photo count, ~26px of card height. Left as an option, not an open item, since dots are the convention (Airbnb, Booking, Apple all use them) and each thumbnail is another `get_photo` fetch unless the full-size image is reused scaled down.

---

## Reject — incompatible with locked decisions

| Technique | Refs | Why rejected |
|---|---|---|
| `frosted-material` / glassmorphism | 002, 004, 008 | Banned by [[visual-identity]]. And the blur finding kills the workaround anyway: blur removes *detail* but preserves *average luminance*, so it would not make text legible over a bright Places photo. Blur solves busy-ness; dimming solves contrast. |
| `gradient-led` CTAs | 004 | Banned. Gradients survive only as the two sanctioned transient motion cues. |
| `neumorphic-controls` | 007 | Banned, and an accessibility failure independent of taste — embossed edges can fall below the 3:1 non-text contrast threshold, so the control boundary itself is hard to perceive. |
| `serif-display-type` | 007 | Genuinely appealing, and banned: SF Pro Rounded is locked as the only family. |
| `ai-painterly` imagery | 007 | Directly contrary to [[visual-identity]]'s stated reason for existing. |
| `monochromatic` | 007 | Would collapse the hero/specialty accent distinction, which is the colour system's only job. |
| `route-over-photo` | 004 | Decorative encoding — a drawn curve is not road geometry. HungryNow hands off to a nav app instead, which is the honest version. |
| `radial-layout` | 002 | Decorative encoding, no VoiceOver reading order, doesn't scale. **Note the difference:** screen 05's radar is a *loading animation*, not an information display, so it does not share this defect. Don't let the visual similarity cause a later misreading. |
| `floating-pill-cta` tab bar | 4/8 | HungryNow deliberately has no tab bar and no settings screen. |
| `full-width-cta` | 4/8 | Not rejected, but note `apple-hig.md` → Layout prefers non-full-width buttons so they harmonise with the corner radius; reference 005's small left-aligned pill is the more HIG-correct pattern. Screen 04 already uses a 198px pill. Screen 06's footer was designed deliberately and recently — flagging only, no change proposed. |

---

## Decision made — screen 02 goes supergraphic (2026-09-07)

**Resolved: replace the floating illustration with a `supergraphic-mosaic`.** Sadri's reason is the strongest argument available and better than the aesthetic one I'd framed it with: *"so the welcome page and the find page not identical."* 02 and 04 were both art-floating-on-blurred-circles, so they read as one screen; swapping pictures wouldn't have fixed that, only a structural change would. Built and documented in [[app-mockups]] → 02. The structural risk flagged below was handled in the build: the band is content-cleared with 43px slack (more than the old layout had), and the status-bar collision is solved by restricting row 1 to pale fills.

*Original framing of the choice, kept for the record:*

This is the one place the references genuinely offer an alternative to something already built, and Sadri explicitly liked it: *"really like this, especially the supergraphic on the welcome screen."*

- **Keep the current floating transparent-PNG illustration.** Already built, already regenerated once to match (rounded shapes, no text, no gold), and screen 02's `.welcome-bg` is tuned to it.
- **Replace with a mosaic** (005's model): a modular grid of flat-vector food motifs plus geometric blocks, bleeding off the top and right edges. Distinctive, cheap to recolour, fully compatible with the palette tokens, and it would make screen 02 the strongest single still in the portfolio set.

The real cost of the mosaic isn't visual, it's structural: **a supergraphic is a fixed-composition asset in a variable-height container.** It needs a defined crop/anchor rule and a minimum height or it breaks under Dynamic Type, on an SE, and in landscape. Reference 005 shows none of that, because a concept shot never has to.

Not deciding this here — it discards existing work and it's a taste call.

---

## Pre-ship defect checklist, derived from the reference tallies

The genre's failures, turned into checks. Each line is a thing 6-8 of the eight references got wrong.

- [ ] **Number formatting rule written down and applied** (7/8 got this wrong). One unit system, locale-aware, no zero-padding, no trailing periods, no mixed styles. Specifically for this app: distance units, rating precision, and price tier must be consistent — and Indonesian locale uses a different decimal separator, so this must go through a formatter, never string interpolation. This is the most concrete deliverable on the page.
- [ ] **Every glyph either carries a visible label or a VoiceOver accessibility label** (6/8 got this wrong). Sweep every screen.
- [ ] **Longest-real-string pass** (7/8 got this wrong). Real Places names, a long `reason`, and the Indonesian translation — checked against truncation on every screen.
- [ ] **One clear primary action per screen** (2/8 got this wrong). Screen 06 already resolved this: Directions filled, "Find something else" ghost.
- [ ] **Contrast verified against the surface the text actually sits on**, in both appearances, at the smallest type size used.
- [ ] **Decorative shapes marked accessibility-hidden.**
- [ ] **Dynamic Type at the largest accessibility size** on every screen with a hero region.
- [ ] **Keep the error state in the portfolio set** — the single strongest credibility signal available, and free.

---

## Cross-references

- [[visual-identity]] — locked spec; this page never overrides it
- [[portfolio-art-direction]] — photography treatment, capture appearance, app icon
- [[app-mockups]] — the built screens these decisions land on
- [[api-contract]] — where the "open now" passthrough candidate belongs

## Open items

- "Open now" passthrough is a *candidate*, not a decision — it needs a look at Places field tiers and the cost cap in [[google-places-api]] before it goes on the checklist as work.
- Screen 02 mosaic-vs-illustration is unresolved (above).
- Zero references in the set are `shipped` app screenshots, so **nothing here corroborates an interaction pattern** — only visual direction. Recorded in the main vault's `gaps.md`.
