//
//  MainWeatherViewModel.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import Combine
import SwiftUI
import CoreLocation

class MainWeatherViewModel: ObservableObject {
    
    private let simpleImageCache = NSCache<NSString, UIImage>()
    
    @Published var weatherInformation: WeatherResponse? = nil
    @Published var weatherImage: UIImage? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let service: OpenWeatherAPI
    private let locationService: LocationManager
    
    init() {
        self.service = OpenWeatherAPI()
        self.locationService = LocationManager()
        locationService.requestLocation()
        locationService.coordinates
            .receive(on: DispatchQueue.main)
            .sink {
                completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            } receiveValue: { coordinates in
                self.fetchWeatherInformation(lon: coordinates.longitude, lat: coordinates.latitude)
            }
            .store(in: &cancellables)
        
        //fetchWeatherInformation(city: "")
    }
    
    func fetchWeatherInformation(city: String) {
        service.currentWeather(city: city)
            .replaceError(with: WeatherResponse())
            .receive(on: DispatchQueue.main)
            .sink { // Since I am replacing error we will never have a completion case where it fails technically
                self.weatherInformation = $0
                self.fetchWeatherImage()
            }
            .store(in: &cancellables)
    }
    
    private func fetchWeatherInformation(lon: Double, lat: Double) {
        service.currentWeather(lat: lat, lon: lon)
            .replaceError(with: WeatherResponse())
            .receive(on: DispatchQueue.main)
            .sink { // Since I am replacing error we will never have a completion case where it fails technically
                self.weatherInformation = $0
                self.fetchWeatherImage()
            }
            .store(in: &cancellables)
    }
    
    // VERY SIMPLE FETCH CALL - could be separated into its own call
    private func fetchWeatherImage() {
        guard let iconCode = self.weatherInformation?.weather?[0].icon else { return }
        guard let url = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png") else { return }
        
        // Check cache
        if let imageInCache = simpleImageCache.object(forKey: iconCode as NSString) {
            self.weatherImage = imageInCache
            return
        }
        
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { return }
            let uiImage = UIImage(data: data)
            
            if let uiImage = uiImage {
                self.simpleImageCache.setObject(uiImage, forKey: iconCode as NSString)
            }
            
            self.weatherImage = UIImage(data: data)
        }
    }
}
