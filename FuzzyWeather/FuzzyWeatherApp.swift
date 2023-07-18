//
//  FuzzyWeatherApp.swift
//  FuzzyWeather
//
//  Created by Jack Wherry on 7/11/23.
//

import SwiftUI

@main
struct FuzzyWeatherApp: App {
    @StateObject private var store = LocationModelStoreStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: $store.locationModelStore) {
                Task {
                    do {
                        try await store.save(locations: store.locationModelStore)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
                .task {
                    do {
                        try await store.load()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
        }
    }
}
