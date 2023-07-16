//
//  LocationDetailView.swift
//  FuzzyWeather
//
//  Created by Jack Wherry on 7/12/23.
//

import SwiftUI

struct LocationDetailView: View {
    @Binding var location: LocationModel
    
    // TODO: check whether this should be another type instead of Int
    @State private var selectedTimeOfDay = 0.0
    @State private var isEditing = false
    
    var body: some View {
        VStack {
            Slider(
                value: $selectedTimeOfDay,
                in: 0...24,
                onEditingChanged: { editing in
                    isEditing = editing
                }
            )
            Text("\(selectedTimeOfDay)").foregroundColor(isEditing ? .red : .blue)
        }.navigationTitle(location.cityName)
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationDetailView(location: .constant(LocationModel(latitude: 40.7128, longitude: 74.0060, cityName: "New York", id: 0, startingDate: Date())))
        }
    }
}
