"""Tests for the pure decision logic in main.py.

`main.py` calls `initialize_app()` at import time, which needs credentials that
do not exist in a test environment — so importing it is not an option. These
tests extract the functions under test from the source instead. That is
deliberate: it keeps the tests running with no Firebase project, no network and
no credentials, at the cost of the extraction helper below.

Scope is the logic that decides what the user sees and what gets spent:
opening-hours evaluation and candidate matching. The parts that talk to Google
are not covered here and are not meant to be — they need the live services.

Run:  python3 -m pytest firebase/functions/test_main.py -v
      (or: python3 firebase/functions/test_main.py)
"""

import datetime
import io
import os
import re
import unittest

_SRC = io.open(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "main.py"),
    encoding="utf-8",
).read()


def _extract(*names: str) -> dict:
    """Pulls named top-level functions out of main.py and executes them in a
    bare namespace, so no module-level Firebase setup runs."""
    ns: dict = {"datetime": datetime}
    for name in names:
        m = re.search(
            rf"^def {name}\(.*?(?=^def |\Z)", _SRC, re.S | re.M
        )
        if m is None:
            raise AssertionError(f"{name} not found in main.py — was it renamed?")
        exec(m.group(0), ns)
    return ns


_ns = _extract("_is_place_open", "_find_matching_candidate", "_parse_price_level")
_is_place_open = _ns["_is_place_open"]
_find_matching_candidate = _ns["_find_matching_candidate"]
_parse_price_level = _ns["_parse_price_level"]


def utc(year, month, day, hour, minute=0):
    return datetime.datetime(year, month, day, hour, minute, tzinfo=datetime.timezone.utc)


# Google Places day numbering: 0 = Sunday ... 6 = Saturday.
SUN, MON, TUE, WED, THU, FRI, SAT = range(7)


def period(open_day, open_hour, close_day, close_hour, open_min=0, close_min=0):
    return {
        "open": {"day": open_day, "hour": open_hour, "minute": open_min},
        "close": {"day": close_day, "hour": close_hour, "minute": close_min},
    }


class IsPlaceOpen(unittest.TestCase):
    """The filter that keeps closed restaurants out of a recommendation.

    Every case pins the clock through `at_time_utc`. Without that these tests
    would pass or fail depending on the hour they happen to run — which is the
    failure mode this function is most likely to have in the first place.
    """

    # 2026-09-14 is a Monday. Jakarta is UTC+7 (utcOffsetMinutes = 420).
    JAKARTA = 420

    def test_open_during_listed_hours(self):
        c = {"periods": [period(MON, 10, MON, 22)], "utcOffsetMinutes": self.JAKARTA}
        # 12:00 UTC = 19:00 Jakarta, inside 10:00-22:00.
        self.assertTrue(_is_place_open(c, utc(2026, 9, 14, 12)))

    def test_closed_before_opening(self):
        c = {"periods": [period(MON, 10, MON, 22)], "utcOffsetMinutes": self.JAKARTA}
        # 01:00 UTC = 08:00 Jakarta, before a 10:00 open.
        self.assertFalse(_is_place_open(c, utc(2026, 9, 14, 1)))

    def test_closed_after_closing(self):
        c = {"periods": [period(MON, 10, MON, 22)], "utcOffsetMinutes": self.JAKARTA}
        # 16:00 UTC = 23:00 Jakarta, after a 22:00 close.
        self.assertFalse(_is_place_open(c, utc(2026, 9, 14, 16)))

    def test_closing_minute_is_exclusive(self):
        """22:00 exactly is closed, not open — the comparison is `< end`."""
        c = {"periods": [period(MON, 10, MON, 22)], "utcOffsetMinutes": self.JAKARTA}
        self.assertFalse(_is_place_open(c, utc(2026, 9, 14, 15)))   # 22:00 local
        self.assertTrue(_is_place_open(c, utc(2026, 9, 14, 14, 59)))  # 21:59 local

    def test_timezone_offset_is_applied(self):
        """The same instant is open in Jakarta and closed in London.

        This is the case the whole `utcOffsetMinutes` handling exists for: the
        candidate cache is shared across a 1km grid but evaluated at query time,
        so the offset has to come from the place, not the server.
        """
        at = utc(2026, 9, 14, 12)  # 19:00 Jakarta, 13:00 London
        jakarta = {"periods": [period(MON, 18, MON, 23)], "utcOffsetMinutes": 420}
        london = {"periods": [period(MON, 18, MON, 23)], "utcOffsetMinutes": 60}
        self.assertTrue(_is_place_open(jakarta, at))
        self.assertFalse(_is_place_open(london, at))

    def test_overnight_hours_wrapping_midnight(self):
        """A bar open Saturday 20:00 to Sunday 03:00 is open at 01:00 Sunday."""
        c = {"periods": [period(SAT, 20, SUN, 3)], "utcOffsetMinutes": self.JAKARTA}
        # 2026-09-19 is a Saturday. 18:00 UTC Sat = 01:00 Sunday Jakarta.
        self.assertTrue(_is_place_open(c, utc(2026, 9, 19, 18)))

    def test_overnight_hours_closed_in_the_gap(self):
        c = {"periods": [period(SAT, 20, SUN, 3)], "utcOffsetMinutes": self.JAKARTA}
        # 08:00 UTC Sat = 15:00 Saturday Jakarta — after Sunday's close, before Saturday's open.
        self.assertFalse(_is_place_open(c, utc(2026, 9, 19, 8)))

    def test_24_7_when_close_spec_missing(self):
        """Google omits `close` for a 24/7 business."""
        c = {"periods": [{"open": {"day": SUN, "hour": 0, "minute": 0}}],
             "utcOffsetMinutes": self.JAKARTA}
        self.assertTrue(_is_place_open(c, utc(2026, 9, 14, 3)))
        self.assertTrue(_is_place_open(c, utc(2026, 9, 17, 20)))

    def test_multiple_periods_split_day(self):
        """Lunch 11-14, dinner 18-22: closed in the afternoon gap."""
        c = {"periods": [period(MON, 11, MON, 14), period(MON, 18, MON, 22)],
             "utcOffsetMinutes": self.JAKARTA}
        self.assertTrue(_is_place_open(c, utc(2026, 9, 14, 5)))    # 12:00 local
        self.assertFalse(_is_place_open(c, utc(2026, 9, 14, 9)))   # 16:00 local
        self.assertTrue(_is_place_open(c, utc(2026, 9, 14, 12)))   # 19:00 local

    def test_wrong_day_is_closed(self):
        """Monday-only hours do not open the place on Tuesday."""
        c = {"periods": [period(MON, 10, MON, 22)], "utcOffsetMinutes": self.JAKARTA}
        self.assertFalse(_is_place_open(c, utc(2026, 9, 15, 5)))  # Tuesday 12:00 local

    def test_unknown_when_no_hours_at_all(self):
        """None, not False — an unlisted warung must stay eligible.

        The backend treats None as "unknown" and keeps such places when open
        options are scarce. Returning False here would silently drop exactly the
        authentic local spots the product is for.
        """
        self.assertIsNone(_is_place_open({}, utc(2026, 9, 14, 12)))
        self.assertIsNone(_is_place_open({"periods": None}, utc(2026, 9, 14, 12)))
        self.assertIsNone(_is_place_open({"periods": []}, utc(2026, 9, 14, 12)))

    def test_openNow_fallback_when_periods_absent(self):
        self.assertTrue(_is_place_open({"openNow": True}, utc(2026, 9, 14, 12)))
        self.assertFalse(_is_place_open({"openNow": False}, utc(2026, 9, 14, 12)))

    def test_periods_win_over_openNow(self):
        """`openNow` is a snapshot from fetch time; periods are evaluated now.

        The 48h cache is why: a cached `openNow: True` goes stale within hours,
        so the periods must take precedence when both are present.
        """
        c = {"periods": [period(MON, 10, MON, 22)],
             "utcOffsetMinutes": self.JAKARTA,
             "openNow": True}
        self.assertFalse(_is_place_open(c, utc(2026, 9, 14, 16)))  # 23:00 local

    def test_malformed_period_is_skipped_not_crashed(self):
        c = {"periods": [{"open": {"day": MON}}, period(MON, 10, MON, 22)],
             "utcOffsetMinutes": self.JAKARTA}
        self.assertTrue(_is_place_open(c, utc(2026, 9, 14, 12)))

    def test_missing_offset_falls_back_to_utc(self):
        c = {"periods": [period(MON, 10, MON, 22)]}
        self.assertTrue(_is_place_open(c, utc(2026, 9, 14, 12)))


