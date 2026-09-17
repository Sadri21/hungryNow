# Log — chronological record

Append entries here as decisions are made or work is completed. Newest at the bottom. Older sessions are rotated to `wiki/log-archive.md` once this file grows past ~1-2 sessions or ~20 lines — read only the tail of this file each session (see root `CLAUDE.md`).

## Archive
- **2026-09-02 → 2026-09-17:** product/backend foundations, mockup and native-screen builds, visual identity and app-icon work, loading/recovery artwork, Screen 06/06A iterations, screen-transition motion, and Screen 05 visual corrections. Full detail: [[log-archive]].

## 2026-09-17 — Result reason permanently visible

- Removed the Screen 06 “Why this place” disclosure from the HTML mockup. The recommendation reason is now one concise, permanently visible paragraph under a noninteractive heading, because it is essential decision evidence rather than advanced information. The two overlapping reason sentences were merged; Restaurant details remains the next action.
- Corrected the Screen 06 eyebrow from “YOUR PICK” to “PICKED FOR YOU,” making it clear that HungryNow selected the recommendation for the user rather than implying the user had already chosen it.
- Ported to native SwiftUI in `ResultView.swift` and `ResultSheet.swift`: removed the collapsible disclosure button (`isWhyExpanded`), added the noninteractive "Why this place" heading (`AppFont.tag`, `Color.heroText`, `.isHeader` trait), and made the recommendation reason permanently visible with markdown bold support. Updated preview fixture to match.

## 2026-09-17 — Recommendation filtering by opening hours (Open Now)

- Added opening hours support to the Firebase Cloud Function backend (`firebase/functions/main.py`). `PLACES_FIELD_MASK` now requests `places.currentOpeningHours`, `places.regularOpeningHours`, and `places.utcOffsetMinutes`.
- Implemented `_is_place_open(candidate)` which computes the restaurant's local time using `utcOffsetMinutes` and evaluates `regularOpeningHours.periods` across normal schedules, 24/7 businesses, and overnight schedules wrapping Sunday midnight.
- Solved the 48-hour location cache staleness issue: candidate records cache periods and timezone offsets so open status is evaluated dynamically at query time; legacy cache entries lacking hours trigger an automatic refresh.
- `get_recommendation` filters candidates before Gemini: when >= 4 verified open candidates exist, all confirmed closed/unknown places are excluded; authentic local warungs with unrecorded hours are preserved if open options are limited; and graceful fallback applies during off-hours.
- Gemini prompt updated with an explicit requirement to only recommend places currently open (`isOpenNow is True or 'unknown'`).

## 2026-09-17 — Checklist audit against the actual codebase

Sadri called the application done; audited the vault checklist against `hungrynow/` and `firebase/functions/main.py` rather than trusting the checked boxes.

- **Backend passthrough closed.** The item recorded as "the single biggest blocker" is in fact shipped: `_enrich_hero` / `_enrich_specialty` fill `latitude`, `longitude`, `placeId`, `rating`, `ratingCount`, `priceLevel`, `photoRefs` and `openNow` from the matched candidate. Checked off. The checklist had been carrying it as open since 2026-09-09.
- **Attribution is the real remainder.** `grep -ci attribution main.py` returns 0 — the field is not requested, not returned, not enriched. Split it out of the passthrough line as its own item and tied it to the existing compliance blocker, since they are one piece of work.
- **`git init` is still not done** and is now the biggest unmanaged risk: 49 Swift files, all nine screens, and the backend exist with no version history at all. Screen 06 alone was rewritten 8 times with only comments as a record. Needs an interactive terminal.
- **`LSApplicationQueriesSchemes` has no plist entry** anywhere in the project (grep across `*.plist` / `*.pbxproj` returns nothing). Directions will fail silently.
- Added a "Next up" block at the top of `checklist.md` ordering the remaining work: attribution → slide-2 placeholder → `git init` → URL schemes → device verification → polish/demo. Explicitly deprioritised the screen-05 CSS ring and contrast fixes: they are mockup-side and cosmetic while four ship-blockers are open.
- Closed the "(Candidate) investigate an open-now passthrough" item — it was superseded by the full opening-hours filtering shipped earlier today.

## 2026-09-17 — Photo attribution, backend half

Constraint from Sadri: abort if the work would spend API cost. It did not — no deploy, no API call, no quota touched. Source edits and offline tests only.

