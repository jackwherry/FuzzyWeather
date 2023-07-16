//
//  FuzzyWeatherApp.swift
//  FuzzyWeather
//
//  Created by Jack Wherry on 7/11/23.
//

import SwiftUI

@main
struct FuzzyWeatherApp: App {
    @State private var store = LocationModelStore.defaultStore
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: $store)
        }
    }
}