class FindMatchingCandidate(unittest.TestCase):
    """Resolving a model's pick back to the candidate it came from.

    This is what lets the prompt carry a short integer id instead of a
    240-character photoRef. If it mis-resolves, the user gets one restaurant's
    name with another's coordinates — so the fallbacks matter as much as the
    happy path.
    """

    def setUp(self):
        self.cands = [
            {"name": f"Resto {i}", "address": f"Street {i}",
             "photoRef": f"places/X/photos/{i}", "photoRefs": [f"places/X/photos/{i}"]}
            for i in range(20)
        ]

    def test_matches_by_id(self):
        self.assertEqual(_find_matching_candidate({"id": 7}, self.cands)["name"], "Resto 7")

    def test_id_zero_is_matched(self):
        """`id: 0` is falsy — a truthiness check here would skip candidate zero."""
        self.assertEqual(_find_matching_candidate({"id": 0}, self.cands)["name"], "Resto 0")

    def test_out_of_range_id_falls_back_to_name(self):
        pick = {"id": 999, "name": "Resto 3"}
        self.assertEqual(_find_matching_candidate(pick, self.cands)["name"], "Resto 3")

    def test_negative_id_falls_back(self):
        pick = {"id": -1, "name": "Resto 4"}
        self.assertEqual(_find_matching_candidate(pick, self.cands)["name"], "Resto 4")

    def test_non_integer_id_falls_back(self):
        pick = {"id": "7", "name": "Resto 5"}
        self.assertEqual(_find_matching_candidate(pick, self.cands)["name"], "Resto 5")

    def test_matches_by_name_case_insensitively(self):
        self.assertEqual(
            _find_matching_candidate({"name": "resto 9"}, self.cands)["name"], "Resto 9")

    def test_matches_by_address_when_name_differs(self):
        pick = {"name": "Totally Different", "address": "Street 11"}
        self.assertEqual(_find_matching_candidate(pick, self.cands)["name"], "Resto 11")

    def test_returns_none_when_nothing_matches(self):
        self.assertIsNone(
            _find_matching_candidate({"name": "Nowhere", "address": "Nothing"}, self.cands))


class ParsePriceLevel(unittest.TestCase):
    """Places returns price level as an int on some paths and an enum string on
    others; the fact row needs 1-4 or nothing."""

    def test_passes_through_valid_integers(self):
        for n in (1, 2, 3, 4):
            self.assertEqual(_parse_price_level(n), n)

    def test_rejects_out_of_range_integers(self):
        self.assertIsNone(_parse_price_level(0))
        self.assertIsNone(_parse_price_level(5))

    def test_handles_missing(self):
        self.assertIsNone(_parse_price_level(None))


if __name__ == "__main__":
    unittest.main(verbosity=2)
