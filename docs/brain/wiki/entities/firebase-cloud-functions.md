# Firebase Cloud Functions

General facts (Blaze/Spark plan behavior, why this is a good default) moved to the main vault: `wiki/entities/tools/firebase-cloud-functions.md`.

**HungryNow-specific (revised 2026-09-16):** backend layer, holds the Gemini key and Google Places REST/web-service key so those server credentials never enter the client app. Screen 6A is the explicit separate-key exception: `GooglePlacesSwift.PlaceDetailsView` uses its own bundle-restricted iOS Places SDK key, never the backend key; see [[architecture]] and [[google-places-api]]. Single endpoint for MVP: fetches nearby places, makes one Gemini call, returns hero pick + specialty picks as JSON.
