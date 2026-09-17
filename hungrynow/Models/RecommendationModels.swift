import Foundation
import UIKit

struct RecommendationResponse: Decodable {
    let hero: HeroPick
    let specialties: [SpecialtyPick]
}

/// The one best-value pick.
///
/// A separate type from `SpecialtyPick` on purpose — `hero` is a single object, not a
/// one-element array, and it carries photo and place fields the specialties never do.
struct HeroPick: Decodable {
    let name, address, reason, description, foodCategory: String
    let phone, photoRef: String?

    // MARK: - Passthrough fields the backend does not return YET
    //
    // All optional, so they decode to nil against today's response and light up the
    // moment `RESPONSE_SCHEMA` passes them through — no client change, no migration.
    // Every one of them already comes back from Places Nearby Search in the Cloud
    // Function and is simply dropped before the response is built; see the vault's
    // `api-contract.md` -> "Fields the UI needs and the response doesn't have".
    //
    // Modelled now rather than later because screen 06 is built around them: without
    // these, its primary action (Directions) cannot work and two thirds of its fact row
    // has no data. Adding them here is what makes that a backend task rather than a
    // second pass over the UI.

    /// Google Place ID — the unambiguous Maps deep link (`query_place_id`), and the one
    /// piece of Places content Google permits storing indefinitely.
    let placeId: String?

    /// **Directions and the distance both depend on these.** A deep link built from
    /// `name` + `address` makes the nav app re-geocode a text query, which for a chain
    /// lands people at the wrong branch — worse than no button at all.
    let latitude, longitude: Double?

    /// 1...5, one decimal. The fact row's RATING column.
    let rating: Double?

    /// Google's `userRatingCount` (total number of reviews).
    let ratingCount: Int?

    /// Google's `price_level`, 1...4. The fact row's PRICE column.
    ///
    /// **This gap is not written down anywhere else.** `api-contract.md`'s table of
    /// missing fields lists `latitude`, `longitude`, `placeId` and `rating` but not price,
    /// and screen 06's own callout says only that the distance and rating are absent — so
    /// the fact row is missing all three of its columns while the notes account for two.
    let priceLevel: Int?

    /// Photos for the hero, in display order.
    ///
    /// **Fetch lazily.** `get_photo` is metered against `DAILY_PHOTO_LIMIT` (33), so
    /// eagerly fetching three cuts the day from 33 results to 11. Slide 1 comes with the
    /// result; slides 2-3 only when someone actually swipes, and most people never will.
    ///
    /// Order is NOT the order Places returns: slides should alternate kind (exterior,
    /// food, wide view) because two frames of the same facade side by side read as a
    /// duplicate-image bug. That sort belongs in the Cloud Function.
    let photoRefs: [String]?

    /// One credit per entry in `photoRefs`, **index-aligned with it** — `nil` where that
    /// photo has no named author.
    ///
    /// Google requires each photo's attribution be displayed, and the three slides are
    /// three different people's photos, so a single line on the card is wrong. The
    /// backend sends this with the recommendation so the credit is in hand before the
    /// image is: `get_photo` is the only metered call, and it must not be spent just to
    /// learn who took the picture.
    let photoAttributions: [String?]?

    /// The credit for one slide, or `nil` if there is none for it.
    ///
    /// Tolerates a short or absent array rather than trusting it to match `photoRefs` —
    /// a mismatch would otherwise crash on a subscript, and a missing credit line is a
    /// compliance problem while a crash is a broken app.
    func attribution(at index: Int) -> String? {
        guard let photoAttributions, photoAttributions.indices.contains(index) else { return nil }
        return photoAttributions[index]
    }

    init(
        name: String,
        address: String,
        reason: String,
        description: String,
        foodCategory: String,
        phone: String? = nil,
        photoRef: String? = nil,
        placeId: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        rating: Double? = nil,
        ratingCount: Int? = nil,
        priceLevel: Int? = nil,
        photoRefs: [String]? = nil,
        photoAttributions: [String?]? = nil
    ) {
        self.name = name
        self.address = address
        self.reason = reason
        self.description = description
        self.foodCategory = foodCategory
        self.phone = phone
        self.photoRef = photoRef
        self.placeId = placeId
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
        self.ratingCount = ratingCount
        self.priceLevel = priceLevel
        self.photoRefs = photoRefs
        self.photoAttributions = photoAttributions
    }
}

struct SpecialtyPick: Decodable {
    let name, address, reason, description, foodCategory: String
    let phone: String?

    /// Google Place ID
    let placeId: String?

    /// Coordinates
    let latitude, longitude: Double?

    /// 1...5, one decimal.
    let rating: Double?

    /// Google's `userRatingCount` (total number of reviews).
    let ratingCount: Int?

