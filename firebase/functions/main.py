# Cloud Function for HungryNow
# Flow: location in -> Places Nearby Search -> one Gemini call -> hero + specialty picks out
# Deploy with `firebase deploy`

import datetime
import hashlib
import json
import time
import uuid
from io import BytesIO
from urllib.parse import quote

import httpx
import requests
from firebase_admin import firestore, initialize_app, storage
from firebase_functions import https_fn, logger
from firebase_functions.options import set_global_options
from firebase_functions.params import SecretParam
from google import genai
from google.genai import errors as genai_errors
from google.genai import types
from PIL import Image

# Hard cap per Gemini attempt - observed failures under sustained overload
# have taken 50-120s+ on Google's side, which would blow the whole retry
# budget on a single attempt if left unbounded.
GEMINI_TIMEOUT_MS = 10_000

# Two models, each with its own separate RPD (requests/day) quota - if the
# primary is exhausted or erroring, falling over to the second effectively
# doubles the daily headroom. Discovered the hard way: gemini-3.6-flash's
# free tier is only 20 RPD, and exceeding it manifests as repeated 503/504
# errors, not a clean 429 - see wiki/entities/gemini-api.md in the vault.
GEMINI_MODELS = ["gemini-3.5-flash-lite", "gemini-3.1-flash-lite"]

# Attempts PER MODEL. Kept low (2, not 5) so trying both models still fits
# safely under the Cloud Function's 60s timeout: 2 models x 2 attempts x 10s
# timeout = 40s worst case, plus backoff and the Places call.
MAX_ATTEMPTS_PER_MODEL = 2

# Hard ceiling on what one call can generate. The response is 1 hero + 2-3
# specialties, each a handful of short fields, which measures well under 1k
# tokens - 2048 is roughly double the worst realistic case, so it bounds a
# runaway generation without ever truncating a legitimate answer.
#
# NOTE: this caps cost PER CALL. It does not keep the project on the free
# tier - free vs pay-as-you-go is decided by whether billing is enabled on
# the API key's Google Cloud project, not by request size.
GEMINI_MAX_OUTPUT_TOKENS = 2048

# Cost control: caps concurrent containers for this function. Must be set
# before any @https_fn.on_request decorator runs (Python evaluates
# decorators at module load time, so this needs to come first).
set_global_options(max_instances=10)

initialize_app()

GEMINI_API_KEY = SecretParam("GEMINI_API_KEY")
PLACES_API_KEY = SecretParam("PLACES_API_KEY")

# Second, code-owned safeguards alongside the Places console quota caps -
# mirror them so a misconfigured/reset console quota still can't run up a bill.
DAILY_REQUEST_LIMIT = 30
DAILY_PHOTO_LIMIT = 33


def _consume_daily_limit(collection: str, limit: int) -> bool:
    """Atomically increments today's usage counter in the given collection.
    Returns False if the daily cap has already been reached (and leaves the
    counter unchanged)."""
    db = firestore.client()
    today = datetime.date.today().isoformat()
    doc_ref = db.collection(collection).document(today)
    transaction = db.transaction()

    @firestore.transactional
    def _run(transaction: firestore.Transaction) -> bool:
        snapshot = doc_ref.get(transaction=transaction)
        current = snapshot.get("count") if snapshot.exists else 0
        if current >= limit:
            return False
        transaction.set(doc_ref, {"count": current + 1})
        return True

    return _run(transaction)


# Shared across ALL users near the same spot, not just repeat visits from one
# device - a tourist rarely revisits the same location twice in a trip, but
# many different users near the same plaza/street all benefit from one fetch.
LOCATION_CACHE_TTL = datetime.timedelta(hours=48)


def _cache_key(lat: float, lng: float) -> str:
    # ~1km grid (2 decimal places), close to the 1.5km search radius already used.
    return f"{round(lat, 2)}_{round(lng, 2)}"


