//
//  ContentView.swift
//  FuzzyWeather
//
//  Created by Jack Wherry on 7/11/23.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @Binding var store: LocationModelStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var showingAddSheet = false
    
    let saveAction: ()->Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.locations.indices, id: \.self) { index in
                    let location = store.locations[index]
                    NavigationLink(location.cityName) {
                        LocationDetailView(location: $store.locations[index])
                    }
                }.onMove{ indexSet, offset in
                    store.move(fromOffsets: indexSet, toOffset: offset)
                }
                .onDelete { indexSet in
                    store.delete(atOffsets: indexSet)
                }
            }
            .navigationTitle("Locations")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button() {
                        showingAddSheet = true
                    } label: { Image(systemName: "plus") }
                        .sheet(isPresented: $showingAddSheet) {
                            AddLocationSheetContent(showingAddSheet: $showingAddSheet, store: $store)
                        }
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive { saveAction() }
        }
    }
}

struct AddLocationSheetContent: View {
    @Binding var showingAddSheet: Bool
    @Binding var store: LocationModelStore
    @State private var textFieldText = ""
    @State private var loadingGeocode = false
    @State private var geocodeError: NSError?
    @State private var displayGeocodeError = false
    @FocusState private var keyboardFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    TextField("Search for a city...", text: $textFieldText)
                        .focused($keyboardFocused)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                keyboardFocused = true
                            }
                        }
                        .padding()
                }
                if loadingGeocode {
                    ProgressView()
                }
                VStack {
                    
                }.alert(isPresented: $displayGeocodeError) {
                    if geocodeError?.code == 8 {
                        return Alert(title: Text("Location lookup failed"), message: Text("Check your spelling and try again."), dismissButton: .default(Text("OK")))
                    } else if geocodeError?.code == 2 {
                        return Alert(title: Text("Location lookup failed"), message: Text("Check your internet connection and try again."), dismissButton: .default(Text("OK")))
                    }
                    return Alert(title: Text("Location lookup failed"), message: Text("Something went wrong."), dismissButton: .default(Text("OK")))
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button() {
                        getCoordinate(addressString: textFieldText, completionHandler: { (coordinate, name, error) in
                            if error == nil {
                                store.append(latitude: coordinate.latitude, longitude: coordinate.longitude, cityName: name)
                                loadingGeocode = false
                                showingAddSheet = false
                            } else {
                                loadingGeocode = false
                                displayGeocodeError = true
                                geocodeError = error
                            }
                        })
                        loadingGeocode = true
                    } label: { Text("Add").fontWeight(.bold) }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button() {
                        showingAddSheet = false
                    } label: { Text("Cancel") }
                }
            }
            
            .navigationTitle("Add a location")
        }
    }
}

func getCoordinate( addressString : String,
                    completionHandler: @escaping(CLLocationCoordinate2D, String, NSError?) -> Void ) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(addressString) { (placemarks, error) in
        if error == nil {
            if let placemark = placemarks?[0] {
                let location = placemark.location!
                let name = placemark.name!
                
                completionHandler(location.coordinate, name, nil)
                return
            }
        }
        
        completionHandler(kCLLocationCoordinate2DInvalid, "", error as NSError?)
    }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(store: .constant(LocationModelStore()))
//    }
//}
