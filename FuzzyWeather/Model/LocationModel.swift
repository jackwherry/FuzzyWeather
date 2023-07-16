//
//  LocationModel.swift
//  FuzzyWeather
//
//  Created by Jack Wherry on 7/12/23.
//

import SwiftUI

/// Represents the comfort level associated with the current dewpoint
// TODO: check access control (is public the right level?)
public enum dewpointComfortLevel {
    case tooDry // < 32 deg F
    case comfortableDry // 32-49 deg F
    case comfortable // 50-59 deg F
    case slightlyHumid // 60-64 deg F
    case moderatelyHumid // 65-69 deg F
    case veryHumid // 70-74 deg F
    case extremelyHumid // > 75 deg F
    
    case dewpointOutsideReasonableBounds // error cases
}

/// Represents the quantized/perceptual wind level (using Beaufort numbers)
public enum windComfortLevel {
    case calm // 0 mph
    case lightAir // 1-3 mph
    case lightBreeze // 4-7 mph
    case gentleBreeze // 8-12 mph
    case moderateBreeze // 13-18 mph
    case freshBreeze // 19-24 mph
    case strongBreeze // 25-31 mph
    case nearGale // 32-38 mph
    case gale // 39-46 mph
    case strongGale // 47-54 mph
    case wholeGale // 55-63 mph
    case stormForce // 64-75 mph
    case hurricaneForce // > 75 mph
    
    case windOutsideReasonableBounds // error cases
}

/// Represents the comfort level associated with the current temperature
/// Based on "new" NWS wind chill index for cold temperatures and heat index for high temperatures
public enum temperatureComfortLevel {
    // winter weather scenarios:
    //  temperature must be less than 50 deg F
    case extremeDangerousCold // wind chill < -60
    case veryDangerousCold // wind chill -60 to -35
    case moderatelyDangerousCold // and wind chill -35 to -19
    case slightlyDangerousCold // wind chill -19 to 0
    case safeUnderFreezing // wind chill 0 to 36, temperature < 32
    case snowMelting // wind chill 0 to 36, temperature > 32
    
    // normal weather scenarios
    //  temperature between 50 and 72 deg F
    case cool // temperature between 50 and 60 deg F
    case lukeWarm // temperature between 60 and 65 deg F
    case roomTemp // temperature between 65 and 72 deg F
    
    // summer temperature scenarios
    //  temperature greater than 72 deg F
    case safeWarm // heat index < 80
    case cautionHot // heat index 80-90
    case extremeCautionHot // heat index 90-102
    case dangerHot // heat index 102-124
    case extremeDangerHot // heat index > 124
    
    // error cases
    case temperatureOutsideReasonableBounds
}

/// Calculates the wind chill given wind speed and temperature
/// (formula from: https://www.weather.gov/ffc/wci)
func getWindChill(wind: Measurement<UnitSpeed>, temperature: Measurement<UnitTemperature>) -> Int {
    let degFTemp = temperature.converted(to: .fahrenheit).value
    let mphWind = wind.converted(to: .milesPerHour).value
    
    let wc = 35.74 + 0.6215*degFTemp - 35.75*pow(mphWind, 0.16) + 0.4275*degFTemp*pow(mphWind, 0.16)
    
    return Int(wc)
}

/// Calculates the heat index given temperature and humidity
/// (formula from: https://www.wpc.ncep.noaa.gov/html/heatindex_equation.shtml)
func getHeatIndex(relativeHumidity: Double, temperature: Measurement<UnitTemperature>) -> Int {
    let degFTemp = temperature.converted(to: .fahrenheit).value
    
    // broken up into sub-expressions to fix "the compiler is unable to type-check this expression in reasonable time"
    var hi = -42.379 + 2.04901523*degFTemp + 10.14333127*relativeHumidity - 0.22475541*degFTemp*relativeHumidity
    hi -= 0.00683783*degFTemp*degFTemp - 0.05481717*relativeHumidity*relativeHumidity
    hi += 0.00122874*degFTemp*degFTemp*relativeHumidity + 0.00085282*degFTemp*relativeHumidity*relativeHumidity
    hi -= 0.00000199*degFTemp*degFTemp*relativeHumidity*relativeHumidity
    
    if relativeHumidity < 0.13 && (degFTemp >= 80 && degFTemp <= 112) {
        hi -= ((13-relativeHumidity)/4) * sqrt((17-abs(degFTemp-95))/17)
    }
    
    if relativeHumidity > 0.85 && (degFTemp >= 80 && degFTemp <= 87) {
        hi += ((relativeHumidity-85)/10) * ((87-degFTemp)/5)
    }
    
    if hi < 80 {
        hi = 0.5 * (degFTemp + 61.0 + ((degFTemp-68.0) * 1.2) + (relativeHumidity * 0.094))
    }
    
    // TODO: determine if this needs to be averaged with the actual temperature or if it's good as is
    
    return Int(hi)
}

func getdewpointComfortLevel(dewpoint: Measurement<UnitTemperature>) -> dewpointComfortLevel {
    let degFDewpoint = dewpoint.converted(to: .fahrenheit).value
    switch degFDewpoint {
    case 0..<32:
        return dewpointComfortLevel.tooDry
    case 32..<50:
        return dewpointComfortLevel.comfortableDry
    case 50..<60:
        return dewpointComfortLevel.comfortable
    case 60..<65:
        return dewpointComfortLevel.slightlyHumid
    case 65..<70:
        return dewpointComfortLevel.moderatelyHumid
    case 70..<75:
        return dewpointComfortLevel.veryHumid
    case 75...:
        return dewpointComfortLevel.extremelyHumid
    default:
        return dewpointComfortLevel.dewpointOutsideReasonableBounds
    }
}

