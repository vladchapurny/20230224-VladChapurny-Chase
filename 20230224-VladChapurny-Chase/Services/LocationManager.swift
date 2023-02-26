//
//  LocationManager.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    var coordinates = PassthroughSubject<CLLocationCoordinate2D, Error>()
    
    override init() {
        super.init()
        
        manager.delegate = self
    }
    
    func attemptRequestPrompt() {
        manager.requestAlwaysAuthorization()
    }
    
    func getLocation() {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        coordinates.send(location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Add logic if it fails to get coordinates (should we keep previous location or update it to say something else (design decision)
        
        /// Simple way to tell publisher that there was an error and end it
        //coordinates.send(completion: .failure(error))
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        manager.requestLocation()
    }
}
