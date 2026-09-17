# Gaps

Known-but-undocumented areas and open safety/documentation items for HungryNow. Not a build TODO (that's `checklist.md`) — this tracks what the *wiki* is missing or what's still genuinely unresolved. Review and prune when a gap gets closed.

## Undocumented entities

- **Firestore has no entity page**, despite being a core dependency used three separate ways (daily request-quota counter, location result cache, permanent photo-URL cache). Worth its own `wiki/entities/firestore.md` — collection names, TTLs, and the transaction pattern used for the daily counters are currently only in `log.md`, scattered across several dated entries.
- **CoreLocation / the location-service layer has no entity page.** `architecture.md` mentions `LocationService/` exists behind a protocol, but nothing documents CoreLocation itself (permission model, accuracy settings) — will matter once "Wire up CoreLocation" (checklist, next week) starts.

## Open questions, not yet resolved

- **Real-device testing not done.** `ios-vs-android.md` (main vault) notes Simulator covers everything except true GPS drift, camera, and final performance — no plan yet for when/how that gets validated before shipping.
- **Edge-case UX undecided.** Checklist has "Handle edge cases: permission denied, zero results, network failure" as an open item, but no synthesis page yet on what each state should actually show the user.
- **Moya `TargetType` + protocol shell not started** (checklist stretch item) — `architecture.md`'s networking section describes the intended design, not a verified implementation.

## Empty sections

- `wiki/sources/` has no entries — Firebase, Gemini, Google Places, and Moya docs were clearly consulted during the build but never logged as source pages.
