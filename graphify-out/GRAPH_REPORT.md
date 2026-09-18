# Graph Report - hungrynow  (2026-09-18)

## Corpus Check
- 62 files · ~1,479,252 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 493 nodes · 649 edges · 42 communities detected
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 49 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]

## God Nodes (most connected - your core abstractions)
1. `AppGlyph` - 25 edges
2. `_is_place_open()` - 19 edges
3. `IsPlaceOpen` - 17 edges
4. `utc()` - 16 edges
5. `RecommendationViewModel` - 16 edges
6. `RecommendationServiceError` - 15 edges
7. `build_layers()` - 13 edges
8. `period()` - 13 edges
9. `Coordinator` - 12 edges
10. `LocationService` - 12 edges

## Surprising Connections (you probably didn't know these)
- `_pick_recommendations()` --calls--> `_is_place_open()`  [EXTRACTED]
  firebase/functions/main.py → firebase/functions/main.py  _Bridges community 4 → community 6_
- `_enrich_hero()` --calls--> `_find_matching_candidate()`  [EXTRACTED]
  firebase/functions/main.py → firebase/functions/main.py  _Bridges community 12 → community 6_
- `RootView` --inherits--> `View`  [EXTRACTED]
  hungrynow/App/RootView.swift →   _Bridges community 0 → community 2_
- `NetworkErrorView` --inherits--> `View`  [EXTRACTED]
  hungrynow/Features/Recommendation/Views/NetworkErrorView.swift →   _Bridges community 0 → community 3_
- `SearchingView` --inherits--> `View`  [EXTRACTED]
  hungrynow/Features/Recommendation/Views/SearchingView.swift →   _Bridges community 0 → community 10_

## Hyperedges (group relationships)
- **Session Vault Bootstrap Sequence** — claude_obsidian_vault, claude_checklist_md, claude_wiki_log_md, claude_wiki_index_md [EXTRACTED 1.00]
- **Dependency Inversion Pattern** — claude_dependency_inversion_rule, claude_recommendationserviceprotocol, claude_locationservice_protocol [EXTRACTED 1.00]
- **Backend API Key Isolation** — claude_firebase_cloud_functions, claude_gemini_api, claude_google_places_api [EXTRACTED 1.00]

## Communities

### Community 0 - "Community 0"
Cohesion: 0.05
Nodes (21): AppBar, LocationChip, WordmarkView, GhostButton, PrimaryButton, ResultFactsCard, ResultFooter, ResultMediaHeader (+13 more)

### Community 1 - "Community 1"
Cohesion: 0.09
Nodes (30): PhotoLuminanceDetector, Int, fmt(), to_swift(), anim(), arc_to_cubics(), build_layers(), cb_eval() (+22 more)

### Community 2 - "Community 2"
Cohesion: 0.07
Nodes (24): RootView, Route, locationDenied, recommendation, welcome, Fact, Decodable, Hashable (+16 more)

### Community 3 - "Community 3"
Cohesion: 0.06
Nodes (29): ReasonText, TextHeightPair, TextHeightsKey, LocationServiceError, geocodingFailed, locationUnavailable, permissionDenied, permissionRestricted (+21 more)

### Community 4 - "Community 4"
Cohesion: 0.14
Nodes (16): _is_place_open(), Determines if a candidate restaurant is currently open.     Returns:       True:, _extract(), IsPlaceOpen, period(), A bar open Saturday 20:00 to Sunday 03:00 is open at 01:00 Sunday., Google omits `close` for a 24/7 business., Lunch 11-14, dinner 18-22: closed in the afternoon gap. (+8 more)

### Community 5 - "Community 5"
Cohesion: 0.1
Nodes (8): OffsetTrackerView, ScrollOffsetTracker, View, UIView, UIViewRepresentable, Coordinator, InnerScrollViewManager, LayoutTriggeringView

### Community 6 - "Community 6"
Cohesion: 0.12
Nodes (26): _cache_candidates(), _cache_key(), _cache_photo_uri(), _compress_to_webp(), _consume_daily_limit(), _enrich_hero(), _enrich_specialty(), _error() (+18 more)

### Community 7 - "Community 7"
Cohesion: 0.1
Nodes (5): StatusBarStyleManager, HeroPhoto, ObservableObject, RecommendationViewModel, WelcomeViewModel

