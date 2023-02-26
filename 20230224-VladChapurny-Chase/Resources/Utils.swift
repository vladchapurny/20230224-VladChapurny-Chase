//
//  Utils.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//
import Foundation

/*
 * Utilities class
 */
class Utils {
    
    /// Converts generic type to String
    ///
    /// - warning: nil parameter returns custom empty string
    /// - parameter value: generic type to convert (can be nil)
    /// - returns: string representation of generic value
    static func Stringify<T>(_ value: T?) -> String {
        guard let value = value else { return Constants.emptyString }
        return String(describing: value)
    }

    /// Rounds temperature value
    ///
    /// - parameter value: temperature (can be nil)
    /// - returns: optional int of rounded value
    static func RoundTemp(_ value: Double?) -> Int? {
        guard let value = value else { return nil }
        return Int(round(value))
    }

    /// Builds URL for geolocation
    ///
    /// - parameter lat: latitude
    /// - parameter lon: longitude
    /// - returns: built url
    static func buildGeoURL(lat: Double, lon: Double) -> URL? {
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

    /// Builds URL for city
    ///
    /// - parameter city: city name
    /// - returns: built url
    static func buildCityURL(city: String) -> URL? {
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
}
