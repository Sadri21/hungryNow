//
//  hungrynowApp.swift
//  hungrynow
//
//  Created by Asa Teknologi on 02/09/26.
//

import SwiftUI
import GooglePlacesSwift

@main
struct hungrynowApp: App {

    init() {
        let key = Bundle.main.object(forInfoDictionaryKey: "PLACES_API_KEY") as? String
        if let key = key, !key.isEmpty, !key.hasPrefix("$") {
            PlacesClient.provideAPIKey(key)
            print("✅ [hungrynowApp] Google Places SDK initialized successfully with key: \(key.prefix(8))... (length: \(key.count))")
        } else {
            print("⚠️ [hungrynowApp] PLACES_API_KEY could not be read from Info.plist. Value: \(String(describing: key))")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