### Community 8 - "Community 8"
Cohesion: 0.11
Nodes (11): App, hungrynowApp, FactFormatter, String, State, idle, loaded, loading (+3 more)

### Community 9 - "Community 9"
Cohesion: 0.09
Nodes (21): AppGlyph, check, chevronLeft, chevronRight, cutlery, directions, externalLink, foodCup (+13 more)

### Community 10 - "Community 10"
Cohesion: 0.12
Nodes (12): CaseIterable, AsymmetricRoundedRectangle, BundleToken, Color, LottiePlayer, Shape, SearchingView, SearchStage (+4 more)

### Community 11 - "Community 11"
Cohesion: 0.12
Nodes (4): hungrynowTests, hungrynowUITests, hungrynowUITestsLaunchTests, XCTestCase

### Community 12 - "Community 12"
Cohesion: 0.24
Nodes (4): _find_matching_candidate(), FindMatchingCandidate, Resolving a model's pick back to the candidate it came from.      This is what l, `id: 0` is falsy — a truthiness check here would skip candidate zero.

### Community 13 - "Community 13"
Cohesion: 0.22
Nodes (4): CLLocationManagerDelegate, LocationService, LocationServiceProtocol, NSObject

### Community 14 - "Community 14"
Cohesion: 0.2
Nodes (5): AppFont, Color, GlyphMetrics, Metrics, MockupArt

### Community 15 - "Community 15"
Cohesion: 0.54
Nodes (7): cb(), main(), path_d(), render_group(), rgb(), sc(), val()

### Community 16 - "Community 16"
Cohesion: 0.33
Nodes (2): page(), updatePhotoIndicator()

### Community 17 - "Community 17"
Cohesion: 0.38
Nodes (2): RecommendationService, RecommendationServiceProtocol

### Community 18 - "Community 18"
Cohesion: 0.33
Nodes (2): ScreenTransition, View

### Community 19 - "Community 19"
Cohesion: 0.4
Nodes (3): ButtonStyle, ButtonStyle, PressableRowStyle

### Community 20 - "Community 20"
Cohesion: 0.4
Nodes (2): NetworkMonitor, NetworkMonitorProtocol

### Community 21 - "Community 21"
Cohesion: 0.4
Nodes (4): nonisolated, RecommendationAPI, getPhoto, getRecommendation

### Community 22 - "Community 22"
Cohesion: 0.5
Nodes (1): DirectionsLink

### Community 23 - "Community 23"
Cohesion: 0.83
Nodes (4): checklist.md (vault source of truth), HungryNow Obsidian Vault, wiki/index.md (page catalog), wiki/log.md (decision log)

### Community 24 - "Community 24"
Cohesion: 0.67
Nodes (4): Dependency Inversion Rule ("the one rule that matters"), LocationService protocol, Moya (over Alamofire) networking layer, RecommendationServiceProtocol

### Community 25 - "Community 25"
Cohesion: 0.67
Nodes (4): Firebase Cloud Functions backend, Gemini API, Google Places API, "I'm Hungry" one-screen one-button flow

### Community 28 - "Community 28"
Cohesion: 1.0
Nodes (2): static(), transform()

### Community 29 - "Community 29"
Cohesion: 0.67
Nodes (2): AnyObject, NetworkMonitorProtocol

### Community 31 - "Community 31"
Cohesion: 1.0
Nodes (1): LocationServiceProtocol

### Community 32 - "Community 32"
Cohesion: 1.0
Nodes (1): RecommendationServiceProtocol

### Community 34 - "Community 34"
Cohesion: 1.0
Nodes (1): Atomically increments today's usage counter in the given collection.     Returns

### Community 35 - "Community 35"
Cohesion: 1.0
Nodes (1): Determines if a candidate restaurant is currently open.     Returns:       True:

### Community 36 - "Community 36"
Cohesion: 1.0
Nodes (1): Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle

### Community 37 - "Community 37"
Cohesion: 1.0
Nodes (1): Uploads to Firebase Storage and returns a permanent, keyless, public     downloa

### Community 38 - "Community 38"
Cohesion: 1.0
Nodes (1): Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle

### Community 39 - "Community 39"
Cohesion: 1.0
Nodes (1): Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle

### Community 40 - "Community 40"
Cohesion: 1.0
Nodes (1): Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle

