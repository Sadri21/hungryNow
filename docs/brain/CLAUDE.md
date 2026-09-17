# HungryNow — Agent Instructions

This is the knowledge base for the HungryNow iOS app project, structured on Andrej Karpathy's LLM Wiki pattern (raw sources → structured wiki → index). If you are an AI coding agent (Claude Code, Cursor, etc.) helping extend this project, read this first.

## Start here, every fresh session — in this order, nothing more

**Token-saving rule:** Work economically with tokens. Read required project instructions, then only the current checklist section and directly relevant files. Avoid full document dumps and full browser snapshots. Keep tool output short. Reuse existing code and assets; make targeted edits. Check representative screens first, then verify the remaining screens once. Keep progress updates and the final answer concise. Finish with a short handoff note.

Token budget matters — Sadri is running this on limited usage, so don't read the whole vault every time. On a new session, read only:

1. **The current section of `checklist.md`** — `## HTML redesign review`, `## Current focus`, and `## SwiftUI build — open items` at the top are the live agenda (terse, one line per item — completed items and full reasoning live in `wiki/log.md`/`wiki/log-archive.md`, not here). A `<!-- ARCHIVE BELOW -->` marker separates that from older reference/backlog sections (mockup-review drift log, deferred SwiftUI-only items, post-MVP business tasks) — read only down to that marker by default; open what's below it only if the task actually touches one of those specific items.
2. **The tail of `wiki/log.md`** — run `tail -20 wiki/log.md` via bash, don't open it with the Read tool (Read has no "last N lines" mode — without a precomputed offset it reads from the top, and this file has been large enough that a full read costs tens of thousands of tokens). Older sessions live in `wiki/log-archive.md` — open that only if a task needs pre-rotation build history.
3. **`wiki/index.md`** — just the list of what pages exist. Don't open them yet.

Only after those three do you open a specific `wiki/concepts/`, `wiki/entities/`, or `wiki/synthesis/` page — and only the one page directly relevant to the task at hand, not the whole set. If the checklist and log don't answer the question, that's when you go deeper, not before.

## STOP — read the implementation contract; never fake missing integrations

Before implementing or changing any screen, feature, API call, or provider component, open and follow the directly relevant guide in this vault first. For UI work, read that screen's current section in `wiki/concepts/app-mockups.md`; for services and dependencies, also read the relevant page in `wiki/entities/` or `wiki/concepts/`. Treat those documented contracts as implementation requirements, not optional background.

If the documented implementation requires an SDK, Swift package, framework, entitlement, API key, backend endpoint, or other dependency that is not present, **stop and tell Sadri before implementing the feature**. Name the missing dependency, explain why it is required, and state the installation or configuration step. Do not silently replace the integration with a custom imitation, hard-coded data, fixtures, stubs, sample responses, or a reduced local version. A missing package is a blocker to surface, not permission to change the architecture.

**Mock data is forbidden in native/runtime HungryNow code unless Sadri explicitly requests it for a specific debugging task.** The only standing exception is the HTML mockup/prototype directory, because static HTML cannot install or execute the iOS SDKs. Keep HTML fixture data visibly documented as design-only; never copy it into Swift as a fallback and never present an HTML approximation as a completed native integration.

For Screen 6A specifically, native code must use `GooglePlacesSwift.PlaceDetailsView` and its provider-managed media/review content as documented in `wiki/concepts/app-mockups.md`. If `GooglePlacesSwift` or its dedicated restricted iOS key is unavailable, report what must be added/configured and stop that implementation. Do not substitute the HTML restaurant, photos, reviews, counts, hours, or contact details in the app. Do not reuse the Firebase/server Places key; follow the client-key boundary in `wiki/concepts/architecture.md` and `wiki/entities/google-places-api.md`.

Before reporting completion, state separately what was changed in the HTML mockup and what was implemented against live/native dependencies. Never claim a feature is implemented when only its mockup or fixture-backed version exists.

Antigravity enforcement mirrors this section in `.agents/rules/native-integration-safety.md`. Keep that workspace rule set to **Always On**; if either copy changes, update the other in the same edit.