def _get_cached_candidates(lat: float, lng: float) -> list[dict] | None:
    db = firestore.client()
    snapshot = db.collection("location_cache").document(_cache_key(lat, lng)).get()
    if not snapshot.exists:
        return None
    data = snapshot.to_dict()
    fetched_at = data.get("fetchedAt")
    if fetched_at is None or (datetime.datetime.now(datetime.timezone.utc) - fetched_at) > LOCATION_CACHE_TTL:
        return None
    candidates = data.get("candidates")
    if not candidates:
        return None
    # If cached candidates lack coordinates (legacy cache), treat as cache miss so we refresh with coordinates.
    if candidates[0].get("latitude") is None:
        return None
    # If cached candidates lack opening hours data (pre-hours cache), treat as cache miss so we refresh with opening hours.
    if "openNow" not in candidates[0] and "periods" not in candidates[0]:
        return None
    # If cached candidates predate attribution capture, treat as a cache miss so
    # we refresh with credits.
    #
    # This DOES cost one Places call per already-cached location, once. The
    # earlier version skipped this to avoid that cost and let entries age out
    # over 48h instead - which meant every location cached before the change
    # silently served photos with no credit, i.e. the exact compliance failure
    # this work exists to fix, for up to two days. Displaying an uncredited
    # Places photo is a terms violation; a one-off refresh per location is the
    # cheaper of the two. Only entries that HAVE photos are refreshed, so
    # locations with nothing to credit cost nothing.
    if any(c.get("photoRefs") for c in candidates) and not any(
        c.get("photoAttributions") for c in candidates
    ):
        return None
    return candidates


def _cache_candidates(lat: float, lng: float, candidates: list[dict]) -> None:
    db = firestore.client()
    db.collection("location_cache").document(_cache_key(lat, lng)).set({
        "candidates": candidates,
        "fetchedAt": firestore.SERVER_TIMESTAMP,
    })


# The cached value is now OUR OWN Firebase Storage URL (a permanent copy we
# downloaded, compressed, and uploaded ourselves), not Google's short-lived
# photoUri - so a long TTL is safe. Effectively permanent: a given photoRef's
# image never needs re-fetching from Google once cached once.
PHOTO_CACHE_TTL = datetime.timedelta(days=365)


def _photo_cache_key(photo_ref: str) -> str:
    # photoRef contains "/" (e.g. "places/X/photos/Y"), unsafe as a raw
    # Firestore document ID - hash it to a flat, safe key instead.
    return hashlib.sha256(photo_ref.encode()).hexdigest()


def _get_cached_photo(photo_ref: str) -> tuple[str, str | None] | None:
    """Returns (photoUri, attribution) or None on miss/expiry. Attribution may
    be None for entries cached before attribution was stored - those still
    serve the image, and the caller falls back to the candidate record."""
    db = firestore.client()
    snapshot = db.collection("photo_cache").document(_photo_cache_key(photo_ref)).get()
    if not snapshot.exists:
        return None
    data = snapshot.to_dict()
    fetched_at = data.get("fetchedAt")
    if fetched_at is None or (datetime.datetime.now(datetime.timezone.utc) - fetched_at) > PHOTO_CACHE_TTL:
        return None
    photo_uri = data.get("photoUri")
    if photo_uri is None:
        return None
    return photo_uri, data.get("attribution")


def _cache_photo_uri(photo_ref: str, photo_uri: str, attribution: str | None) -> None:
    db = firestore.client()
    db.collection("photo_cache").document(_photo_cache_key(photo_ref)).set({
        "photoUri": photo_uri,
        "photoRef": photo_ref,
        "attribution": attribution,
        "fetchedAt": firestore.SERVER_TIMESTAMP,
    })


PHOTO_MAX_WIDTH_PX = 800
WEBP_QUALITY = 82


def _compress_to_webp(image_bytes: bytes) -> bytes:
    image = Image.open(BytesIO(image_bytes))
    if image.mode in ("RGBA", "P"):
        image = image.convert("RGB")
    output = BytesIO()
    image.save(output, format="WEBP", quality=WEBP_QUALITY)
    return output.getvalue()


def _upload_photo_to_storage(cache_key: str, data: bytes) -> str:
    """Uploads to Firebase Storage and returns a permanent, keyless, public
    download URL (Firebase's own token-based URL scheme - works regardless
    of the bucket's IAM/ACL configuration)."""
    bucket = storage.bucket()
    path = f"photos/{cache_key}.webp"
    blob = bucket.blob(path)
    token = str(uuid.uuid4())
    blob.metadata = {"firebaseStorageDownloadTokens": token}
    blob.upload_from_string(data, content_type="image/webp")
    encoded_path = quote(path, safe="")
    return f"https://firebasestorage.googleapis.com/v0/b/{bucket.name}/o/{encoded_path}?alt=media&token={token}"

