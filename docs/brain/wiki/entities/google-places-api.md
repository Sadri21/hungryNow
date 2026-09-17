# Google Places API (New)

General field-tier table and safeguard pattern moved to the main vault: `wiki/entities/tools/google-places-api.md`.

Place data source. Chosen over OpenStreetMap for data quality (see [[places-api-vs-openstreetmap]]).

**HungryNow-specific:**

This app requests rating + priceLevel + userRatingCount + currentOpeningHours/regularOpeningHours/utcOffsetMinutes → **Enterprise tier, 1,000 free calls/month.**

**Decision:** use them anyway. Without rating/price, the app can't honestly claim "best value" — that's the core promise, not a nice-to-have. And without opening hours, the app risks recommending closed restaurants to tourists who are hungry right now. Because rating/price already placed Nearby Search in the Enterprise tier, adding `currentOpeningHours` incurs no additional SKU cost or tier jump.

**Decision:** use them anyway. Without rating/price, the app can't honestly claim "best value" — that's the core promise, not a nice-to-have.

**Cap:** total Nearby Search calls capped at **900/month (~30/day)**. That's safely under the smallest tier (Enterprise, 1,000/month), so no matter which fields end up being requested, staying under this cap makes billing physically impossible. Do not use larger numbers like "8,000/day" or "100/day" — both were considered and rejected earlier in this project (100/day exhausts the whole month's free allowance in 10 days).

**Required safeguards, both must exist before this is used with real traffic:**
1. Google Cloud Console → APIs & Services → Quotas — Nearby Search daily quota capped at **30/day**
2. App-level counter in the Cloud Function (Firestore, reset daily) — refuse calls once the day's count hits **30**
3. Billing budget alert at a low dollar amount as a backup notification (does NOT stop spending on its own — safeguards 1 and 2 are what actually prevent charges)

Requires billing enabled (real card on file) even to use the free tier.

**Photo API safeguards (`get_photo`), both now confirmed in place:**
1. Google Cloud Console → APIs & Services → Quotas — Place Photo daily quota capped at **33/day**
2. App-level counter in the Cloud Function (Firestore, `photo_usage_counters/{date}`, `DAILY_PHOTO_LIMIT=33`, reset daily) — refuse calls once the day's count hits 33

## Client-side Places SDK key decision (2026-09-16)

Screen 6A uses the provider-rendered `GooglePlacesSwift.PlaceDetailsView`, which calls Google directly from iOS and requires `PlacesClient.provideAPIKey(_:)`. The Firebase/server Places key cannot be used for this.

- Create **one dedicated HungryNow iOS Places key for now**. Two dev/prod keys are optional until the app has separate bundle identifiers or needs separate rotation, quotas, and monitoring.
- Apply an **iOS application restriction** for HungryNow's exact bundle identifier and an **API restriction** limited to Places SDK for iOS / Places API (New).
- Enable Firebase App Check for the Places SDK (production attestation; debug provider only in debug builds).
- Keep the value out of version control using an ignored `Secrets.xcconfig` plus a committed value-free example file. Passing it through a build setting or `Info.plist` prevents repository leakage but does not hide it from the compiled app.
- Configure client-specific quotas, monitoring, and billing alerts because `PlaceDetailsView` queries bypass the Cloud Function counter.
- Keep Gemini and Google Places REST/web-service keys in Firebase Functions. Never reuse a server key in the iOS client.

Official references: [Google Maps Platform security guidance](https://developers.google.com/maps/api-security-best-practices), [Places SDK for iOS App Check](https://developers.google.com/maps/documentation/places/ios-sdk/app-check), and [`PlacesClient.provideAPIKey(_:)`](https://developers.google.com/maps/documentation/places/ios-sdk/reference/swift/Classes/PlacesClient).

**Future optimization, not needed now:** Nearby Search with Pro-only fields for the candidate list, then Place Details with Enterprise fields only for the 1-2 places about to be recommended (not the whole batch). Confines expensive fields to a handful of calls per request instead of every nearby result — worth doing if this ever reaches real-user scale.
