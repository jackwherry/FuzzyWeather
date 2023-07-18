//
//  LocationModelStore.swift
//  FuzzyWeather
//
//  Created by Jack Wherry on 7/12/23.
//

import SwiftUI

struct LocationModelStore {
    var locations: [LocationModel] = []
    
    static let defaultStore: Self = {
        var data = Self()
        data.append(latitude: 40.7128, longitude: 74.0060, cityName: "New York")
        return data
    }()
    
    @discardableResult
    mutating func append(latitude: Double, longitude: Double, cityName: String = "") -> LocationModel {
        var id = 0
        for location in locations {
            id = max(id, location.id)
        }
        let location = LocationModel(latitude: latitude, longitude: longitude, cityName: cityName, id: id + 1, startingDate: Date())
        locations.append(location)
        return location
    }
    
    mutating func delete(atOffsets: IndexSet) {
        locations.remove(atOffsets: atOffsets)
    }
    
    mutating func move(fromOffsets: IndexSet, toOffset: Int) {
        locations.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
}
