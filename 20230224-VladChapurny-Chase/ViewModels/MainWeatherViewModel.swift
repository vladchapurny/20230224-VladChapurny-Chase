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
    
    @Published var weatherInformation: WeatherResponse? = nil
    @Published var weatherImage: UIImage? = nil
    
    private let service: OpenWeatherAPI
    private let locationService: LocationManager
    private let simpleImageCache = NSCache<NSString, UIImage>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(service: OpenWeatherAPI = OpenWeatherAPI(), locationService: LocationManager = LocationManager()) {
        
        self.service = service
        self.locationService = locationService
    
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
        performLocationFetch()
    }
    
    func refreshWeatherData(completion: () -> ()) {
        performLocationFetch()
        simpleImageCache.countLimit = 20 // they only have 18 icons
        // Demo purpose ONLY completion to stop refresh icon
        completion()
    }
    
    func fetchWeatherInformation(city: String) {
        
        UserDefaults.standard.setValue(city, forKey: "defaultLocation")
        
        service.currentWeather(city: city)
            .replaceError(with: WeatherResponse())
            .receive(on: DispatchQueue.main)
            .sink { // Since I am replacing error we will never have a completion case where it fails technically
                self.weatherInformation = $0
                self.fetchWeatherImage()
            }
            .store(in: &cancellables)
    }
    
    private func performLocationFetch() {
        let auth: CLAuthorizationStatus
        let service = CLLocationManager()
        
        if #available(iOS 14, *) {
            auth = service.authorizationStatus
        } else {
            auth = CLLocationManager.authorizationStatus()
        }
        
        switch auth {
        case .authorizedAlways, .authorizedWhenInUse:
            locationService.getLocation()
            UserDefaults.standard.setValue("", forKey: "defaultLocation")
        case .notDetermined:
            locationService.attemptRequestPrompt()
            UserDefaults.standard.setValue("", forKey: "defaultLocation")
        default:
            if let savedLocation = UserDefaults.standard.string(forKey: "defaultLocation"), !savedLocation.isEmpty {

                fetchWeatherInformation(city: savedLocation)
            }
        }
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
