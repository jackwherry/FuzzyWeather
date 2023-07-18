//
//  ContentView.swift
//  FuzzyWeather
//
//  Created by Jack Wherry on 7/11/23.
//

import SwiftUI

struct ContentView: View {
    @Binding var store: LocationModelStore
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack{
            List {
                ForEach(store.locations.indices, id: \.self) { index in
                    let location = store.locations[index]
                    NavigationLink(location.cityName) {
                        LocationDetailView(location: $store.locations[index])
                    }
                }.onMove{ indexSet, offset in
                    
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
                        .popover(isPresented: $showingAddSheet) {
                            AddLocationSheetContent(showingAddSheet: $showingAddSheet)
                        }
                }
            }
        }
    }
}

struct AddLocationSheetContent: View {
    @Binding var showingAddSheet: Bool
    @State private var textFieldText = ""
    @FocusState private var keyboardFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button() {
                    showingAddSheet = false
                } label: { Image(systemName: "xmark.circle") }
                    .padding()
            }
            Spacer()
            
            TextField("Search for a location...", text: $textFieldText)
                .focused($keyboardFocused)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        keyboardFocused = true
                    }
                }
                .padding()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: .constant(LocationModelStore()))
    }
}
