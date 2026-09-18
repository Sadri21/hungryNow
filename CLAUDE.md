# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

Functionally complete and running end to end: ~49 Swift files, all nine screens built natively, and a deployed Python backend. Location → Cloud Function → Places + one Gemini call → hero pick plus 2-3 specialty picks, with photo attribution, opening-hours filtering, and quota caps all live.

The architecture below is **built, not planned**. What remains is verification and polish rather than construction — see `docs/brain/checklist.md` for the live agenda.

**Verify before you trust a task description.** Five checklist items were found stale in a single session on 2026-09-17: each was written when true, then restated without re-reading the file it described. If an item claims a defect in a specific file, open that file first.

## Knowledge base — read this before doing anything else

All product, architecture, and decision context for this project lives in the repo, in an Obsidian-style vault at:

```
docs/brain/
```

Paths below are relative to that directory (so `checklist.md` means `docs/brain/checklist.md`). Open it as a vault in Obsidian if you want the `[[wikilinks]]` to resolve; it reads fine as plain Markdown either way.

This exists so context survives across sessions. **Every fresh session, in this order (token budget matters — don't read the whole vault):**
1. `checklist.md` — source of truth for what's done and what's next.
2. Last 5-10 lines of `wiki/log.md` — recent decisions/gotchas.
3. `wiki/index.md` — catalog of pages (don't open them yet).
4. Only then open the one relevant `wiki/concepts/`, `wiki/entities/`, or `wiki/synthesis/` page for the task at hand.

At the end of a session: check off completed items in `docs/brain/checklist.md` and append what happened to `docs/brain/wiki/log.md`.

**`docs/brain/` is the single source of truth.** The vault used to live outside the repo; that copy is gone. Never write session updates anywhere but `docs/brain/`.

## Commands

- Build: `xcodebuild -project hungrynow.xcodeproj -scheme hungrynow -destination 'platform=iOS Simulator,name=iPhone 17' build`
- Run all tests: `xcodebuild -project hungrynow.xcodeproj -scheme hungrynow -destination 'platform=iOS Simulator,name=iPhone 17' test`
- Run a single test: add `-only-testing:hungrynowTests/hungrynowTests/testExample` (swap in the actual class/method name)
- List available simulators: `xcrun simctl list devices available`
- Open in Xcode: `open hungrynow.xcodeproj`

Scheme name is `hungrynow`. Bundle ID is `com.revaiter.hungrynow` (brand: **Revaiter**). iOS deployment target: 16.0. Swift version: 5.0.

## Architecture (built — see `docs/brain/wiki/concepts/architecture.md` for the canonical version)

```
hungrynow/
├── App/                   → hungrynowApp, RootView (route enum: welcome/recommendation/locationDenied)
├── Features/
│   ├── Welcome/           → WelcomeView + ViewModel (permission request)
│   └── Recommendation/
│       ├── Views/         → Home, Searching, Result, PlaceDetails,
│       │                    LocationOff, NoResults, NetworkError, ErrorState
│       │   └── Components/→ ResultSheet, ResultMediaHeader, ResultFactsCard,
│       │                    ResultFooter, ResultSpecialtiesSection, ReasonText
│       └── ViewModel/     → RecommendationViewModel — state + services, no UI logic
├── Services/
│   ├── LocationService/       → CoreLocation behind LocationServiceProtocol
│   ├── NetworkMonitor/        → NWPathMonitor behind NetworkMonitorProtocol
│   │                            (distinguishes offline from service-unavailable)
│   └── RecommendationService/
│       ├── RecommendationAPI.swift             → Moya TargetType enum
│       ├── RecommendationServiceProtocol.swift → the abstraction
│       └── RecommendationService.swift         → Moya-backed implementation
├── Models/                → RecommendationModels.swift: RecommendationResponse,
│                            HeroPick, SpecialtyPick, PhotoResponse, HeroPhoto,
│                            PlaceDetailItem
└── Core/                  → Theme, FactFormatter, DirectionsLink, ScreenTransition,
    └── Components/          StatusBarStyleManager, PhotoLuminanceDetector, error types,
                             AppBar, PrimaryButton, AppGlyphs, LottiePlayer, …
```

**The one rule that matters:** ViewModels depend only on protocols (`RecommendationServiceProtocol`, `LocationServiceProtocol`, `NetworkMonitorProtocol`), never on concrete implementations or third-party libraries directly. Never call a service directly from a View or ViewModel. This dependency inversion is what lets networking/data sources/AI providers get swapped later without touching UI or business logic — it's the whole architectural point of this project, not incidental style.

**Gotcha when adding a `NetworkErrorVariant` case:** `RecommendationView.Screen.hashKey` switches exhaustively over it, in a file that never mentions the new state. Adding a case breaks the build there. Grep for other switches on the enum rather than trusting a per-file check.

**Tests are thin — do not read a green suite as safety.** Two unit tests exist, both on `FactFormatter` number formatting. Nothing covers the decode path, the service layer, or `_is_place_open`, which is exactly where the real bugs of 2026-09-17 were. Run the suite, but verify behaviour against the live function too.

**Networking:** Moya (over Alamofire) as the abstraction, one `TargetType` per endpoint. Chosen because it's a well-known convention an AI agent will recognize rather than guessing at a bespoke layer.

**Backend:** Firebase Cloud Functions hold the Gemini API and Google Places API keys — never embedded in the client app. The client calls the Cloud Function, not the third-party APIs directly. Backend source code lives in `firebase/functions/` (managed via `firebase/firebase.json`; run Firebase CLI commands inside `firebase/`).

**Cost-sensitive services:** Google Places and Gemini calls have hard usage/quota caps configured server-side — check `docs/brain/wiki/entities/google-places-api.md` and `gemini-api.md` before touching quota logic. Current caps: `DAILY_REQUEST_LIMIT = 30`, `DAILY_PHOTO_LIMIT = 33`.

**Caching — read this before changing anything that touches Places or photos:**

- `location_cache` keys on lat/lng rounded to 2dp (~1km grid), 48h TTL. Both quota checks live *inside* the cache-miss branch, so a cache hit spends zero Places quota. Keep it that way.
- `photo_cache` is not really a cache: `get_photo` downloads the image once, compresses it to WebP, uploads it to Firebase Storage, and serves your own permanent URL. 365-day TTL because Google is never asked again.
- **Gemini runs on every request, outside the cache branch.** A cache hit costs 0 Places calls but 1 Gemini call. `DAILY_REQUEST_LIMIT` guards only the Places side — Gemini is currently uncapped. This is deliberate (a cached pick would break "Try another") but it is the uncapped surface.
- **Adding a field to the cached candidate shape needs a staleness guard** in `_get_cached_candidates`, or existing entries serve the field as missing until the TTL expires. This caused a real bug on 2026-09-17: photo attribution shipped, looked broken for a day, and the cause was a guard deliberately skipped to save one Places call per location. An uncredited Places photo is a terms violation; the refresh is cheaper than the violation.

**Gemini prompt economics:** never put long opaque identifiers in the prompt. photoRefs are ~240 characters each and were 43% of the prompt before being replaced with integer ids that `_find_matching_candidate` resolves server-side. `gemini_usage` is logged on every call — check Cloud Logging for real token counts rather than estimating. Note that `max_output_tokens` bounds cost per call but does **not** decide free vs pay-as-you-go; that is set by whether billing is enabled on the API key's Cloud project.

## Product

One-screen, one-button ("I'm Hungry") flow: location → Cloud Function → one Gemini call returns a hero best-value restaurant pick with a reason, plus 2-3 "specialty food" picks from the same candidate list. No login, no search bar, no list-of-results dashboard — this is a decision tool for tourists unfamiliar with the local food scene, not a directory.

## Working style with the project owner (Sadri)

If a decision looks technically, financially, or strategically questionable, say so directly and invite debate before going along with it — don't silently comply just because it was already stated. This was explicitly requested.

## graphify

This project has a graphify knowledge graph at graphify-out/.

Rules:
- Before answering architecture or codebase questions, read graphify-out/GRAPH_REPORT.md for god nodes and community structure
- If graphify-out/wiki/index.md exists, navigate it instead of reading raw files
- For cross-module "how does X relate to Y" questions, prefer `graphify query "<question>"`, `graphify path "<A>" "<B>"`, or `graphify explain "<concept>"` over grep — these traverse the graph's EXTRACTED + INFERRED edges instead of scanning files
- After modifying code files in this session, run `graphify update .` to keep the graph current (AST-only, no API cost)
