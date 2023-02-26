//
//  WeatherResponse.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import Foundation

/*
 * Model for our Weather Data
 */
struct WeatherData: Codable {
    /// weather information
    var weather: [Weather]?
    /// main information
    var main: Main?
    /// visibility (only comes in Metric)
    var visibility: Int?
    /// Name of city in US
    var name: String?
    
    /// empty Init
    init() { }
    
    // DEMO: design decision for demo purpose to introduce codingkeys and init for decoder
    enum CodingKeys: String, CodingKey {
        case weather = "weather"
        case main = "main"
        case visibility = "visibility"
        case name = "name"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        weather = try values.decodeIfPresent([Weather].self, forKey: .weather)
        main = try values.decodeIfPresent(Main.self, forKey: .main)
        visibility = try values.decodeIfPresent(Int.self, forKey: .visibility)
        name = try values.decodeIfPresent(String.self, forKey: .name)
    }
    
    struct Weather: Codable {
        /// weather description
        var description: String?
        /// weather icon
        var icon: String?
        
        enum CodingKeys: String, CodingKey {
            case description = "description"
            case icon = "icon"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            description = try values.decodeIfPresent(String.self, forKey: .description)
            icon = try values.decodeIfPresent(String.self, forKey: .icon)
        }
    }

    struct Main: Codable {
        /// current temperature in °F
        var temp: Double?
        /// feels like in °F
        var feelsLike: Double?
        /// pressure
        var pressure: Int?
        /// humidity percentage
        var humidity: Int?
        
        enum CodingKeys: String, CodingKey {
            case temp = "temp"
            case feelsLike = "feels_like"
            case pressure = "pressure"
            case humidity = "humidity"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            temp = try values.decodeIfPresent(Double.self, forKey: .temp)
            feelsLike = try values.decodeIfPresent(Double.self, forKey: .feelsLike)
            pressure = try values.decodeIfPresent(Int.self, forKey: .pressure)
            humidity = try values.decodeIfPresent(Int.self, forKey: .humidity)
        }
    }
}