PLACES_FIELD_MASK = ",".join([
    "places.id",
    "places.displayName",
    "places.formattedAddress",
    "places.location",
    "places.primaryType",
    "places.rating",
    "places.userRatingCount",
    "places.priceLevel",
    "places.nationalPhoneNumber",
    "places.photos",
    "places.currentOpeningHours",
    "places.regularOpeningHours",
    "places.utcOffsetMinutes",
])

RESPONSE_SCHEMA = {
    "type": "object",
    "properties": {
        "hero": {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "address": {"type": "string"},
                "phone": {"type": "string", "nullable": True},
                "reason": {"type": "string"},
                "description": {"type": "string"},
                "foodCategory": {"type": "string"},
                "id": {"type": "integer", "nullable": True},
            },
            "required": ["name", "address", "reason", "description", "foodCategory"],
        },
        "specialties": {
            "type": "array",
            "minItems": 2,
            "maxItems": 3,
            "items": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "address": {"type": "string"},
                    "phone": {"type": "string", "nullable": True},
                    "reason": {"type": "string"},
                    "description": {"type": "string"},
                    "foodCategory": {"type": "string"},
                    "id": {"type": "integer", "nullable": True},
                },
                "required": ["name", "address", "reason", "description", "foodCategory"],
            },
        },
    },
    "required": ["hero", "specialties"],
}


def _error(message: str, status: int) -> https_fn.Response:
    return https_fn.Response(
        json.dumps({"error": message}),
        status=status,
        mimetype="application/json",
    )


def _parse_price_level(price_level) -> int | None:
    if isinstance(price_level, int) and 1 <= price_level <= 4:
        return price_level
    if isinstance(price_level, str):
        mapping = {
            "PRICE_LEVEL_FREE": 1,
            "PRICE_LEVEL_INEXPENSIVE": 1,
            "PRICE_LEVEL_MODERATE": 2,
            "PRICE_LEVEL_EXPENSIVE": 3,
            "PRICE_LEVEL_VERY_EXPENSIVE": 4,
        }
        return mapping.get(price_level)
    return None


def _fetch_nearby_candidates(lat: float, lng: float, places_key: str) -> list[dict]:
    response = requests.post(
        "https://places.googleapis.com/v1/places:searchNearby",
        headers={
            "Content-Type": "application/json",
            "X-Goog-Api-Key": places_key,
            "X-Goog-FieldMask": PLACES_FIELD_MASK,
        },
        json={
            "includedTypes": ["restaurant"],
            "maxResultCount": 20,
            "locationRestriction": {
                "circle": {
                    "center": {"latitude": lat, "longitude": lng},
                    "radius": 1500.0,
                }
            },
        },
        timeout=10,
    )
    response.raise_for_status()
    places = response.json().get("places", [])

    def _photo_refs(place: dict) -> list[str]:
        photos = place.get("photos") or []
        return [p.get("name") for p in photos if p.get("name")]

    def _photo_attributions(place: dict) -> dict[str, str]:
        """Maps each photoRef to its author credit. Google requires the
        attribution be displayed wherever the photo is - we keep it beside
        the ref so it travels through the cache with it and get_photo can
        return it without a second Places call."""
        out = {}
        for p in place.get("photos") or []:
            ref = p.get("name")
            if not ref:
                continue
            authors = p.get("authorAttributions") or []
            name = (authors[0].get("displayName") or "").strip() if authors else ""
            if name:
                out[ref] = name
        return out

    candidates = []
    for place in places:
        loc = place.get("location") or {}
        refs = _photo_refs(place)
        attributions = _photo_attributions(place)
        current_hours = place.get("currentOpeningHours") or {}
        regular_hours = place.get("regularOpeningHours") or {}
        open_now = current_hours.get("openNow")
        periods = regular_hours.get("periods") or current_hours.get("periods")
        utc_offset = place.get("utcOffsetMinutes")

        candidates.append({
            "id": place.get("id"),
            "name": place.get("displayName", {}).get("text", "Unknown"),
            "address": place.get("formattedAddress", ""),
            "latitude": loc.get("latitude"),
            "longitude": loc.get("longitude"),
            "rating": place.get("rating"),
            "ratingCount": place.get("userRatingCount"),
            "priceLevel": _parse_price_level(place.get("priceLevel")),
            "type": place.get("primaryType"),
            "phone": place.get("nationalPhoneNumber"),
            "photoRef": refs[0] if refs else None,
            "photoRefs": refs[:3] if refs else None,
            "photoAttributions": attributions or None,
            "openNow": open_now,
            "periods": periods,
            "utcOffsetMinutes": utc_offset,
        })
    return candidates


