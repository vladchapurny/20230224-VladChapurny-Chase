//
//  MainWeatherViewModel.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import Combine
import SwiftUI
import CoreLocation

/*
 * MVVM - View Model - doing all the heavy lifting for us
 */
class MainWeatherViewModel: ObservableObject {
    
    // MARK: Variables
    
    /// Weather Information Publisher
    @Published var weatherInformation: WeatherData? = nil
    /// Weather Image Publisher
    @Published var weatherImage: UIImage? = nil
    
    /// Open weather map service
    private let openWeatherMapService: OpenWeatherMapService
    /// locatio service
    private let locationService: LocationService
    // DEMO PURPOSE: VERY! simple cache (not optimal)
    private let simpleImageCache = NSCache<NSString, UIImage>()
    /// storing publishers
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Init
    /// init that allows depenedncy injection (when we seperate and create mock services)
    init(service: OpenWeatherMapService = OpenWeatherMapService(), locationService: LocationService = LocationService()) {
    
        self.openWeatherMapService = service
        self.locationService = locationService
        self.simpleImageCache.countLimit = 20 /// since there are only 18 images the cache should hold all of them
    
        /// subscribing to coordinates inside WeatherData
        /// optimization would be to only subscribe and unsubscribe when we can even fetch the coordinates
        locationService.coordinates
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error) // this will never happen right now because WeatherData does not have a completion error
                }
            } receiveValue: { [weak self] coordinates in
                self?.fetchWeatherInformation(lon: coordinates.longitude, lat: coordinates.latitude)
            }
            .store(in: &cancellables)
        
        /// Load location depending on what the default is
        performLocationFetch()
    }
    
    // MARK: public functions
    /// refresh weather location (used for scroll down to refresh)
    func refreshWeatherData(completion: () -> ()) {
        /// Load location depending on what the default is
        performLocationFetch()
        
        // Demo purpose ONLY completion to stop refresh icon
        completion()
    }
    
    /// Get weather information based on city
    func fetchWeatherInformation(city: String) {
        
        /// Store city name in user defaults
        UserDefaults.standard.setValue(city, forKey: Constants.UDLocationKey)
        
        /// call api and request location
        openWeatherMapService.currentWeather(city: city)
            .replaceError(with: WeatherData())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in // Since I am replacing error we will never have a completion case where it fails technically
                self?.weatherInformation = $0
                self?.fetchWeatherImage() /// fetch weather image when weather was fetched
            }
            .store(in: &cancellables)
    }
    
    // MARK: private functions
    private func fetchWeatherInformation(lon: Double, lat: Double) {
        openWeatherMapService.currentWeather(lat: lat, lon: lon)
            .replaceError(with: WeatherData())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in // Since I am replacing error we will never have a completion case where it fails technically
                self?.weatherInformation = $0
                self?.fetchWeatherImage()
            }
            .store(in: &cancellables)
    }
    
    /// Check if we can fetch geolocation or if we should fetch location by city
    private func performLocationFetch() {
        /// CoreLocation authorization status
        let auth: CLAuthorizationStatus
        /// CoreLocation manager
        let service = CLLocationManager()
        
        /// Avoid Warnings
        if #available(iOS 14, *) {
            auth = service.authorizationStatus
        } else {
            auth = CLLocationManager.authorizationStatus()
        }
        
        switch auth {
        /// If we are authorized to use location then fetch the location
        case .authorizedAlways, .authorizedWhenInUse:
            locationService.getLocation()
            UserDefaults.standard.setValue("", forKey: Constants.UDLocationKey)
        /// if we have not asked, then ask, then fetch location
        case .notDetermined:
            locationService.attemptRequestPrompt()
            UserDefaults.standard.setValue("", forKey: Constants.UDLocationKey)
        /// otherwise fetch whatever location was saved (if no saved location then display empty states)
        default:
            if let savedLocation = UserDefaults.standard.string(forKey: Constants.UDLocationKey), !savedLocation.isEmpty {
                fetchWeatherInformation(city: savedLocation)
            }
        }
    }
    
    // VERY SIMPLE FETCH CALL - could be separated into its own call
    private func fetchWeatherImage() {
        /// Check that weather icon exists
        guard let iconCode = self.weatherInformation?.weather?[0].icon else { return }
        
        /// basic url builder for the icon check
        guard let url = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png") else { return }
        
        /// check if image exists in our simple cache
        if let imageInCache = simpleImageCache.object(forKey: iconCode as NSString) {
            self.weatherImage = imageInCache
            return
        }
        
        /// Fetch image if not found in cache
        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: url) else { return }
            let uiImage = UIImage(data: data)
            
            /// Add image to cache
            if let uiImage = uiImage {
                self?.simpleImageCache.setObject(uiImage, forKey: iconCode as NSString)
            }
            
            self?.weatherImage = UIImage(data: data)
        }
    }
}
