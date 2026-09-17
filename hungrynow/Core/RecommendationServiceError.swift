import Foundation

enum RecommendationServiceError: Error, Equatable {
    case missingLocation
    case noResults
    case dailyLimitReached
    case placesLookupFailed
    case recommendationFailed
    case missingPhotoRef
    case photoLimitReached
    case photoFetchFailed
    case decodingFailed
    case unknown(String?)
    case network

    static func from(errorCode: String?) -> RecommendationServiceError {
        switch errorCode {
        case "missing_location": return .missingLocation
        case "no_results": return .noResults
        case "daily_limit_reached": return .dailyLimitReached
        case "places_lookup_failed": return .placesLookupFailed
        case "recommendation_failed": return .recommendationFailed
        case "missing_photo_ref": return .missingPhotoRef
        case "photo_limit_reached": return .photoLimitReached
        case "photo_fetch_failed": return .photoFetchFailed
        default: return .unknown(errorCode)
        }
    }
}
