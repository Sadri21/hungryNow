import CoreLocation
import RxSwift

protocol LocationServiceProtocol {
    /// The current authorization status, read synchronously from the underlying manager.
    var authorizationStatus: CLAuthorizationStatus { get }

    /// Asks iOS for When In Use and completes when the prompt is answered, with
    /// whatever the answer was — `.denied` is a normal outcome here, not an error.
    ///
    /// Separate from `requestLocation()` on purpose. Screen 02 needs the permission
    /// and nothing else, while `requestLocation()` also takes a GPS fix; asking for a
    /// fix during onboarding spends battery and time on coordinates that will be stale
    /// by the time anyone taps "I'm Hungry".
    ///
    /// Completes immediately if the prompt was already answered on a previous launch —
    /// iOS shows the system alert exactly once and silently ignores later requests.
    func requestAuthorization() -> Single<CLAuthorizationStatus>

    /// Authorization (prompting if still undetermined) followed by a single fix.
    func requestLocation() -> Single<CLLocationCoordinate2D>

    /// A human place name for the app bar's location chip, e.g. "Seminyak, Bali".
    ///
    /// Returns a formatted string rather than a `CLPlacemark` so that CoreLocation's
    /// model stays behind this protocol — the naming rule is part of the service, not
    /// something each caller re-derives from placemark fields.
    ///
    /// `CLGeocoder` is a rate-limited network service. Call it once per resolved
    /// location, never per view update.
    func reverseGeocode(_ coordinate: CLLocationCoordinate2D) -> Single<String>
}
