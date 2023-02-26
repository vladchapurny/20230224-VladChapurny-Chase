//
//  OpenWeatherAPI.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import Foundation
import Combine

// Setting up basic protocol for the two main queries
protocol OpenWeatherQueries {
    func currentWeather(city: String) -> AnyPublisher<WeatherData, Error>
    func currentWeather(lat: Double, lon: Double) -> AnyPublisher<WeatherData, Error>
}

/*
 * Open Weather Map API communication service using Combine framework
 */
class OpenWeatherMapService: OpenWeatherQueries {
    
    /// Function to fetch current weather for given city location
    func currentWeather(city: String) -> AnyPublisher<WeatherData, Error> {
        print("Started fetch for \(city)")
        
        /// Check if the city url is correct
        guard let url = Utils.buildCityURL(city: city) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        /// Simple (could be optimized) data task to fetch data for given url
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                
                /// Simple error check
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: WeatherData.self, decoder: JSONDecoder()) // TODO: Make a generic (optimized) decoder in utils
            .eraseToAnyPublisher()
    }
    
    /// Function to get weather by using location coordinates
    func currentWeather(lat: Double, lon: Double) -> AnyPublisher<WeatherData, Error> {
        print("Started fetch for \(lat), \(lon)")
        
        /// Check if the location coordinate url is correct
        guard let url = Utils.buildGeoURL(lat: lat, lon: lon) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        /// Simple (could be optimized) data task to fetch data for given url
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                
                /// Simple error check
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: WeatherData.self, decoder: JSONDecoder()) // TODO: Make a generic (optimized) decoder in utils
            .eraseToAnyPublisher()
    }
}