- **No field-mask change was needed.** `places.photos` already returns each photo's `authorAttributions` in the same payload; the code was requesting the data and discarding it, keeping only `p["name"]`. So attribution costs nothing extra — this was a parsing gap, not a missing purchase.
- `_photo_attributions(place)` maps each photoRef to its first author `displayName`. Photos with no ref or no author are skipped.
- Candidates now carry `photoAttributions` (a ref→name dict) and it travels through the 48h location cache with the refs.
- `_enrich_hero` emits `photoAttributions` as a **list index-aligned with `photoRefs`**, `None` where a photo has no author — so a three-slide carousel can credit each slide separately, which is what Google requires.
- `_get_cached_photo_uri` → `_get_cached_photo`, now returning `(photoUri, attribution)`; the photo cache document stores `attribution`. `get_photo` returns `{"photoUri", "attribution"}`.
- **`get_photo` takes the attribution from the client, not from Places.** The client already has it from the recommendation response. Re-querying Places for a credit line would mean a Place Details call on every photo tap — real money for a string we were already handed. Pre-attribution cache entries get backfilled from that parameter instead of refetching the image.
- **Deliberately did NOT add a `photoAttributions` staleness guard** to `_get_cached_candidates`, unlike the coordinates and opening-hours guards. That guard forces a refresh, which costs one Places call per cached location. At a 48h TTL the entries age out for free; until then the hero carries no credit and the client renders the photo without one. Documented as a comment at the guard so the omission doesn't read as an oversight.
- Verified offline: index alignment holds, missing author yields `None`, ref-less photo dropped, no-photo place yields `None` rather than `{}`. `py_compile` clean.

**Still open — the compliance blocker is NOT closed.** The Swift client does not yet decode `photoAttributions` (`RecommendationModels.swift` has only a flat `attribution` on `PhotoResponse`), and its `get_photo` call does not pass `attribution` back. Backend serves it; nothing displays it yet.

## 2026-09-17 — Photo attribution, client half

Completes the compliance blocker in code. No build, no run, no API call — parse checks and an offline decode round-trip only.

- `HeroPick.photoAttributions: [String?]?` decodes the backend's index-aligned list, with `attribution(at:)` as a bounds-safe accessor. It tolerates a short or absent array deliberately: a mismatch would crash on a raw subscript, and a missing credit is a compliance problem while a crash is a broken app.
- `getPhoto` gained an `attribution` parameter across `RecommendationAPI`, `RecommendationServiceProtocol` and `RecommendationService`. Only one type conforms to the protocol, so no mocks broke.
- `loadHeroPhoto(at:of:)` reads the credit from the hero **before** the request and uses `knownAttribution ?? response.attribution`. The hero is the primary source; `get_photo` only echoes what it was sent or had cached, because the backend must never re-query Places for a credit line.
- **Latent bug fixed in passing:** `PlaceDetailItem.photoAttribution` was a single `String?` set from `photos.first?.attribution`, which would credit every carousel photo to slide 1's author — exactly what the attribution requirement exists to prevent. Now `photoAttributions: [String?]` with a bounds-safe `photoAttribution(at:)`. Nothing rendered it yet, so this never shipped; `ResultView` was already doing per-slide correctly via `photos[slide]?.attribution`.
- Verified offline with a standalone Swift decode harness across four response shapes: full list with an embedded null, field absent (a stale 48h cache entry), explicit null, and an array shorter than `photoRefs`. All four behave; none crash.

**Still unverified:** no build was run this session (Sadri owns the emulator loop). Confirm a real credit line renders under the screen-06 hero photo before treating the compliance blocker as closed.

## 2026-09-17 — Attribution: the cache guard I skipped was the bug

Sadri found it by opening Firestore: cached candidates in `location_cache` had `photoRefs` but no `photoAttributions` key at all. Pre-change entries, written before attribution capture existed.

**This was a self-inflicted bug, and the reasoning that caused it is worth keeping.** Earlier today I deliberately did NOT add a `photoAttributions` staleness guard to `_get_cached_candidates`, to avoid spending one Places call per cached location, and documented the omission as a considered cost decision. The consequence I waved away as "the hero simply carries no attribution" for 48h is exactly the compliance failure the work exists to fix — an uncredited Places photo is a terms violation, not a cosmetic gap. Traded a real violation for a small, one-off cost. Wrong trade.

Now guarded: entries that have `photoRefs` but no `photoAttributions` are treated as a cache miss and refreshed. Scoped with `any(c.get("photoRefs"))` so locations with no photos to credit never pay for a refresh. Costs one Places call per already-cached location, once.

**Debugging note, for next time.** I spent several rounds on wrong theories — a "stale build" (my `strings` check on the app bundle was invalid: it returns 0 hits for `photoUri` and `photoRefs` too, code that demonstrably works), then a staging/wrong-project theory Sadri correctly killed by pointing out that names, ratings and photos all arrive fine from the same response. What misled me: every curl test hit `-6.1862,106.8341`, whose cache entry happened to be post-change and therefore had attributions. The app was on a different cache key with an old entry. **Same code, different cached data — verify against the data the app actually hits, not a location that happens to work.** Reading Firestore directly, as Sadri did, beat all of my inference.

