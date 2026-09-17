# Mockup review — the judgment calls (2026-09-07)

Unprocessed. From a full review of the nine screens in `output/mockups/index.html`. The defects and the drift went straight onto `checklist.md` under "From the mockup review — 2026-09-07"; these four are taste or product calls that need Sadri's decision before they become work, or before they get dropped.

Each one is written as *the argument*, not as a conclusion — the point is to be able to disagree with it later and see what was actually claimed.

---

## 1. "Here's the one we'd send you to." — the "we" on the app's most important line

**Where:** screen 06, `.hero-lead`. The peak moment of the whole product.

**The case against it.** The CSS comment above that line makes the correct observation — `apple-hig.md` → Writing is wary of "we" because the referent goes vague — and then uses "we'd" anyway, on the grounds that chrome shouldn't have a personality but a recommendation can. The second half of that is right. The problem is that the referent really is vague here, and vague in a way that matters: *who* would send me there? The app? Sadri? Locals? The model? A recommendation app's single credibility line is a bad place for the reader to have to guess who is vouching.

**Alternatives that keep the warmth and lose the referent:** `Here's the one.` / `This is the one.` Both are sentence case, one full stop, no superlative, no quality claim the app can't substantiate — same tests the current line passes. Neither introduces a speaker.

**The case for keeping it.** "we'd" is warmer than either alternative, and warmth at the peak moment is a stated product goal. If the answer is that the vagueness is acceptable because nobody reads it that closely, that's a legitimate call — but it should be the recorded reason, rather than the HIG note sitting in the CSS unresolved.

**Status:** unresolved. My recommendation is `Here's the one.`

---

## 2. Screens 04 and 05 now share a silhouette

**Where:** screen 04 (illustration centred on `.softbg`, label under it, pill at the bottom) and screen 05 (radar centred on the same `.softbg`, stage list under it, ghost button at the bottom).

This is structurally the same repetition that was diagnosed and fixed between 02 and 04 — and fixed *well*, by changing structure rather than swapping art. So the same diagnosis applies here on its face.

**But the two cases are not equivalent, and the difference cuts the other way.** 02 and 04 are separated by the system permission alert and are not visually adjacent in use. 04 and 05 are consecutive, and 05 is what 04 *becomes* when you tap the button. A shared silhouette across a transition is continuity, not repetition: the illustration can plausibly morph into the radar, and keeping the ground identical is what makes that read as one motion instead of a screen change.

**So this may already be right by accident.** The thing worth deciding is whether it's deliberate — because if it is, it has consequences: the illustration and the radar should be sized and centred to the *same* box so the transition lands, and the `.big` question and the stage list should occupy the same vertical band. Right now they roughly do, but by coincidence rather than by rule, which is the kind of thing that drifts.

**Status:** needs a decision, not a fix. Two outcomes: (a) declare it continuity and write the shared-geometry rule down, or (b) declare it repetition and differentiate 05 structurally the way 02 was.

---

## 3. Screen 07 says the same thing twice

**Where:** the `.state-chip.off` reads "Location off"; the `.state-headline` about 40px below it reads "Location is turned off".

The chip is meant to be glanceable status that persists across screens. On this one screen it's a duplicate of the headline, so it stops being status and becomes redundancy at the exact moment the user is confused.

**Two ways out.** Drop the chip on 07 only — defensible, since the headline already carries the state and the chip's job (context for the answer) is moot when there's no answer. Or keep the chip as the status and make the headline do different work: name the *consequence* rather than the state, e.g. "HungryNow can't see where you are". The second is better if the chip is going to be load-bearing everywhere else, because a bar element that vanishes on one screen is its own inconsistency.

**Status:** minor, low risk either way. Mild preference for keeping the chip and rewording the headline.

---

## 4. What the review did *not* find, which is worth recording

No new problems in the app bar unification, the `.softbg` sharing, the accent-reservation rule, the full-bleed separator mechanics, or the contrast/hairline reasoning on screen 02. Those held up under the review, including the parts that were argued about most on the day they were built. The `reference-adoption.md` reject table also held — nothing in the mockups has quietly drifted back toward a banned technique (no gradients outside the two sanctioned motion cues, no glass, no shadows on cards).

Recording this because a review that only lists faults gives a false picture of where the design actually stands, and because "the parts that were fought over are the parts that survived" is a useful thing to know about this project's process.

---

## Housekeeping done in the same pass

`checklist.md` had the "reword `visual-identity.md`'s colour-alone-signals line" item twice, once with the rationale and once with the replacement wording. Merged into one line carrying both.