def _is_place_open(candidate: dict, at_time_utc: datetime.datetime | None = None) -> bool | None:
    """Determines if a candidate restaurant is currently open.
    Returns:
      True: Confirmed open at the evaluated time.
      False: Confirmed closed at the evaluated time.
      None: Hours unknown / not provided in Google Places.
    """
    periods = candidate.get("periods")
    utc_offset = candidate.get("utcOffsetMinutes")

    if periods and isinstance(periods, list):
        now_utc = at_time_utc or datetime.datetime.now(datetime.timezone.utc)
        if utc_offset is not None:
            local_dt = now_utc + datetime.timedelta(minutes=utc_offset)
        else:
            local_dt = now_utc

        # Google Places day: 0 = Sunday, 1 = Monday, ..., 6 = Saturday.
        # Python weekday(): 0 = Monday, ..., 6 = Sunday.
        current_day = (local_dt.weekday() + 1) % 7
        current_min_of_week = current_day * 1440 + local_dt.hour * 60 + local_dt.minute

        for p in periods:
            open_spec = p.get("open")
            if not open_spec or "day" not in open_spec or "hour" not in open_spec:
                continue
            close_spec = p.get("close")
            if not close_spec or "day" not in close_spec or "hour" not in close_spec:
                # Missing close spec indicates 24/7 business
                return True

            start_min = open_spec["day"] * 1440 + open_spec["hour"] * 60 + open_spec.get("minute", 0)
            end_min = close_spec["day"] * 1440 + close_spec["hour"] * 60 + close_spec.get("minute", 0)

            if end_min > start_min:
                if start_min <= current_min_of_week < end_min:
                    return True
            else:
                # Wraps around Sunday midnight (e.g. Saturday 20:00 to Sunday 03:00)
                if current_min_of_week >= start_min or current_min_of_week < end_min:
                    return True

        return False

    # Fallback to currentOpeningHours.openNow if periods were absent
    if candidate.get("openNow") is not None:
        return bool(candidate["openNow"])

    return None