This vault lives at `docs/brain/` inside the project repo. It covers product/architecture *decisions* — it doesn't track the actual code structure. For that, the repo has its own knowledge graph: check `graphify-out/GRAPH_REPORT.md` there for god nodes and community structure before searching raw source files, and `graphify query "<question>"` for cross-file relationships. It's kept current automatically as code changes (see the project's own `CLAUDE.md`).

At the end of a session: check off completed items in `checklist.md`, append what happened to `wiki/log.md`, then run `wc -l wiki/log.md` — if it's past ~20 lines (roughly 1-2 sessions), rotate everything except the current session into `wiki/log-archive.md` right then (see rule 6 below), and stop there — don't rewrite pages that didn't change.

## What this project is

An AI restaurant-recommendation app for tourists who don't know the local food scene. One-tap hero recommendation + a small "Try Specialty Food" section. Full context: `wiki/concepts/product-overview.md`.

## How this vault is organized

- `raw/` — inbox for unprocessed notes, pasted docs, decisions-in-progress. Not meant to be polished.
- `wiki/sources/` — one summary per external reference (API docs, libraries used)
- `wiki/entities/` — one page per tool/service/dependency the project depends on
- `wiki/concepts/` — architecture decisions, patterns, and the product/business positioning
- `wiki/synthesis/` — trade-off analyses and comparisons behind key decisions
- `wiki/gaps.md` — known-but-undocumented areas and open items; review and prune when a gap closes, add one when you notice a real gap
- `wiki/index.md` — master catalog of every page in this vault
- `wiki/log.md` — chronological record of what was decided/built, in order. Kept short (recent sessions only) — rotate older ones to `wiki/log-archive.md` once it grows past ~1-2 sessions or ~20 lines (check every session, don't wait to notice it's grown — see rule 6 below), same rule as the main vault's `wiki/concepts/tech/freshness-and-health.md`
- `wiki/log-archive.md` — older `log.md` sessions, rotated out to keep the active log cheap to read. Full history, nothing summarized away; open only on demand

## Rules for extending this codebase

1. **Follow SOLID principles already established** — see `wiki/concepts/architecture.md` for the current module structure and dependency direction (protocols first, concrete implementations behind them).
2. **Never call a service directly from a View or ViewModel** — always go through the protocol defined in `Services/`. This is what keeps the app testable and swappable.
3. **Before adding a new dependency or API**, check `wiki/entities/` — it may already be documented, including known limitations (rate limits, cost caps, data quality caveats).
4. **After making an architectural decision**, add or update a page in `wiki/concepts/` or `wiki/synthesis/` and append a line to `wiki/log.md`. This is the whole point of this vault — don't skip it.
5. **Cost-sensitive services** (Google Places, Gemini) have hard usage caps already configured — see `wiki/entities/google-places-api.md` and `wiki/entities/gemini-api.md` before changing quota logic.
6. **Log rotation is a required end-of-session step, not an occasional cleanup.** This log grew to 692 lines/~36k words before it was first rotated, and one partial read of it cost ~80k tokens — that is the failure mode this rule exists to prevent. `wc -l wiki/log.md` past ~20 lines means: move everything but the current session verbatim to `wiki/log-archive.md`, update the `## Archive` summary bullet at the top of the active log, done in the same session that noticed it, not deferred.

## Why this vault exists

This project is also a portfolio piece demonstrating "AI-scalable, well-documented code" as a service offering. The vault itself is part of the proof — keep it genuinely maintained, not decorative.

## Freshness rule for facts

Every fact written into this vault's `wiki/` must be timeless, dated, or a pointer — never a bare present-tense claim about something that can change (a quota, a cost figure, a status) with no date attached. Full policy: `../wiki/concepts/tech/freshness-and-health.md` in the main vault.

## Working style with Sadri

If Sadri (the project owner) has made or is about to make a decision that looks questionable — technically, financially, or strategically — say so directly and invite debate before going along with it. Don't silently comply just because a decision was already stated. Push back with the specific reason, then let him decide. He asked for this explicitly; agreeing by default is not the helpful default here.
