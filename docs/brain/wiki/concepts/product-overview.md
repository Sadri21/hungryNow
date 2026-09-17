# Product Overview

**Positioning:** an AI companion for tourists who don't know the local food scene where they are right now.

**Core flow:** one screen, one button ("I'm Hungry"). Location → backend → one Gemini call returns a hero best-value pick with a reason, plus 2-3 "specialty" picks from the same candidate list. No login, no search bar, no long list — this is a decision tool, not a directory.

**Specialty picks, precisely defined:** each specialty must be a *different* restaurant from the hero pick (never the same place twice), and each must specialize in one specific, iconic dish or cuisine type (e.g. ramen, sushi, takoyaki, satay) rather than being a generic "restaurant" - the point is showing the tourist a few distinct food experiences nearby, not restating the hero's category. Each specialty carries a short `foodCategory` label (e.g. "Ramen") for this reason.

**Why it's being built:** primarily a portfolio piece proving "AI feature integration for mobile apps" for freelance work (Fiverr). Secondary possibility: a real product later, not planned for now.

**Known close competitors (validated, not an empty market):** NearbyGem and Foodi ship the one-tap AI pick idea; Mamakoo and GetOutTrip ship the local-specialty-discovery idea. Nobody found combines both this minimally — frame this as "a take on the pattern," not "nothing like this exists."

**Full business plan:** see `HungryNow-MVP-Business-Plan.md` in the project root for the complete plan, timeline, and limitations.