def _pick_recommendations(candidates: list[dict], gemini_key: str) -> dict:
    client = genai.Client(api_key=gemini_key)

    # Sanitize candidates to keep the prompt concise: drop the bulky periods arrays,
    # and send a short integer `id` in place of the photoRef.
    #
    # A photoRef is ~240 characters of opaque Google identifier - across 20 candidates
    # that was ~1,200 tokens, roughly 43% of the prompt, spent on a string the model
    # cannot reason about and only ever copies back verbatim. An index does the same
    # job in 1-2 characters. `_find_matching_candidate` resolves the pick back to its
    # candidate (and therefore its real photoRef) by id first, then name/address.
    gemini_candidates = []
    for idx, c in enumerate(candidates):
        is_open = _is_place_open(c)
        gemini_candidates.append({
            "id": idx,
            "name": c.get("name"),
            "address": c.get("address"),
            "rating": c.get("rating"),
            "ratingCount": c.get("ratingCount"),
            "priceLevel": c.get("priceLevel"),
            "type": c.get("type"),
            "phone": c.get("phone"),
            "isOpenNow": is_open if is_open is not None else "unknown",
        })

    prompt = (
        "You are picking restaurants for a tourist who is hungry right NOW and unfamiliar with the local food scene. "
        "From the candidate list below, choose exactly one 'hero' pick (the single best-value "
        "option overall, weighing rating, price level, and review count) and 2-3 'specialty' "
        "picks. The hero and every specialty pick must be different restaurants - never "
        "repeat the hero's restaurant in the specialties list. Each specialty must be a "
        "place known for one specific, iconic dish or cuisine (e.g. ramen, sushi, takoyaki, "
        "satay) - not a generic 'restaurant' category - and each specialty must specialize "
        "in a different dish from the others. "
        "CRITICAL REQUIREMENT: The user is hungry now, so you MUST only pick restaurants that "
        "are currently open (isOpenNow is True or 'unknown'). Never pick a restaurant where isOpenNow is False unless "
        "no open restaurants exist in the list. "
        "Only choose from the list below - never invent "
        "a restaurant, address, or fact not present in the data. Keep each reason to one "
        "short sentence. For each pick, also write a 'description' (1-2 sentences) "
        "introducing the place to the tourist - base it only on the category, price level, "
        "rating, and review count already given; do not invent specific menu items, "
        "history, or details not present in the data. Copy the 'phone' field verbatim from "
        "the candidate data if present, or output null if the candidate has no phone number "
        "- never invent a phone number. For every pick (hero and each specialty), also set "
        "'foodCategory' to the one specific dish/cuisine it specializes in (e.g. 'Ramen', "
        "'Sushi', 'Takoyaki') - short, 1-3 words. For every pick (hero and each specialty), "
        "set 'id' to the integer 'id' of the candidate you chose, copied exactly from the "
        "candidate data - never invent an id and never reuse one.\n\n"
        f"Candidates:\n{json.dumps(gemini_candidates, ensure_ascii=False)}"
    )

    last_error: Exception | None = None
    for model in GEMINI_MODELS:
        for attempt in range(MAX_ATTEMPTS_PER_MODEL):
            is_last_attempt_for_model = attempt == MAX_ATTEMPTS_PER_MODEL - 1
            try:
                response = client.models.generate_content(
                    model=model,
                    contents=prompt,
                    config=types.GenerateContentConfig(
                        response_mime_type="application/json",
                        response_schema=RESPONSE_SCHEMA,
                        max_output_tokens=GEMINI_MAX_OUTPUT_TOKENS,
                        http_options=types.HttpOptions(timeout=GEMINI_TIMEOUT_MS),
                    ),
                )
                # Log real usage so prompt growth is visible in Cloud Logging rather
                # than guessed at. `usage_metadata` is the authoritative count.
                usage = getattr(response, "usage_metadata", None)
                if usage is not None:
                    logger.info(
                        f"gemini_usage model={model} "
                        f"prompt={getattr(usage, 'prompt_token_count', '?')} "
                        f"output={getattr(usage, 'candidates_token_count', '?')} "
                        f"total={getattr(usage, 'total_token_count', '?')}"
                    )
                return json.loads(response.text)
            except genai_errors.ClientError as e:
                # 429 means today's quota for THIS model is gone - retrying
                # the same model is pointless, move straight to the next one.
                last_error = e
                logger.warn(f"gemini_rate_limited model={model} code={e.code}")
                break
            except genai_errors.ServerError as e:
                # ServerError only ever covers Google's own 5xx transient
                # errors (500/502/503/504) - all worth retrying the same way.
                last_error = e
                if is_last_attempt_for_model:
                    break
                delay = min(2**attempt, 8)
                logger.warn(f"gemini_server_error_retry model={model} attempt={attempt + 1} code={e.code} delay={delay}s")
                time.sleep(delay)
            except httpx.TimeoutException as e:
                last_error = e
                if is_last_attempt_for_model:
                    break
                delay = min(2**attempt, 8)
                logger.warn(f"gemini_timeout_retry model={model} attempt={attempt + 1} delay={delay}s")
                time.sleep(delay)
    raise last_error


