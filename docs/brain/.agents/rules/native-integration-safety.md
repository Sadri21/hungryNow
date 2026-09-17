# HungryNow native integration safety — Always On

Read and follow @../../CLAUDE.md before modifying HungryNow. Before implementing a screen or feature, also read its directly relevant contract in `wiki/concepts/`, `wiki/entities/`, or `wiki/synthesis/`. Do not begin from the HTML alone.

## Mandatory stop conditions

- If the documented implementation requires a missing SDK, Swift package, framework, entitlement, API key, backend endpoint, or configuration, stop that implementation and tell Sadri exactly what is missing, why it is required, and how to install or configure it.
- Never treat a missing dependency as permission to invent a replacement, reduce the architecture, or make the feature appear complete with hard-coded values.
- Never put mock data, fixtures, stubs, sample responses, or HTML demo values into native/runtime HungryNow code unless Sadri explicitly authorizes mock data for a specific debugging task.
- Static fixture data is allowed only in `output/mockups/`, because HTML cannot install or execute iOS SDKs. Keep those fixtures design-only and never copy them into Swift.
- If live integration cannot be completed, leave it clearly blocked and report the blocker. Do not claim completion.

## Screen 6A

Screen 6A must use `GooglePlacesSwift.PlaceDetailsView` with provider-managed media and reviews as specified in `wiki/concepts/app-mockups.md`. Google owns the photo collage/gallery, image count, review content, loading, and attribution. If `GooglePlacesSwift` is missing, tell Sadri to add/configure the package and stop; do not build a custom native imitation and do not use the HTML restaurant, photos, reviews, counts, hours, or contact details.

## Google Places key boundary

- Keep Gemini and the Google Places REST/web-service key in Firebase Functions; never put either server credential in the app.
- Screen 6A uses one separate, dedicated iOS Places SDK key for the current stage. Do not require two keys unless separate dev/prod bundle IDs or operational isolation are introduced.
- Restrict the iOS key to HungryNow's exact bundle ID and only Places SDK for iOS / Places API (New); enable Firebase App Check and client-specific quotas/monitoring.
- Keep the value out of Git using an ignored `Secrets.xcconfig` and a committed value-free example. Do not claim that `Info.plist`, Keychain, obfuscation, or remote delivery makes a shipped client key secret.
- If the iOS key or its restrictions are not configured, stop and tell Sadri what to configure. Never reuse the server key as a shortcut.

## Completion report

Always distinguish among:

- HTML mockup changes;
- native code integrated with real dependencies;
- blocked work caused by a missing dependency or configuration.

Never describe the first as the second.
