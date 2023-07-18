//
//  LocationDetailView.swift
//  FuzzyWeather
//
//  Created by Jack Wherry on 7/12/23.
//

import SwiftUI

struct LocationDetailView: View {
    @Binding var location: LocationModel
    
    @State private var selectedTimeOfDay = 0.0
    @State private var isEditing = false
    
    @State private var emojiState = EmojiState(count: 13, emojis: "😤🤔😬")

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Slider(
                    value: $selectedTimeOfDay,
                    in: 0...24,
                    step: 1,
                    onEditingChanged: { editing in
                        emojiState.updateEmojis(emojis: location[hourID: Int(selectedTimeOfDay)].emojis)
                        isEditing = editing
                        if !isEditing {
                            withAnimation(.easeInOut(duration: 2)) {
                                emojiState.reposition()
                            }
                        }
                    }
                ).padding()
                Text(getScrollText(selectedTimeOfDay: selectedTimeOfDay)) //.foregroundColor(isEditing ? .red : .blue)
                    .font(.title2)
                Text(getFormattedDateTime(offsetSeconds: 3600 * Int(selectedTimeOfDay)))
                ZStack {
                    ForEach(emojiState.entries.indices, id: \.self) { index in
                        let entry = emojiState.entries[index]
                        entry.emoji
                            .scaleEffect(2)
                            .position(
                                x: proxy.size.width * entry.x,
                                y: proxy.size.height * entry.y)
                    }
                }
            }
            // .font(.system(size: 24))
            .contentShape(Rectangle())
            .navigationTitle(location.cityName)
            .accessibilityAction(named: "Reposition") {
                emojiState.reposition()
            }
            //.drawingGroup()
        }
    }
}

//struct LocationDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            LocationDetailView(location: .constant(LocationModel(latitude: 40.7128, longitude: 74.0060, cityName: "New York", id: 0, startingDate: Date())))
//        }
//    }
//}

struct EmojiState {
    var entries: [Entry] = []
    
    var emojis = ""

    init(count: Int = 100, emojis: String) {
        for _ in 0..<count {
            entries.append(Entry(emojis: emojis))
        }
        self.emojis = emojis
    }

    mutating func reposition() {
        for index in entries.indices {
            entries[index].reposition(emojis: emojis)
        }
    }
    
    mutating func updateEmojis(emojis: String) {
        self.emojis = emojis
    }

    struct Entry {
        var emojiSeed: Int
        var x: Double
        var y: Double
        
        var emojis: String

        init(emojis: String) {
            emojiSeed = Int.random(in: 0..<emojis.count)
            x = Double.random(in: 0..<1)
            y = Double.random(in: 0..<1)
            
            self.emojis = emojis
        }

        mutating func reposition(emojis: String) {
            emojiSeed = Int.random(in: 0..<emojis.count)
            x = Double.random(in: 0..<1)
            y = Double.random(in: 0..<1)
            
            self.emojis = emojis
        }

        var emoji: Text {
            Text(String(emojis[emojis.index(emojis.startIndex, offsetBy: emojiSeed)]))
        }
    }
}

private func getScrollText(selectedTimeOfDay: Double) -> String {
    let intSTOD = Int(selectedTimeOfDay)
    
    if intSTOD == 0 {
        return "Now"
    }
    
    var hourSingularOrPlural = "hours"
    if intSTOD == 1 {
        hourSingularOrPlural = "hour"
    }
    
    return "\(intSTOD) \(hourSingularOrPlural) from now"
}

private func getFormattedDateTime(offsetSeconds: Int) -> String {
    let formatter = DateFormatter()
    
    formatter.dateFormat = "h a" // just the hour and am/pm, like "7 PM"
    
    return formatter.string(from: Date().advanced(by: TimeInterval(offsetSeconds)))
}
