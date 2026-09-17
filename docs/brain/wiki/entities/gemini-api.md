# Gemini API

General facts, rate limits, and gotchas moved to the main vault: `wiki/entities/tools/gemini-api.md`.

**HungryNow-specific usage:**

- Used for the recommendation reasoning: given a candidate list of nearby places, returns one hero pick + 2-3 specialty picks, each with a short reason.
- Rate limit on free tier: 15 requests/minute (Flash model) — the real ceiling before token count matters.
- Typical request cost for this app: ~600-700 tokens total (input + output) per call — far under the free daily allowance.
- Currently using `gemini-3.5-flash-lite` (500 RPD free tier) after `gemini-3.6-flash` (only 20 RPD free tier) proved too easy to exhaust during dev/testing — see main vault `wiki/entities/tools/gemini-api.md` for the general lesson this taught.
