//
//  Utils.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import Foundation

func Stringify<T>(_ value: T?) -> String {
    guard let value = value else { return "---" }
    return String(describing: value)
}

func RoundTemp(_ value: Double?) -> Int? {
    guard let value = value else { return nil }
    return Int(round(value))
}

func buildGeoURL(lat: Double, lon: Double) -> URL? {
    guard let keys = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Keys", ofType: "plist") ?? "") else {
        return nil
    }
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.openweathermap.org"
    components.path = "/data/2.5/weather"
    components.queryItems = [
        URLQueryItem(name: "lat", value: String(lat)),
        URLQueryItem(name: "lon", value: String(lon)),
        URLQueryItem(name: "appid", value: keys["openWeatherMapKey"] as? String),
        URLQueryItem(name: "units", value: "imperial"),
    ]

    return components.url
}

func buildCityURL(city: String) -> URL? {
    guard let keys = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Keys", ofType: "plist") ?? "") else {
        return nil
    }
    
    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.openweathermap.org"
    components.path = "/data/2.5/weather"
    components.queryItems = [
        URLQueryItem(name: "q", value: city+",US"),
        URLQueryItem(name: "appid", value: keys["openWeatherMapKey"] as? String),
        URLQueryItem(name: "units", value: "imperial"),
    ]

    return components.url
}

struct Constants {
    static let emptyString = "---"
}
