# Graph Report - hungrynow  (2026-09-17)

## Corpus Check
- 51 files · ~286,574 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 393 nodes · 499 edges · 38 communities detected
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 11 edges (avg confidence: 0.8)
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
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]

## God Nodes (most connected - your core abstractions)
1. `RecommendationViewModel` - 17 edges
2. `RecommendationServiceError` - 15 edges
3. `Coordinator` - 12 edges
4. `LocationService` - 12 edges
5. `Screen` - 11 edges
6. `get_recommendation()` - 10 edges
7. `get_photo()` - 9 edges
8. `FoodGlyph` - 9 edges
9. `FactFormatter` - 8 edges
10. `OffsetTrackerView` - 8 edges

## Surprising Connections (you probably didn't know these)
- `Atomically increments today's usage counter in the given collection.     Returns` --rationale_for--> `_consume_daily_limit()`  [EXTRACTED]
  functions/main.py → firebase/functions/main.py

## Hyperedges (group relationships)
- **Session Vault Bootstrap Sequence** — claude_obsidian_vault, claude_checklist_md, claude_wiki_log_md, claude_wiki_index_md [EXTRACTED 1.00]
- **Dependency Inversion Pattern** — claude_dependency_inversion_rule, claude_recommendationserviceprotocol, claude_locationservice_protocol [EXTRACTED 1.00]
- **Backend API Key Isolation** — claude_firebase_cloud_functions, claude_gemini_api, claude_google_places_api [EXTRACTED 1.00]

## Communities

### Community 0 - "Community 0"
Cohesion: 0.07
Nodes (26): AppGlyph, cutlery, directions, reload, search, settings, CheckGlyphShape, ChevronLeftGlyphShape (+18 more)

### Community 1 - "Community 1"
Cohesion: 0.05
Nodes (19): AppBar, LocationChip, WordmarkView, GhostButton, ResultFactsCard, ResultFooter, ResultMediaHeader, ResultSheet (+11 more)

### Community 2 - "Community 2"
Cohesion: 0.06
Nodes (28): ReasonText, TextHeightPair, TextHeightsKey, LocationServiceError, geocodingFailed, locationUnavailable, permissionDenied, permissionRestricted (+20 more)

### Community 3 - "Community 3"
Cohesion: 0.17
Nodes (23): _cache_candidates(), _cache_key(), _cache_photo_uri(), _compress_to_webp(), _consume_daily_limit(), _enrich_hero(), _enrich_specialty(), _error() (+15 more)

### Community 4 - "Community 4"
Cohesion: 0.1
Nodes (16): RootView, Route, locationDenied, recommendation, welcome, Fact, FactRow, Decodable (+8 more)

### Community 5 - "Community 5"
Cohesion: 0.18
Nodes (5): UIView, UIViewRepresentable, Coordinator, InnerScrollViewManager, LayoutTriggeringView

### Community 6 - "Community 6"
Cohesion: 0.12
Nodes (11): CaseIterable, FoodGlyph, cup, noodleBowl, riceBowl, skewer, PhotoLuminanceDetector, Int (+3 more)

### Community 7 - "Community 7"
Cohesion: 0.18
Nodes (2): HeroPhoto, RecommendationViewModel

### Community 8 - "Community 8"
Cohesion: 0.12
Nodes (4): hungrynowTests, hungrynowUITests, hungrynowUITestsLaunchTests, XCTestCase

### Community 9 - "Community 9"
Cohesion: 0.13
Nodes (9): PrimaryButton, State, idle, loaded, loading, locationDenied, networkError, noResults (+1 more)

### Community 10 - "Community 10"
Cohesion: 0.21
Nodes (3): OffsetTrackerView, ScrollOffsetTracker, View

### Community 11 - "Community 11"
Cohesion: 0.22
Nodes (4): CLLocationManagerDelegate, LocationService, LocationServiceProtocol, NSObject

### Community 12 - "Community 12"
Cohesion: 0.2
Nodes (8): RecommendationView, Screen, idle, loaded, loading, locationDenied, networkError, noResults

### Community 13 - "Community 13"
Cohesion: 0.22
Nodes (3): StatusBarStyleManager, ObservableObject, WelcomeViewModel

### Community 14 - "Community 14"
Cohesion: 0.2
Nodes (5): AppFont, Color, GlyphMetrics, Metrics, MockupArt

### Community 15 - "Community 15"
Cohesion: 0.33
Nodes (1): FactFormatter

### Community 16 - "Community 16"
Cohesion: 0.38
Nodes (3): BundleToken, Color, LottiePlayer

### Community 17 - "Community 17"
Cohesion: 0.38
Nodes (2): RecommendationService, RecommendationServiceProtocol

### Community 18 - "Community 18"
Cohesion: 0.33
Nodes (2): ScreenTransition, View

### Community 19 - "Community 19"
Cohesion: 0.4
Nodes (2): NetworkMonitor, NetworkMonitorProtocol

### Community 20 - "Community 20"
Cohesion: 0.4
Nodes (4): nonisolated, RecommendationAPI, getPhoto, getRecommendation

### Community 21 - "Community 21"
Cohesion: 0.5
Nodes (1): DirectionsLink

### Community 22 - "Community 22"
Cohesion: 0.5
Nodes (2): App, hungrynowApp

### Community 23 - "Community 23"
Cohesion: 0.83
Nodes (4): checklist.md (vault source of truth), HungryNow Obsidian Vault, wiki/index.md (page catalog), wiki/log.md (decision log)

