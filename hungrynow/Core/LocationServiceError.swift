import Foundation

enum LocationServiceError: Error {
    case permissionDenied
    case permissionRestricted
    case locationUnavailable
    /// Reverse geocoding returned nothing usable. Distinct from `locationUnavailable`
    /// because the fix itself succeeded — only the name lookup failed, which is
    /// cosmetic (the app bar's chip) and must never block a recommendation.
    case geocodingFailed
    case unknown
}