    /// Google's `price_level`, 1...4.
    let priceLevel: Int?

    init(
        name: String,
        address: String,
        reason: String,
        description: String,
        foodCategory: String,
        phone: String? = nil,
        placeId: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        rating: Double? = nil,
        ratingCount: Int? = nil,
        priceLevel: Int? = nil
    ) {
        self.name = name
        self.address = address
        self.reason = reason
        self.description = description
        self.foodCategory = foodCategory
        self.phone = phone
        self.placeId = placeId
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
        self.ratingCount = ratingCount
        self.priceLevel = priceLevel
    }
}

struct PhotoResponse: Decodable {
    let photoUri: String

    /// Google **requires** photo attributions be displayed.
    ///
    /// `get_photo` echoes back whatever the client sent it, and falls back to whatever it
    /// cached for that ref. It is NOT an independent source: the backend deliberately
    /// never re-queries Places for a credit line, because that would be a Place Details
    /// call on every photo tap. Treat `HeroPick.photoAttributions` as the primary source
    /// and this as the fallback — see `loadHeroPhoto(at:of:)`.
    let attribution: String?
}

struct APIErrorResponse: Decodable {
    let error: String
}

/// One loaded carousel slide.
///
/// The attribution travels WITH the photo rather than being a single line on the card:
/// Google requires each photo's attributions be displayed, and three photos means three
/// different credits, so one static line was defensible with one photo and is wrong with
/// three.
struct HeroPhoto {
    let url: URL
    let attribution: String?
    var image: UIImage? = nil
    var detectedStatusBarStyle: UIStatusBarStyle? = nil
}

/// A unified item model for Screen 06A (Place Details), representing either the hero
/// pick or a specialty pick for navigation and presentation.
struct PlaceDetailItem: Identifiable, Hashable {
    var id: String { placeId ?? name }
    let name: String
    let address: String
    let reason: String
    let description: String
    let foodCategory: String
    let phone: String?
    let placeId: String?
    let latitude: Double?
    let longitude: Double?
    let rating: Double?
    let ratingCount: Int?
    let priceLevel: Int?
    let photoURLs: [URL]

    /// One credit per entry in `photoURLs`, index-aligned, `nil` where unknown.
    ///
    /// Was a single `String?` taken from slide 1, which credited every photo in the
    /// carousel to the first photo's author — wrong, and the kind of wrong Google's
    /// attribution requirement exists to prevent. Nothing rendered it yet, so this is a
    /// latent bug fixed before it shipped rather than one observed.
    let photoAttributions: [String?]

    /// The credit for one photo, or `nil`. Bounds-safe.
    func photoAttribution(at index: Int) -> String? {
        guard photoAttributions.indices.contains(index) else { return nil }
        return photoAttributions[index]
    }

    let isHero: Bool

    init(
        name: String,
        address: String,
        reason: String,
        description: String,
        foodCategory: String,
        phone: String? = nil,
        placeId: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        rating: Double? = nil,
        ratingCount: Int? = nil,
        priceLevel: Int? = nil,
        photoURLs: [URL] = [],
        photoAttributions: [String?] = [],
        isHero: Bool = false
    ) {
        self.name = name
        self.address = address
        self.reason = reason
        self.description = description
        self.foodCategory = foodCategory
        self.phone = phone
        self.placeId = placeId
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
        self.ratingCount = ratingCount
        self.priceLevel = priceLevel
        self.photoURLs = photoURLs
        self.photoAttributions = photoAttributions
        self.isHero = isHero
    }

    init(hero: HeroPick, photos: [HeroPhoto] = []) {
        self.name = hero.name
        self.address = hero.address
        self.reason = hero.reason
        self.description = hero.description
        self.foodCategory = hero.foodCategory
        self.phone = hero.phone
        self.placeId = hero.placeId
        self.latitude = hero.latitude
        self.longitude = hero.longitude
        self.rating = hero.rating
        self.ratingCount = hero.ratingCount
        self.priceLevel = hero.priceLevel
        self.photoURLs = photos.map(\.url)
        self.photoAttributions = photos.map(\.attribution)
        self.isHero = true
    }

    init(specialty: SpecialtyPick) {
        self.name = specialty.name
        self.address = specialty.address
        self.reason = specialty.reason.isEmpty ? specialty.description : specialty.reason
        self.description = specialty.description
        self.foodCategory = specialty.foodCategory
        self.phone = specialty.phone
        self.placeId = specialty.placeId
        self.latitude = specialty.latitude
        self.longitude = specialty.longitude
        self.rating = specialty.rating
        self.ratingCount = specialty.ratingCount
        self.priceLevel = specialty.priceLevel
        self.photoURLs = []
        self.photoAttributions = []
        self.isHero = false
    }
}

