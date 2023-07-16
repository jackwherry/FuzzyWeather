//
//  ContentView.swift
//  FuzzyWeather
//
//  Created by Jack Wherry on 7/11/23.
//

import SwiftUI

struct ContentView: View {
    @Binding var store: LocationModelStore
    
    var body: some View {
        NavigationStack{
            List {
                ForEach(store.locations.indices, id: \.self) { index in
                    let location = store.locations[index]
                    NavigationLink(location.cityName) {
                        LocationDetailView(location: $store.locations[index])
                    }
                }
            }.navigationTitle("Locations")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: .constant(LocationModelStore()))
    }
}
