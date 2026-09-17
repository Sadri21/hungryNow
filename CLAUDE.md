# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

This is a fresh SwiftUI iOS app (Xcode default template, no custom code yet beyond `ContentView.swift` / `hungrynowApp.swift`). The real architecture below is the *planned* structure — it does not exist in the codebase yet. Check `hungrynow/` before assuming any file mentioned here has been created.

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

## Architecture (planned — see `wiki/concepts/architecture.md` in the vault for the canonical version)

```
hungrynow/
├── App/                  → entry point only
├── Features/
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
```

**The one rule that matters:** ViewModels depend only on protocols (`RecommendationServiceProtocol`, a location-service protocol), never on concrete implementations or third-party libraries directly. Never call a service directly from a View or ViewModel. This dependency inversion is what lets networking/data sources/AI providers get swapped later without touching UI or business logic — it's the whole architectural point of this project, not incidental style.

**Networking:** Moya (over Alamofire) as the abstraction, one `TargetType` per endpoint. Chosen because it's a well-known convention an AI agent will recognize rather than guessing at a bespoke layer.

**Backend:** Firebase Cloud Functions hold the Gemini API and Google Places API keys — never embedded in the client app. The client calls the Cloud Function, not the third-party APIs directly. Backend source code lives in `firebase/functions/` (managed via `firebase/firebase.json`; run Firebase CLI commands inside `firebase/`).

**Cost-sensitive services:** Google Places and Gemini calls have hard usage/quota caps that must be configured server-side — check `wiki/entities/google-places-api.md` and `wiki/entities/gemini-api.md` in the vault before touching quota logic.

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
