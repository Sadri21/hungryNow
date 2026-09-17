//
//  DirectionsLink.swift
//  hungrynow
//
//  Building the Directions deep link. A pure function, so it is testable without a
//  simulator and without UIKit.
//

import CoreLocation
import Foundation

/// The URL screen 06's Directions button opens.
enum DirectionsLink {

    /// Apple Maps, driving directions to a coordinate.
    ///
    /// **Coordinates are required, and there is deliberately no text fallback.** Building
    /// the link from `name` + `address` makes Maps re-geocode a text query, and for a
    /// chain — the vault's own test hero, "Restoran Nasi Kandar Ar Rashid", is one — that
    /// lands people at the wrong branch. A button that confidently sends someone to the
    /// wrong restaurant is worse than a button that is visibly unavailable, so nil here
    /// disables the control rather than degrading it.
    ///
    /// `placeId` is carried for the same reason it is in the model: Google Maps'
    /// `query_place_id` is the unambiguous link. It is unused until the choice of nav app
    /// is made — see below.
    ///
    /// **Apple Maps only, for now.** Offering Google Maps or Waze needs `comgooglemaps`
    /// and `waze` in `LSApplicationQueriesSchemes`, or `canOpenURL` fails silently and
    /// reports every app as missing — an open checklist item, and a separate piece of work
    /// from this screen. Apple Maps needs no scheme query and is always present.
    static func appleMaps(latitude: Double?, longitude: Double?, name: String) -> URL? {
        guard let latitude, let longitude else { return nil }
        guard CLLocationCoordinate2DIsValid(
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        ) else { return nil }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.apple.com"
        components.path = "/"
        components.queryItems = [
            // `daddr` as a coordinate, never as text. `q` is the pin's label only.
            URLQueryItem(name: "daddr", value: "\(latitude),\(longitude)"),
            URLQueryItem(name: "q", value: name),
            URLQueryItem(name: "dirflg", value: "d"),
        ]
        return components.url
    }

    /// Google Maps place listing / details URL.
    /// Uses `query_place_id` when available for an exact listing match, falling back to name and address.
    static func googleMapsPlace(placeId: String?, name: String, address: String? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.google.com"
        components.path = "/maps/search/"
        let queryValue: String
        if let address = address, !address.isEmpty {
            queryValue = "\(name), \(address)"
        } else {
            queryValue = name
        }
        var queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "query", value: queryValue),
        ]
        if let placeId = placeId, !placeId.isEmpty {
            queryItems.append(URLQueryItem(name: "query_place_id", value: placeId))
        }
        components.queryItems = queryItems
        return components.url
    }
}
