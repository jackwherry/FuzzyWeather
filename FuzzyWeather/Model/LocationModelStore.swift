//
//  LocationModelStore.swift
//  FuzzyWeather
//
//  Created by Jack Wherry on 7/12/23.
//

import SwiftUI

struct LocationModelStore: Codable {
    var locations: [LocationModel] = []
    
    static let defaultStore: Self = {
        var data = Self()
        data.append(latitude: 40.7128, longitude: 74.0060, cityName: "New York")
        return data
    }()
    
    @discardableResult
    mutating func append(latitude: Double, longitude: Double, cityName: String = "") -> LocationModel {
        let location = LocationModel(latitude: latitude, longitude: longitude, cityName: cityName, startingDate: Date())
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

@MainActor
class LocationModelStoreStore: ObservableObject {
    @Published var locationModelStore: LocationModelStore = LocationModelStore.defaultStore
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("scrums.data")
    }
    
    func load() async throws {
        let task = Task<LocationModelStore, Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return LocationModelStore()
            }
            let locations = try JSONDecoder().decode(LocationModelStore.self, from: data)
            return locations
        }
        let locationModelStore = try await task.value
        self.locationModelStore = locationModelStore
    }
    
    func save(locations: LocationModelStore) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(locations)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
            
        }
        _ = try await task.value
        
    }
}
