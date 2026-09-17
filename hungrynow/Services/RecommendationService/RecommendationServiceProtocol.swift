import Foundation
import RxSwift

protocol RecommendationServiceProtocol {
    func getRecommendation(latitude: Double, longitude: Double) -> Single<RecommendationResponse>
    func getPhoto(photoRef: String, attribution: String?) -> Single<PhotoResponse>
}
