//
//  OpenWeatherAPI.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import Foundation
import Combine

protocol OpenWeatherQueries {
    func currentWeather(city: String) -> AnyPublisher<WeatherResponse, Error>
    func currentWeather(lat: Double, lon: Double) -> AnyPublisher<WeatherResponse, Error>
}

class OpenWeatherAPI: OpenWeatherQueries {
    func currentWeather(city: String) -> AnyPublisher<WeatherResponse, Error> {
        
        guard let url = Utils.buildCityURL(city: city) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func currentWeather(lat: Double, lon: Double) -> AnyPublisher<WeatherResponse, Error> {
        
        guard let url = Utils.buildGeoURL(lat: lat, lon: lon) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
