import CoreLocation
import RxSwift

final class LocationService: NSObject, LocationServiceProtocol {
    private let manager = CLLocationManager()
    private var pendingObserver: ((SingleEvent<CLLocationCoordinate2D>) -> Void)?
    private var pendingAuthObserver: ((SingleEvent<CLAuthorizationStatus>) -> Void)?

    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestAuthorization() -> Single<CLAuthorizationStatus> {
        Single<CLAuthorizationStatus>.create { [weak self] observer in
            guard let self else {
                observer(.failure(LocationServiceError.unknown))
                return Disposables.create()
            }

            let status = self.manager.authorizationStatus

            // Anything other than .notDetermined means the alert has already been
            // answered on some earlier launch. iOS will not show it a second time, so
            // waiting on a delegate callback here would hang forever.
            guard status == .notDetermined else {
                observer(.success(status))
                return Disposables.create()
            }

            self.pendingAuthObserver = observer
            self.manager.requestWhenInUseAuthorization()

            return Disposables.create { [weak self] in
                self?.pendingAuthObserver = nil
            }
        }
    }

    func requestLocation() -> Single<CLLocationCoordinate2D> {
        Single<CLLocationCoordinate2D>.create { [weak self] observer in
            guard let self else {
                observer(.failure(LocationServiceError.unknown))
                return Disposables.create()
            }

            self.pendingObserver = observer

            switch self.manager.authorizationStatus {
            case .notDetermined:
                self.manager.requestWhenInUseAuthorization()
            case .denied:
                self.resolve(.failure(LocationServiceError.permissionDenied))
            case .restricted:
                self.resolve(.failure(LocationServiceError.permissionRestricted))
            case .authorizedWhenInUse, .authorizedAlways:
                self.manager.requestLocation()
            @unknown default:
                self.resolve(.failure(LocationServiceError.unknown))
            }

            return Disposables.create { [weak self] in
                self?.pendingObserver = nil
            }
        }
    }

    func reverseGeocode(_ coordinate: CLLocationCoordinate2D) -> Single<String> {
        Single<String>.create { observer in
            // A fresh geocoder per request: CLGeocoder handles one job at a time and
            // starting a second on the same instance cancels the first.
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error {
                    // A cancelled geocode is the disposal path below, not a failure
                    // worth reporting.
                    let code = (error as NSError).code
                    if code == CLError.geocodeCanceled.rawValue { return }
                    observer(.failure(error))
                    return
                }

                guard let placemark = placemarks?.first,
                      let name = Self.displayName(for: placemark) else {
                    observer(.failure(LocationServiceError.geocodingFailed))
                    return
                }

                observer(.success(name))
            }

            return Disposables.create { geocoder.cancelGeocode() }
        }
    }

    /// "Seminyak, Bali" — the settlement, then the region.
    ///
    /// The fallback chain matters because Places-style results vary a lot by country:
    /// `locality` is empty in plenty of places where `subLocality` or
    /// `subAdministrativeArea` is the only meaningful name ("Kuta Selatan, Badung
    /// Regency" is a normal result here). The two halves are de-duplicated because in
    /// city-states and single-region countries they come back identical, and
    /// "Singapore, Singapore" reads like a bug.
    private static func displayName(for placemark: CLPlacemark) -> String? {
        let settlement = placemark.locality
            ?? placemark.subLocality
            ?? placemark.subAdministrativeArea
            ?? placemark.name
        let region = placemark.administrativeArea

        switch (settlement, region) {
        case let (settlement?, region?) where settlement != region:
            return "\(settlement), \(region)"
        case let (settlement?, _):
            return settlement
        case let (nil, region?):
            return region
        default:
            return nil
        }
    }

    private func resolve(_ event: SingleEvent<CLLocationCoordinate2D>) {
        pendingObserver?(event)
        pendingObserver = nil
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        // A bare authorization request finishes here whatever the answer, and must be
        // settled BEFORE the location branch below — otherwise a `requestAuthorization()`
        // that happens to be granted would fall through and trigger a fix nobody asked
        // for. `.notDetermined` is skipped because this callback also fires once when
        // the delegate is first set, before any prompt has been shown.
        if status != .notDetermined, let observer = pendingAuthObserver {
            pendingAuthObserver = nil
            observer(.success(status))
        }

        // Everything below belongs to `requestLocation()` only.
        guard pendingObserver != nil else { return }

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied:
            resolve(.failure(LocationServiceError.permissionDenied))
        case .restricted:
            resolve(.failure(LocationServiceError.permissionRestricted))
        case .notDetermined:
            break
        @unknown default:
            resolve(.failure(LocationServiceError.unknown))
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        resolve(.success(location.coordinate))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resolve(.failure(LocationServiceError.locationUnavailable))
    }
}
