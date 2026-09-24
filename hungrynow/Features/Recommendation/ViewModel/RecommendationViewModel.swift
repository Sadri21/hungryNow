import Combine
import CoreLocation
import Foundation
import RxSwift
import UIKit

final class RecommendationViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case loaded(RecommendationResponse)
        case locationDenied
        case noResults
        case networkError(NetworkErrorVariant)
    }

    @Published private(set) var state: State = .idle

    /// The hero's photos, index-aligned with `photoRefs`, filled in as they arrive.
    ///
    /// A dictionary rather than an array because the fetches are lazy and land out of
    /// order: slide 1 comes with the result, slides 2-3 only if someone swipes. An array
    /// would need placeholder holes to keep the indices meaningful.
    @Published private(set) var heroPhotos: [Int: HeroPhoto] = [:]

    /// The place name in the app bar's chip, e.g. "Seminyak, Bali". Nil until
    /// resolved, and the chip is simply absent while it is — a partial bar is normal.
    @Published private(set) var locationName: String?

    /// Which of screen 05's stages is current.
    ///
    /// Advanced on real events only — see `SearchStage`. There is no timer anywhere in
    /// this file, and there must not be one: a stage that advances on a clock is faked
    /// progress, which is exactly what the screen was designed to avoid.
    @Published private(set) var searchStage: SearchStage = .locating

    private var isResolvingLocationName = false

    /// Where the search was run from. Kept so the hero's distance can be computed — the
    /// response has no distance field and never will; it is a function of two coordinates,
    /// one of which only the client has.
    private var searchCoordinate: CLLocationCoordinate2D?

    /// Photo refs already requested, so swiping back and forth doesn't re-bill
    /// `get_photo` for a slide already on screen.
    private var requestedPhotoIndexes: Set<Int> = []

    /// The in-flight search, held separately from `disposeBag` so Cancel can dispose
    /// just this one. A `DisposeBag` is all-or-nothing and also owns the chip's geocode,
    /// which Cancel has no business tearing down.
    private var searchDisposable: Disposable?

    private let locationService: LocationServiceProtocol
    private let recommendationService: RecommendationServiceProtocol
    private let networkMonitor: NetworkMonitorProtocol
    private let disposeBag = DisposeBag()

    init(locationService: LocationServiceProtocol = LocationService(),
         recommendationService: RecommendationServiceProtocol = RecommendationService(),
         networkMonitor: NetworkMonitorProtocol = NetworkMonitor.shared) {
        self.locationService = locationService
        self.recommendationService = recommendationService
        self.networkMonitor = networkMonitor
    }

    /// Resolves the location name for the app bar, once.
    ///
    /// Called when Home appears, which can only happen after the permission prompt has
    /// been answered — so this never races the system alert, and it never triggers one
    /// of its own.
    ///
    /// Failure is silent by design. A refused permission or a rate-limited geocode
    /// leaves the chip absent; neither is worth an error state, because the chip is
    /// context and the app works without it.
    ///
    /// Guarded twice because Home reappears every time the flow returns to `.idle`, and
    /// `CLGeocoder` is rate-limited — this must not fire on each return.
    func resolveLocationName() {
        guard locationName == nil, !isResolvingLocationName else { return }
        isResolvingLocationName = true

        locationService.requestLocation()
            .flatMap { [locationService] coordinate in
                locationService.reverseGeocode(coordinate)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] name in
                    self?.isResolvingLocationName = false
                    self?.locationName = name
                },
                onFailure: { [weak self] _ in
                    self?.isResolvingLocationName = false
                }
            )
            .disposed(by: disposeBag)
    }

    func findFood() {
        // A second tap while a search is running would otherwise leave two chains
        // racing to set `state`.
        searchDisposable?.dispose()

        searchStage = .locating
        state = .loading
        heroPhotos = [:]
        requestedPhotoIndexes = []
        searchCoordinate = nil

        searchDisposable = locationService.requestLocation()
            .observe(on: MainScheduler.instance)
            // The one honest stage boundary the client can see: the fix has arrived, so
            // the Cloud Function call is what we are waiting on from here.
            .do(onSuccess: { [weak self] coordinate in
                self?.searchStage = .reading
                self?.searchCoordinate = coordinate
            })
            .flatMap { [recommendationService] coordinate in
                recommendationService.getRecommendation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] response in
                    self?.state = .loaded(response)
                    // Slide 1 only. See `loadHeroPhoto(at:)`.
                    self?.loadHeroPhoto(at: 0, of: response.hero)
                },
                onFailure: { [weak self] error in
                    self?.handleError(error)
                }
            )
    }


    // MARK: - Screen 06

    /// The hero's fact row: distance, rating, price per person, matching Screen 06.
    func heroFacts(for hero: HeroPick) -> [Fact] {
        // Every fact here is omitted when its data is missing, never defaulted.
        //
        // The card used to fill gaps with plausible-looking constants — "100 m", and a
        // rating of "4.9" from "1.5K reviews". Attached to a named real restaurant that
        // is an invented review count, and nothing on screen marks it as a placeholder.
        // A shorter card is honest; a complete one that is partly fiction is not.

        // 1. Distance (away)
        let distanceText: String? = distance(to: hero).map { FactFormatter.distance(metres: $0) }

        // 2. Rating (rating)
        let ratingValue: String?
        let ratingLabel: String
        if let rating = hero.rating {
            ratingValue = FactFormatter.ratingValue(rating)
            if let count = hero.ratingCount, count > 0 {
                ratingLabel = "\(FactFormatter.compactCount(count)) reviews"
            } else {
                ratingLabel = "rating"
            }
        } else if let parsed = Self.extractRating(from: hero.description) ?? Self.extractRating(from: hero.reason) {
            ratingValue = parsed
            ratingLabel = "rating"
        } else {
            ratingValue = nil
            ratingLabel = "rating"
        }

        // 3. Price (per person)
        //
        // Google's reported range first, the 1...4 tier as a fallback, and nothing
        // at all when neither exists. The previous version scraped a price out of
        // the model's prose and, failing that, printed a hardcoded "Rp50k–150k" —
        // so a restaurant with no price data showed the same confident figure as
        // one with a known tier, in rupiah regardless of country.
        let priceText = FactFormatter.price(range: hero.priceRange, level: hero.priceLevel)

        var facts: [Fact] = []
        if let distanceText {
            facts.append(Fact(label: "away", value: distanceText))
        }
        if let ratingValue {
            facts.append(
                Fact(
                    label: ratingLabel,
                    value: ratingValue,
                    showsStar: true,
                    spokenValue: FactFormatter.spokenRating(ratingValue)
                )
            )
        }
        if let priceText {
            facts.append(Fact(label: "per person", value: priceText))
        }
        return facts
    }

    private static func extractRating(from text: String) -> String? {
        let pattern = #"(\d\.\d)\s*(?:rating|\/5)|rating\s*(?:of\s*)?(\d\.\d)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else {
            return nil
        }
        for rangeIdx in 1..<match.numberOfRanges {
            let r = match.range(at: rangeIdx)
            if r.location != NSNotFound, let range = Range(r, in: text) {
                return String(text[range])
            }
        }
        return nil
    }

    /// Straight-line metres from where the search ran to the pick.
    ///
    /// Straight-line, not driving distance: a route needs a Directions API call, which is
    /// a separate billed product, and the fact row's job is "how far is this, roughly" —
    /// which is also why `FactFormatter` rounds to 10m rather than pretending to metre
    /// precision neither coordinate has.
    private func distance(to hero: HeroPick) -> Double? {
        guard let from = searchCoordinate,
              let latitude = hero.latitude,
              let longitude = hero.longitude else { return nil }

        return CLLocation(latitude: from.latitude, longitude: from.longitude)
            .distance(from: CLLocation(latitude: latitude, longitude: longitude))
    }

    /// How many slides the hero's carousel has.
    ///
    /// Falls back to the single legacy `photoRef` while `photoRefs` is absent, so screen
    /// 06 shows one photo today and three the day the array lands.
    func heroPhotoCount(for hero: HeroPick) -> Int {
        heroPhotoRefs(for: hero).count
    }

    /// Fetches one slide's photo, at most once.
    ///
    /// **Called on swipe, not up front.** `get_photo` is metered against
    /// `DAILY_PHOTO_LIMIT` (33): eagerly loading three photos per result would cut the
    /// day from 33 results to 11, and most people never swipe past the first.
    func loadHeroPhoto(at index: Int, of hero: HeroPick) {
        let refs = heroPhotoRefs(for: hero)
        guard refs.indices.contains(index),
              !requestedPhotoIndexes.contains(index) else { return }

        requestedPhotoIndexes.insert(index)

        // Known before the request goes out — it arrived with the recommendation.
        let knownAttribution = hero.attribution(at: index)


        recommendationService.getPhoto(photoRef: refs[index], attribution: knownAttribution)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] response in
                    guard let url = URL(string: response.photoUri) else { return }
                    let photoRef = refs[index]

                    // ONE download, published ONCE, already decoded.
                    //
                    // The previous version published a URL-only `HeroPhoto` here and then
                    // started this same download for luminance. That made the slide render
                    // `AsyncImage(url:)`, which fetched the identical URL a second time —
                    // two network trips for one ~40-90KB WebP, racing each other, and a
                    // visible re-render when the manual copy landed and swapped
                    // `AsyncImage` out for `Image(uiImage:)`.
                    //
                    // Publishing only when `image` is non-nil means the view never takes
                    // the `AsyncImage` branch at all: it shows the `foodCategory` fallback
                    // until the bytes are in hand, then the real photo, once.
                    URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                        guard let data = data, let img = UIImage(data: data) else {
                            // Nothing was published, so the slide is still showing the
                            // fallback. Clear the index so swiping back can retry.
                            DispatchQueue.main.async {
                                self?.requestedPhotoIndexes.remove(index)
                            }
                            return
                        }
                        let style = PhotoLuminanceDetector.shared.detectStyle(for: img, identifier: photoRef)

                        DispatchQueue.main.async {
                            self?.heroPhotos[index] = HeroPhoto(
                                url: url,
                                // Hero's own credit wins; the response is the fallback
                                // for entries the backend cached before it carried
                                // attributions.
                                attribution: knownAttribution ?? response.attribution,
                                image: img,
                                detectedStatusBarStyle: style
                            )
                        }
                    }.resume()
                },
                onFailure: { [weak self] _ in
                    // A failed photo is not a failed result. The slide keeps the
                    // `foodCategory` fallback and the pick is still perfectly usable, so
                    // this must never touch `state`. Cleared from the requested set so a
                    // later swipe back can retry.
                    self?.requestedPhotoIndexes.remove(index)
                }
            )
            .disposed(by: disposeBag)
    }

    private func heroPhotoRefs(for hero: HeroPick) -> [String] {
        if let refs = hero.photoRefs, !refs.isEmpty { return refs }
        if let ref = hero.photoRef { return [ref] }
        return []
    }

    /// Screen 05's Cancel. Drops the search and goes back to Home.
    ///
    /// Back to `.idle` rather than to an error: the user asked to stop, so nothing went
    /// wrong and there is nothing to report. `locationName` is left alone so the app bar
    /// chip survives the trip back — re-resolving it would burn a second geocode for a
    /// name already on screen.
    func cancelSearch() {
        searchDisposable?.dispose()
        searchDisposable = nil
        searchStage = .locating
        state = .idle
    }

    /// Screen 06's Home button, or Screen 09's Back to Home. Returns from result/error view back to Home.
    func resetToHome() {
        searchDisposable?.dispose()
        searchDisposable = nil
        searchStage = .locating
        heroPhotos = [:]
        requestedPhotoIndexes = []
        state = .idle
        resolveLocationName()
    }

    /// Re-evaluates location authorization, e.g. after returning from Settings.
    func checkLocationPermission() {
        let status = locationService.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            state = .idle
            resolveLocationName()
        }
    }

    private func handleError(_ error: Error) {
        if let locError = error as? LocationServiceError {
            switch locError {
            case .permissionDenied, .permissionRestricted:
                state = .locationDenied
                return
            default:
                break
            }
        }

        if let recError = error as? RecommendationServiceError {
            switch recError {
            case .missingLocation:
                state = .locationDenied
                return
            case .noResults:
                state = .noResults
                return
            case .dailyLimitReached:
                // Its own variant, not `.serviceUnavailable`: the quota resets tomorrow,
                // so "Try again" would be a button that cannot succeed.
                state = .networkError(.dailyLimitReached)
                return
            case .network, .placesLookupFailed, .recommendationFailed, .decodingFailed, .unknown:
                let variant: NetworkErrorVariant = networkMonitor.isConnected ? .serviceUnavailable : .offline
                state = .networkError(variant)
                return
            case .missingPhotoRef, .photoLimitReached, .photoFetchFailed:
                return
            }
        }

        let variant: NetworkErrorVariant = networkMonitor.isConnected ? .serviceUnavailable : .offline
        state = .networkError(variant)
    }

    deinit {
        searchDisposable?.dispose()
    }
}