Also fixed while here: the credit rendered as a bare name. Most Places credits are the restaurant's own name (it uploaded the photo), so "Kampung Kecil Abdul Muis" under the reason text reads as a stray string. Now "Photo by <name>", with a matching accessibility label.

**Open:** placement. The credit sits at the bottom of the "Why this place" block, not on or under the photo it credits. Works, but it is the wrong place for it — and `Color.text2` fineprint is the same low-contrast pattern already flagged three times for `.photo-credit`. Needs a decision before shipping.

## 2026-09-17 — Attribution verified on device

Sadri confirmed the credit line renders after redeploying the cache guard and rebuilding. The compliance blocker is closed end to end: Places -> backend capture -> cache -> `get_recommendation` -> client decode -> screen 06 display.

Two follow-ups moved onto the checklist rather than being treated as done:
- The credit's **placement** is still wrong — bottom of the "Why this place" block, not on the photo. Compliant but reads as part of the reason copy.
- Its **contrast** is `Color.text2` fineprint, which is the fourth instance of the low-contrast bug class already flagged three times for `.photo-credit` in the mockups. The native view now has it too.

## 2026-09-17 — Vault moved into the repo; preparing for a public portfolio release

Sadri is publishing the repo publicly as a portfolio/sale piece, and wants the "brain" to ship with it so a buyer's AI agent can work in the codebase immediately. That only works if the vault travels with the code — the repo's `CLAUDE.md` previously pointed at an absolute path on Sadri's Mac, so a clone would have sent an agent to a folder it doesn't have.

- Vault now lives at `docs/brain/` **inside the repo**. Repo `CLAUDE.md` and `AGENTS.md` rewritten to relative paths; the vault's own `CLAUDE.md` no longer claims to be outside the repo.
- The pre-move copy outside the repo is **deprecated** and must not be edited. Both repo instruction files state that `docs/brain/` wins if the two ever coexist. This was the real risk of the move: two vaults, session updates silently landing in the dead one.
- **What was deliberately NOT shipped, and why.** Some general design-research and technique pages that informed this project are kept separate and are not part of this vault: they are reusable method across projects rather than HungryNow deliverables. The *decisions* they produced are recorded here in full, which is what a buyer needs to extend the app coherently. Seven dangling references to them were rewritten to keep the conclusions and drop the pointers; `wiki/index.md` now states the omission is deliberate so it doesn't read as missing files.
- Secrets audit before publishing: `Config/Secrets.xcconfig` holds a live restricted Places key and is correctly gitignored, with a `.example` template beside it. No hardcoded keys in Swift or Python. `Info.plist` uses `$(PLACES_API_KEY)`. Gemini and the server Places key live in Firebase Secrets — that architecture is what makes the repo publishable at all. Added ignores for `firebase/functions/venv` (160 MB, previously untracked-but-unignored), `__pycache__`, `.env*`, and `*firebase-adminsdk*.json`.
- Staged dry-run: 523 files, 41 MB, secrets and venv excluded. No `git init` yet — Sadri's call.

**Note on `raw/`:** checked before shipping and kept. `mockup-review-2026-09-07.md` is four unresolved design judgment calls written as arguments rather than conclusions, including one that argues against its own diagnosis. It shows process quality rather than undermining it.

## 2026-09-17 — Old vault deleted; `docs/brain/` is now the only copy

Deleted the out-of-repo copy after verifying this one held all 144 files. The brief two-vault arrangement (repo copy + a one-way sync script) lasted about ten minutes and was the wrong answer: the sync immediately overwrote `log-archive.md` in the private vault and destroyed three research references, which had to be restored by hand. Two writable copies of the same notes is a data-loss bug waiting to happen, so the fix was one copy, not better syncing. Sync script deleted.

- Seven pages differed between the copies — this one has the private-vault research references stripped for public release. Those originals are archived outside this repo.
- Root vault's `CLAUDE.md`/`AGENTS.md` updated: they were live instructions pointing at the now-deleted folder.
- **From here: all HungryNow session updates go to `docs/brain/checklist.md` and `docs/brain/wiki/log.md`.** Nothing to sync, nothing to keep in step.

## 2026-09-17 — Closed a stale ship-blocker: the foodpanda placeholder

"Replace screen 06 slide 2 — placeholder foodpanda image, visible watermark, can't ship" has been carried as a blocker since before the Sept 10 mockup redesign. Checked it against the files rather than trusting the line: `foodpanda` appears only in `output/mockups/archive-before-2026-09-10/screen-06-result.html`, never in the current mockups and never in the app, whose carousel has always fetched real Places photos through `get_photo`. The redesign removed the problem and the checklist item outlived it.

Closed as resolved-by-redesign, not fixed. Worth noting the failure mode: an item phrased as a blocker stayed on the live agenda for a week after it stopped being true, and I repeated it as a blocker several times today before checking. Items that describe a *file* should be verified against that file before being restated.
