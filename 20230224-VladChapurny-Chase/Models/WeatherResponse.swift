//
//  WeatherResponse.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import Foundation

struct WeatherResponse: Codable {
    var weather: [Weather]?
    var main: Main?
    var visibility: Int?
    var name: String?
    
    init() { }
    
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
    
    
    // MARK: INNER STRUCTS FOR DECODING (could be separated out)
    struct Weather: Codable {
        var description: String?
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
        var temp: Double?
        var feelsLike: Double?
        var pressure: Int?
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