def _find_matching_candidate(pick: dict, candidates: list[dict]) -> dict | None:
    # 0. Match by the integer id the model was given. Unambiguous when present, and the
    #    reason photoRefs no longer need to travel through the prompt at all. Guarded
    #    rather than trusted: the model can still emit an out-of-range or non-integer id,
    #    in which case we fall through to the name/address matching below.
    pick_id = pick.get("id")
    if isinstance(pick_id, int) and 0 <= pick_id < len(candidates):
        return candidates[pick_id]

    pick_photo = pick.get("photoRef")
    pick_name = (pick.get("name") or "").strip().lower()
    pick_address = (pick.get("address") or "").strip().lower()

    # 1. Match by photoRef if present
    if pick_photo:
        for c in candidates:
            if c.get("photoRef") == pick_photo or pick_photo in (c.get("photoRefs") or []):
                return c

    # 2. Exact match by name
    if pick_name:
        for c in candidates:
            c_name = (c.get("name") or "").strip().lower()
            if c_name == pick_name:
                return c

    # 3. Substring match by name - LONGEST match wins, not the first found.
    #
    # Scanning in order and returning the first hit picks the wrong restaurant
    # whenever one name contains another: "Warung Nasi Padang" matches inside
    # "Warung Nasi Padang Sederhana", so whichever sits earlier in the candidate
    # list wins regardless of which the model meant. The longest overlap is the
    # better guess, and ties keep list order.
    if pick_name:
        best = None
        best_len = 0
        for c in candidates:
            c_name = (c.get("name") or "").strip().lower()
            if c_name and (c_name in pick_name or pick_name in c_name):
                if len(c_name) > best_len:
                    best, best_len = c, len(c_name)
        if best is not None:
            return best

    # 4. Match by address - same rule, same reason ("Street 1" is inside "Street 11").
    if pick_address:
        best = None
        best_len = 0
        for c in candidates:
            c_addr = (c.get("address") or "").strip().lower()
            if c_addr and (c_addr in pick_address or pick_address in c_addr):
                if len(c_addr) > best_len:
                    best, best_len = c, len(c_addr)
        if best is not None:
            return best

    return None


def _enrich_hero(hero: dict, candidates: list[dict]) -> dict:
    matched = _find_matching_candidate(hero, candidates)
    if matched:
        if hero.get("latitude") is None:
            hero["latitude"] = matched.get("latitude")
        if hero.get("longitude") is None:
            hero["longitude"] = matched.get("longitude")
        if hero.get("placeId") is None:
            hero["placeId"] = matched.get("id")
        if hero.get("rating") is None:
            hero["rating"] = matched.get("rating")
        if hero.get("ratingCount") is None:
            hero["ratingCount"] = matched.get("ratingCount")
        if hero.get("priceLevel") is None:
            hero["priceLevel"] = matched.get("priceLevel")
        if hero.get("photoRefs") is None and matched.get("photoRefs"):
            hero["photoRefs"] = matched.get("photoRefs")
        # Google requires each photo's credit be displayed. Send one entry per
        # ref, index-aligned with photoRefs, so a three-photo carousel can
        # credit each slide separately. None where the photo has no author.
        if hero.get("photoAttributions") is None:
            refs = hero.get("photoRefs") or ([hero["photoRef"]] if hero.get("photoRef") else [])
            by_ref = matched.get("photoAttributions") or {}
            if refs and by_ref:
                hero["photoAttributions"] = [by_ref.get(r) for r in refs]
        if hero.get("openNow") is None and matched.get("openNow") is not None:
            hero["openNow"] = matched.get("openNow")
    return hero


def _enrich_specialty(specialty: dict, candidates: list[dict]) -> dict:
    matched = _find_matching_candidate(specialty, candidates)
    if matched:
        if specialty.get("latitude") is None:
            specialty["latitude"] = matched.get("latitude")
        if specialty.get("longitude") is None:
            specialty["longitude"] = matched.get("longitude")
        if specialty.get("placeId") is None:
            specialty["placeId"] = matched.get("id")
        if specialty.get("rating") is None:
            specialty["rating"] = matched.get("rating")
        if specialty.get("ratingCount") is None:
            specialty["ratingCount"] = matched.get("ratingCount")
        if specialty.get("priceLevel") is None:
            specialty["priceLevel"] = matched.get("priceLevel")
        if specialty.get("openNow") is None and matched.get("openNow") is not None:
            specialty["openNow"] = matched.get("openNow")
    return specialty