### Community 41 - "Community 41"
Cohesion: 1.0
Nodes (1): Uploads to Firebase Storage and returns a permanent, keyless, public     downloa

### Community 42 - "Community 42"
Cohesion: 1.0
Nodes (1): Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle

### Community 43 - "Community 43"
Cohesion: 1.0
Nodes (1): Planned Architecture (not yet implemented)

### Community 44 - "Community 44"
Cohesion: 1.0
Nodes (1): Bundle ID com.revaiter.hungrynow (Revaiter)

### Community 45 - "Community 45"
Cohesion: 1.0
Nodes (1): Working style with project owner (Sadri)

## Knowledge Gaps
- **105 isolated node(s):** `y at x on a CSS cubic-bezier(x1,y1,x2,y2). Newton, then clamp.`, `keys: [(frame, [values], ease_of_the_segment_that_STARTS_here)].      A Lottie k`, `Express a CSS keyframe cycle with an `animation-delay` as one loop of keys.`, `SVG elliptical arc -> cubic segments (endpoint parameterisation, F.6.5).`, `-> list of subpaths, each {"nodes": [{"v","i","o"}], "closed": bool}.` (+100 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 16`** (7 nodes): `prototype.js`, `appendReview()`, `page()`, `selectDetailTab()`, `setPlate()`, `updateDetailAppbar()`, `updatePhotoIndicator()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 17`** (7 nodes): `RecommendationService.swift`, `RecommendationService`, `.getPhoto()`, `.getRecommendation()`, `.init()`, `.request()`, `RecommendationServiceProtocol`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 18`** (6 nodes): `ScreenTransition`, `.animation()`, `.transition()`, `View`, `.screenGeometryGroup()`, `ScreenTransition.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 20`** (5 nodes): `NetworkMonitor.swift`, `NetworkMonitor`, `.deinit()`, `.init()`, `NetworkMonitorProtocol`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 22`** (4 nodes): `DirectionsLink`, `.appleMaps()`, `.googleMapsPlace()`, `DirectionsLink.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 28`** (3 nodes): `build-nearby-search-lottie.py`, `static()`, `transform()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 29`** (3 nodes): `AnyObject`, `NetworkMonitorProtocol.swift`, `NetworkMonitorProtocol`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 31`** (2 nodes): `LocationServiceProtocol.swift`, `LocationServiceProtocol`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 32`** (2 nodes): `RecommendationServiceProtocol.swift`, `RecommendationServiceProtocol`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 34`** (1 nodes): `Atomically increments today's usage counter in the given collection.     Returns`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 35`** (1 nodes): `Determines if a candidate restaurant is currently open.     Returns:       True:`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 36`** (1 nodes): `Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 37`** (1 nodes): `Uploads to Firebase Storage and returns a permanent, keyless, public     downloa`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 38`** (1 nodes): `Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 39`** (1 nodes): `Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 40`** (1 nodes): `Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 41`** (1 nodes): `Uploads to Firebase Storage and returns a permanent, keyless, public     downloa`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 42`** (1 nodes): `Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 43`** (1 nodes): `Planned Architecture (not yet implemented)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 44`** (1 nodes): `Bundle ID com.revaiter.hungrynow (Revaiter)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 45`** (1 nodes): `Working style with project owner (Sadri)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PlaceDetailsView` connect `Community 0` to `Community 8`, `Community 5`?**
  _High betweenness centrality (0.125) - this node is a cross-community bridge._
- **Why does `AppGlyph` connect `Community 9` to `Community 8`, `Community 0`, `Community 10`?**
  _High betweenness centrality (0.090) - this node is a cross-community bridge._
- **Why does `SearchStage` connect `Community 10` to `Community 1`?**
  _High betweenness centrality (0.086) - this node is a cross-community bridge._
- **Are the 15 inferred relationships involving `_is_place_open()` (e.g. with `.test_open_during_listed_hours()` and `.test_closed_before_opening()`) actually correct?**
  _`_is_place_open()` has 15 INFERRED edges - model-reasoned connections that need verification._
- **What connects `y at x on a CSS cubic-bezier(x1,y1,x2,y2). Newton, then clamp.`, `keys: [(frame, [values], ease_of_the_segment_that_STARTS_here)].      A Lottie k`, `Express a CSS keyframe cycle with an `animation-delay` as one loop of keys.` to the rest of the system?**
  _105 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.09 - nodes in this community are weakly interconnected._