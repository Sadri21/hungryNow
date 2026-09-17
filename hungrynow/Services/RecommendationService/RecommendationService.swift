import Foundation
import Moya
import RxSwift
import RxMoya

final class RecommendationService: RecommendationServiceProtocol {
    private let provider: MoyaProvider<RecommendationAPI>

    init(provider: MoyaProvider<RecommendationAPI> = MoyaProvider<RecommendationAPI>()) {
        self.provider = provider
    }

    func getRecommendation(latitude: Double, longitude: Double) -> Single<RecommendationResponse> {
        request(.getRecommendation(latitude: latitude, longitude: longitude))
    }

    func getPhoto(photoRef: String, attribution: String?) -> Single<PhotoResponse> {
        request(.getPhoto(photoRef: photoRef, attribution: attribution))
    }

    private func request<T: Decodable>(_ target: RecommendationAPI) -> Single<T> {
        provider.rx.request(target)
            .flatMap { response -> Single<T> in
                guard (200..<300).contains(response.statusCode) else {
                    let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: response.data)
                    return .error(RecommendationServiceError.from(errorCode: apiError?.error))
                }
                do {
                    return .just(try JSONDecoder().decode(T.self, from: response.data))
                } catch {
                    return .error(RecommendationServiceError.decodingFailed)
                }
            }
            .catch { error in
                if error is RecommendationServiceError {
                    return .error(error)
                }
                return .error(RecommendationServiceError.network)
            }
    }
}