func getWindComfortLevel(wind: Measurement<UnitSpeed>) -> windComfortLevel {
    let mphWind = wind.converted(to: .milesPerHour).value
    switch mphWind {
    case 0:
        return windComfortLevel.calm
    case 1..<4:
        return windComfortLevel.lightAir
    case 4..<8:
        return windComfortLevel.lightBreeze
    case 8..<13:
        return windComfortLevel.gentleBreeze
    case 13..<19:
        return windComfortLevel.moderateBreeze
    case 19..<25:
        return windComfortLevel.freshBreeze
    case 25..<32:
        return windComfortLevel.strongBreeze
    case 32..<39:
        return windComfortLevel.nearGale
    case 39..<47:
        return windComfortLevel.gale
    case 47..<55:
        return windComfortLevel.strongGale
    case 55..<64:
        return windComfortLevel.wholeGale
    case 64..<75:
        return windComfortLevel.stormForce
    case 75...:
        return windComfortLevel.hurricaneForce
    default:
        return windComfortLevel.windOutsideReasonableBounds
    }
}

func getTemperatureComfortLevel(temperature: Measurement<UnitTemperature>, windChill: Int?, heatIndex: Int?) -> temperatureComfortLevel {
    let degFTemp = temperature.converted(to: .fahrenheit).value
    if let windChill = windChill {
        // Winter weather scenarios
        if degFTemp < 50 {
            switch windChill {
            case ..<(-60):
                return .extremeDangerousCold
            case -60...(-35):
                return .veryDangerousCold
            case -35...(-19):
                return .moderatelyDangerousCold
            case -19..<0:
                return .slightlyDangerousCold
            case 0...36:
                if degFTemp < 32 {
                    return .safeUnderFreezing
                } else {
                    return .snowMelting
                }
            default:
                break
            }
        }
    } else if let heatIndex = heatIndex {
        // Summer temperature scenarios
        if degFTemp > 72 {
            switch heatIndex {
            case ..<80:
                return .safeWarm
            case 80...90:
                return .cautionHot
            case 90...102:
                return .extremeCautionHot
            case 102...124:
                return .dangerHot
            case 124...:
                return .extremeDangerHot
            default:
                break
            }
        }
    }
    
    // Normal weather scenarios
    if degFTemp >= 50 && degFTemp <= 60 {
        return .cool
    } else if degFTemp > 60 && degFTemp <= 65 {
        return .lukeWarm
    } else if degFTemp > 65 && degFTemp <= 72 {
        return .roomTemp
    }
    
    // Error case
    return .temperatureOutsideReasonableBounds
}

struct LocationModel: Equatable, Identifiable {
    /// Represents the forecasted weather conditions for a given hour
    /// (conceptually equivalent to WeatherKit's HourWeather structure: https://developer.apple.com/documentation/weatherkit/hourweather)
    struct HourForecast: Equatable, Identifiable {
        /// Hour of day (represented by a Date for the start time of this hour)
        var hour: Date
        
        /// Hour's location in [0,1] range (position within 24 hour forecast period)
        var timelineLocation: Double
        
        /// String of emojis used in animation
        var emojis: String
        
        /// Background color (used to generate a moving gradient)
        var color: Color
        
        var id: Int
    }
    
    /// GPS coordinates representing the location
    var latitude, longitude: Double
    
    // TODO: also represent using NWS gridpoints so we don't need to look them up on each API call?
    
    /// The city name closest to this location
    var cityName: String
    
    subscript(hourID hourID: HourForecast.ID) -> HourForecast {
        get { hourForecasts.first(where: { $0.id == hourID }) ?? HourForecast(
            hour: Date(), timelineLocation: 0, emojis: "❌", color: Color(white: 0), id: 0
        ) }
        set {
            if let index = hourForecasts.firstIndex(where: { $0.id == hourID }) {
                hourForecasts[index] = newValue
            }
        }
    }
    
    @discardableResult
    mutating func append(hour: Date, timelineLocation: Double) -> HourForecast {
        var id = 0
        for hour in hourForecasts {
            id = max(id, hour.id)
        }
        let hour = HourForecast(hour: hour, timelineLocation: timelineLocation, emojis: "❌", color: Color(white: 0), id: id + 1)
        hourForecasts.append(hour)
        return hour
    }
    
    /// Array of (possibly unsorted) hourly forecasts
    var hourForecasts: [HourForecast]
    
    // TODO: add a place name closest to this location?
    //  (like the "weather for ..." at the bottom of the Apple Weather app)
    
    /// Unique identifier
    var id: Int
}

extension LocationModel {
    init(latitude: Double, longitude: Double, cityName: String = "", id: Int = 0, startingDate: Date) {
        self.latitude = latitude
        self.longitude = longitude
        self.cityName = cityName
        self.id = id
        
        hourForecasts = []
        var dates: [Date] = []
        for _ in 1...24 {
            dates.append(startingDate.advanced(by: TimeInterval(3600)))
        }
        for (index, date) in dates.enumerated() {
            hourForecasts.append(HourForecast(hour: date, timelineLocation: Double(index)/Double(hourForecasts.count-1), emojis: "❌", color: Color(white: 0), id: index))
        }
    }
}
