# API Contract

Fixed reference for the iOS `Models/` layer (`RecommendationResponse`, `SpecialtyPick`, etc.) and [[moya]] `TargetType` definitions. Source of truth is `functions/main.py`'s `RESPONSE_SCHEMA` and the two `@https_fn.on_request` handlers — this page is the documented mirror of that, current as of the 2026-09-03 session (see [[log]]). If the two ever disagree, trust the code and update this page.

Both endpoints are plain HTTPS POST/GET Cloud Functions (`https_fn.on_request`), not callable functions — Moya just hits their URLs directly, no Firebase SDK needed on the client.

## `get_recommendation`

**Request** — `POST`, JSON body:

```json
{
  "latitude": 13.7563,
  "longitude": 100.5018
}
```

Both fields required — missing either returns `400 missing_location`.

**Success response** — `200`, JSON body:

```json
{
  "hero": {
    "name": "string",
    "address": "string",
    "phone": "string | null",
    "reason": "string",
    "description": "string",
    "foodCategory": "string",
    "photoRef": "string | null"
  },
  "specialties": [
    {
      "name": "string",
      "address": "string",
      "phone": "string | null",
      "reason": "string",
      "description": "string",
      "foodCategory": "string"
    }
  ]
}
```

**Fields the UI needs and the response doesn't have (found 2026-09-07 while designing screen 06 — see [[app-mockups]]):**

| Needed | For | Why the current response can't do it |
|---|---|---|
| `latitude`, `longitude` | the Directions button; the distance shown on the hero card | A deep link built from `name` + `address` makes the nav app re-geocode a text query. For a chain — and the test hero, "Restoran Nasi Kandar Ar Rashid", is one — that lands people at the wrong branch, which is worse than no button. Distance can't be computed at all without coordinates. |
| `placeId` | the best Google Maps deep link (`query_place_id`) | Unambiguous, and it's the one piece of Places content Google permits storing indefinitely. |
| `rating` | the `★ 4.7` on the hero card | Not in the response; the mockup is currently showing a number the API doesn't return. |
| `priceLevel` | the fact row's PRICE column | Google's price_level (1..4), needed to show per-person price ranges. |
| `openNow` | "Open Now" validation | Ensures recommendations are open when the tourist is hungry right now. |

All these already come back from Places Nearby Search in the backend. Rating, coordinates, placeId, and priceLevel are enriched server-side into the hero and specialty objects before the response is returned.

### Candidate selection & Opening hours (Open Now)
- **Places API Fields:** Nearby Search queries `places.currentOpeningHours`, `places.regularOpeningHours`, and `places.utcOffsetMinutes`.
- **Dynamic Evaluation:** The Cloud Function calculates the restaurant's local time via `utcOffsetMinutes` and evaluates its `regularOpeningHours.periods` dynamically on every recommendation request. This prevents stale status even when candidates are served from the 48-hour Firestore cache.
- **Filtering & Gemini:** Confirmed closed places are filtered out before calling Gemini whenever at least 4 verified open options exist. Authentic local stalls with unrecorded hours are retained if open options are limited. Gemini's prompt explicitly enforces: *"The user is hungry now, so you MUST only pick restaurants that are currently open (isOpenNow is True or 'unknown')."* This is a passthrough change, not new API calls or new quota. Until it lands, screen 06's meta row and Directions button are both ahead of the contract.

Notes for the Swift model layer:
- `specialties` always has 2–3 items (schema-enforced `minItems`/`maxItems`), never 0, 1, or 4+.
- `hero` is a single object, not wrapped in an array — different shape from `specialties`, don't reuse the same Codable type for both. `photoRef` is hero-only; `SpecialtyPick` has no photo field at all.
- `phone` and `photoRef` are nullable in the schema (`"nullable": True`) — model them as `String?` in Swift, not force-unwrapped.
- `name`, `address`, `reason`, `description`, `foodCategory` are always present and non-null on every pick (schema `required` list) — safe to model as non-optional `String`.
- `foodCategory` is short (1–3 words, e.g. "Ramen", "Sushi") — intended as the key into the app's bundled generic-icon library, used as the fallback whenever a real photo isn't available (no `photoRef`, or [[google-places-api]]'s photo quota is exhausted).
- The hero and every specialty are guaranteed distinct restaurants — enforced by the Gemini prompt, not by a JSON schema constraint (schemas can't express "all names distinct"), so this is a behavioral guarantee, not a structural one.

**Error responses** — all JSON `{"error": "<code>"}`, HTTP status varies by code:

| status | error code | meaning |
|---|---|---|
| 400 | `missing_location` | `latitude`/`longitude` missing from request body |
| 404 | `no_results` | Places Nearby Search returned zero candidates for this location |
| 429 | `daily_limit_reached` | code-owned Places daily quota (`DAILY_REQUEST_LIMIT`, currently 30) hit — mirrors the console-side cap, see [[google-places-api]] |
| 502 | `places_lookup_failed` | Places API request itself failed (network/HTTP error) |
| 502 | `recommendation_failed` | both Gemini models exhausted their retry budget — see [[gemini-api]] for the fallback chain |

The app should map `429`/`502` to a generic "try again" state and `404` to a "no restaurants nearby" state — none of these are recoverable client-side, no retry-with-different-params makes sense for any of them.

## `get_photo`

Lazy, on-demand endpoint — call only when the user taps into the hero pick's detail view, never eagerly for all picks (cost reasons, see [[google-places-api]]).

**Request** — `GET` or `POST`, `photoRef` as a query param (`?photoRef=...`) or JSON body field — handler accepts either.

```json
{ "photoRef": "places/ChIJ.../photos/AWU5..." }
```

`photoRef` comes verbatim from the `hero.photoRef` field in the `get_recommendation` response — the client never constructs or guesses one.

**Success response** — `200`:

```json
{ "photoUri": "https://firebasestorage.googleapis.com/v0/b/.../o/photos%2F<hash>.webp?alt=media&token=..." }
```

This is a permanent, keyless, publicly-loadable URL (Firebase Storage, not Google's Place Photo endpoint directly) — safe to load straight into an `AsyncImage`/`SDWebImage`-style view with no auth header. WebP format.

**Error responses**:

| status | error code | meaning |
|---|---|---|
| 400 | `missing_photo_ref` | no `photoRef` supplied |
| 429 | `photo_limit_reached` | daily photo quota (`DAILY_PHOTO_LIMIT`, currently 33) hit — app should fall back to the bundled generic `foodCategory` icon, not show a broken-image state |
| 502 | `photo_fetch_failed` | fetch from Google, WebP compression, or Storage upload failed |

## Suggested Swift shape

```swift
struct RecommendationResponse: Decodable {
    let hero: HeroPick
    let specialties: [SpecialtyPick]
}

struct HeroPick: Decodable {
    let name, address, reason, description, foodCategory: String
    let phone, photoRef: String?
}

struct SpecialtyPick: Decodable {
    let name, address, reason, description, foodCategory: String
    let phone: String?
}

struct APIErrorResponse: Decodable {
    let error: String
}
```

Not authoritative Swift — just the mapping the JSON above implies. The actual files live in `Models/` per [[architecture]].