@https_fn.on_request(secrets=[GEMINI_API_KEY, PLACES_API_KEY])
def get_recommendation(req: https_fn.Request) -> https_fn.Response:
    body = req.get_json(silent=True) or {}
    lat = body.get("latitude")
    lng = body.get("longitude")
    if lat is None or lng is None:
        return _error("missing_location", 400)

    candidates = _get_cached_candidates(lat, lng)
    if candidates is None:
        # Real cache miss - this is the only path that spends Places quota.
        if not _consume_daily_limit("usage_counters", DAILY_REQUEST_LIMIT):
            return _error("daily_limit_reached", 429)

        try:
            candidates = _fetch_nearby_candidates(lat, lng, PLACES_API_KEY.value)
        except requests.RequestException as e:
            body = e.response.text if e.response is not None else str(e)
            logger.error(f"places_lookup_failed: {body}")
            return _error("places_lookup_failed", 502)

        if not candidates:
            return _error("no_results", 404)

        _cache_candidates(lat, lng, candidates)

    # Filter candidates by opening hours:
    open_candidates = []
    unknown_candidates = []
    closed_candidates = []

    for c in candidates:
        status = _is_place_open(c)
        if status is True:
            open_candidates.append(c)
        elif status is None:
            unknown_candidates.append(c)
        else:
            closed_candidates.append(c)

    # Need at least 3 candidates (1 hero + 2 specialties)
    if len(open_candidates) >= 4:
        # Plenty of verified open spots: strictly filter out all closed and unknown places
        active_candidates = open_candidates
    elif len(open_candidates) + len(unknown_candidates) >= 3:
        # Include verified open places plus unknown places (e.g. authentic warungs without listed Google hours)
        active_candidates = open_candidates + unknown_candidates
    else:
        # Late-night / off-hours fallback: include closed candidates (open prioritized first)
        active_candidates = open_candidates + unknown_candidates + closed_candidates

    try:
        result = _pick_recommendations(active_candidates, GEMINI_API_KEY.value)
    except Exception as e:
        logger.error(f"recommendation_failed: {e}")
        return _error("recommendation_failed", 502)

    if isinstance(result, dict):
        if "hero" in result:
            result["hero"] = _enrich_hero(result["hero"], candidates)
        if "specialties" in result and isinstance(result["specialties"], list):
            result["specialties"] = [_enrich_specialty(s, candidates) for s in result["specialties"]]

    return https_fn.Response(
        json.dumps(result),
        status=200,
        mimetype="application/json",
    )


@https_fn.on_request(secrets=[PLACES_API_KEY])
def get_photo(req: https_fn.Request) -> https_fn.Response:
    """Lazily resolves a hero pick's photoRef to a public, keyless image URL.
    Called only when the user taps into the hero restaurant - never eagerly.
    Falls back to a 429 when the separate photo daily cap is hit, so the app
    can show a bundled generic category image instead."""
    photo_ref = req.args.get("photoRef") or (req.get_json(silent=True) or {}).get("photoRef")
    if not photo_ref:
        return _error("missing_photo_ref", 400)

    # The client passes the attribution it already received with the
    # recommendation. We never re-query Places for it: a Place Details lookup
    # just to fetch a credit line would spend quota on every photo tap.
    client_attribution = req.args.get("attribution") or (req.get_json(silent=True) or {}).get("attribution")

    cached = _get_cached_photo(photo_ref)
    if cached is not None:
        photo_uri, attribution = cached
        # Backfill a pre-attribution cache entry rather than refetching the image.
        if attribution is None and client_attribution:
            attribution = client_attribution
            _cache_photo_uri(photo_ref, photo_uri, attribution)
    else:
        photo_uri = None
        attribution = client_attribution

    if photo_uri is None:
        # Real cache miss - this is the only path that spends photo quota.
        if not _consume_daily_limit("photo_usage_counters", DAILY_PHOTO_LIMIT):
            return _error("photo_limit_reached", 429)

        try:
            # No skipHttpRedirect here - we want requests to follow the
            # redirect and hand us the actual image bytes directly.
            response = requests.get(
                f"https://places.googleapis.com/v1/{photo_ref}/media",
                params={
                    "maxWidthPx": PHOTO_MAX_WIDTH_PX,
                    "key": PLACES_API_KEY.value,
                },
                timeout=15,
            )
            response.raise_for_status()
        except requests.RequestException as e:
            body = e.response.text if e.response is not None else str(e)
            logger.error(f"photo_fetch_failed: {body}")
            return _error("photo_fetch_failed", 502)

        try:
            compressed = _compress_to_webp(response.content)
            photo_uri = _upload_photo_to_storage(_photo_cache_key(photo_ref), compressed)
        except Exception as e:
            logger.error(f"photo_compress_upload_failed: {e}")
            return _error("photo_fetch_failed", 502)

        _cache_photo_uri(photo_ref, photo_uri, attribution)

    return https_fn.Response(
        json.dumps({"photoUri": photo_uri, "attribution": attribution}),
        status=200,
        mimetype="application/json",
    )