### Community 24 - "Community 24"
Cohesion: 0.67
Nodes (4): Dependency Inversion Rule ("the one rule that matters"), LocationService protocol, Moya (over Alamofire) networking layer, RecommendationServiceProtocol

### Community 25 - "Community 25"
Cohesion: 0.67
Nodes (4): Firebase Cloud Functions backend, Gemini API, Google Places API, "I'm Hungry" one-screen one-button flow

### Community 26 - "Community 26"
Cohesion: 0.67
Nodes (2): AnyObject, NetworkMonitorProtocol

### Community 27 - "Community 27"
Cohesion: 1.0
Nodes (1): LocationServiceProtocol

### Community 28 - "Community 28"
Cohesion: 1.0
Nodes (1): RecommendationServiceProtocol

### Community 29 - "Community 29"
Cohesion: 1.0
Nodes (1): Uploads to Firebase Storage and returns a permanent, keyless, public     downloa

### Community 30 - "Community 30"
Cohesion: 1.0
Nodes (1): Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle

### Community 31 - "Community 31"
Cohesion: 1.0
Nodes (1): Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle

### Community 32 - "Community 32"
Cohesion: 1.0
Nodes (1): Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle

### Community 33 - "Community 33"
Cohesion: 1.0
Nodes (1): Uploads to Firebase Storage and returns a permanent, keyless, public     downloa

### Community 34 - "Community 34"
Cohesion: 1.0
Nodes (1): Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle

### Community 35 - "Community 35"
Cohesion: 1.0
Nodes (1): Planned Architecture (not yet implemented)

### Community 36 - "Community 36"
Cohesion: 1.0
Nodes (1): Bundle ID com.revaiter.hungrynow (Revaiter)

### Community 37 - "Community 37"
Cohesion: 1.0
Nodes (1): Working style with project owner (Sadri)

## Knowledge Gaps
- **66 isolated node(s):** `Atomically increments today's usage counter in the given collection.     Returns`, `Uploads to Firebase Storage and returns a permanent, keyless, public     downloa`, `Determines if a candidate restaurant is currently open.     Returns:       True:`, `Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle`, `permissionDenied` (+61 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 7`** (17 nodes): `HeroPhoto`, `RecommendationViewModel`, `.cancelSearch()`, `.checkLocationPermission()`, `.deinit()`, `.distance()`, `.extractPriceRange()`, `.extractRating()`, `.findFood()`, `.handleError()`, `.heroFacts()`, `.heroPhotoCount()`, `.heroPhotoRefs()`, `.init()`, `.loadHeroPhoto()`, `.resetToHome()`, `.resolveLocationName()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 15`** (9 nodes): `FactFormatter`, `.compactCount()`, `.decimalFormatter()`, `.distance()`, `.priceRange()`, `.priceTier()`, `.rating()`, `.ratingValue()`, `FactFormatter.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 17`** (7 nodes): `RecommendationService.swift`, `RecommendationService`, `.getPhoto()`, `.getRecommendation()`, `.init()`, `.request()`, `RecommendationServiceProtocol`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 18`** (6 nodes): `ScreenTransition`, `.animation()`, `.transition()`, `View`, `.screenGeometryGroup()`, `ScreenTransition.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 19`** (5 nodes): `NetworkMonitor.swift`, `NetworkMonitor`, `.deinit()`, `.init()`, `NetworkMonitorProtocol`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 21`** (4 nodes): `DirectionsLink`, `.appleMaps()`, `.googleMapsPlace()`, `DirectionsLink.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 22`** (4 nodes): `App`, `hungrynowApp`, `.init()`, `hungrynowApp.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 26`** (3 nodes): `AnyObject`, `NetworkMonitorProtocol.swift`, `NetworkMonitorProtocol`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 27`** (2 nodes): `LocationServiceProtocol.swift`, `LocationServiceProtocol`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 28`** (2 nodes): `RecommendationServiceProtocol.swift`, `RecommendationServiceProtocol`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 29`** (1 nodes): `Uploads to Firebase Storage and returns a permanent, keyless, public     downloa`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 30`** (1 nodes): `Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 31`** (1 nodes): `Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 32`** (1 nodes): `Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 33`** (1 nodes): `Uploads to Firebase Storage and returns a permanent, keyless, public     downloa`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 34`** (1 nodes): `Lazily resolves a hero pick's photoRef to a public, keyless image URL.     Calle`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 35`** (1 nodes): `Planned Architecture (not yet implemented)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 36`** (1 nodes): `Bundle ID com.revaiter.hungrynow (Revaiter)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 37`** (1 nodes): `Working style with project owner (Sadri)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PlaceDetailsView` connect `Community 9` to `Community 0`, `Community 1`, `Community 5`?**
  _High betweenness centrality (0.206) - this node is a cross-community bridge._
- **Why does `RecommendationViewModel` connect `Community 7` to `Community 9`, `Community 13`?**
  _High betweenness centrality (0.081) - this node is a cross-community bridge._
- **What connects `Atomically increments today's usage counter in the given collection.     Returns`, `Uploads to Firebase Storage and returns a permanent, keyless, public     downloa`, `Determines if a candidate restaurant is currently open.     Returns:       True:` to the rest of the system?**
  _66 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.07 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.06 - nodes in this community are weakly interconnected._
- **Should `Community 4` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._