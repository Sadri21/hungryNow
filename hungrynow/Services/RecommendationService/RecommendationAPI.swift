import Alamofire
import Foundation
import Moya

enum RecommendationAPI {
    case getRecommendation(latitude: Double, longitude: Double)
    case getPhoto(photoRef: String, attribution: String?)
}

extension RecommendationAPI: nonisolated TargetType {
    var baseURL: URL {
        URL(string: "https://us-central1-revaiter-hungrynow.cloudfunctions.net")!
    }

    var path: String {
        switch self {
        case .getRecommendation:
            return "/get_recommendation"
        case .getPhoto:
            return "/get_photo"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getRecommendation, .getPhoto:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .getRecommendation(latitude, longitude):
            return .requestParameters(
                parameters: ["latitude": latitude, "longitude": longitude],
                encoding: JSONEncoding.default
            )
        case let .getPhoto(photoRef, attribution):
            // The credit rides along with the request. The backend will not look it up
            // from Places — that would be a billed Place Details call per photo tap — so
            // if the client does not send what it was already given, the photo comes
            // back uncredited.
            var parameters: [String: Any] = ["photoRef": photoRef]
            if let attribution {
                parameters["attribution"] = attribution
            }
            return .requestParameters(
                parameters: parameters,
                encoding: JSONEncoding.default
            )
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }

    var sampleData: Data {
        Data()
    }
}
