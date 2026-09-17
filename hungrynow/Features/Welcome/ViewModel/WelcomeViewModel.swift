//
//  WelcomeViewModel.swift
//  hungrynow
//
//  State for screen 02. Talks to `LocationServiceProtocol` and nothing else —
//  no CoreLocation types are constructed here and no concrete service is named
//  except as the default argument that composition would otherwise supply.
//

import Combine
import CoreLocation
import Foundation
import RxSwift

/// Screen 02's only job is the permission ask.
///
/// It deliberately does NOT take a location fix and does NOT call the Cloud Function.
/// `requestLocation()` would do the first as a side effect, and coordinates taken
/// during onboarding are stale by the time anyone taps "I'm Hungry" — which is where
/// the fix and the metered backend call belong.
final class WelcomeViewModel: ObservableObject {

    /// True only while the system alert is on screen. Drives the button's disabled
    /// state so a second tap can't stack another request behind the first.
    @Published private(set) var isRequestingPermission = false

    private let locationService: LocationServiceProtocol
    private let disposeBag = DisposeBag()

    init(locationService: LocationServiceProtocol = LocationService()) {
        self.locationService = locationService
    }

    /// Asks iOS for When In Use, then hands control on with the resulting authorization status.
    ///
    /// `completion` runs on whatever the user answered, including "Don't Allow" — a
    /// refusal is an answer, not a failure, allowing the caller (RootView) to route to
    /// Screen 07 (LocationOffView) immediately.
    func requestLocationPermission(completion: @escaping (CLAuthorizationStatus) -> Void) {
        guard !isRequestingPermission else { return }
        isRequestingPermission = true

        locationService.requestAuthorization()
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] status in
                    self?.isRequestingPermission = false
                    completion(status)
                },
                onFailure: { [weak self] _ in
                    self?.isRequestingPermission = false
                    completion(.denied)
                }
            )
            .disposed(by: disposeBag)
    }
}
