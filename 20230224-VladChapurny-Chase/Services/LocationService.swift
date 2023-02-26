//
//  LocationManager.swift
//  20230224-VladChapurny-Chase
//
//  Created by Vlad Chapurny on 2023-02-25.
//

import Foundation
import CoreLocation
import Combine

/*
 * Location Service to help manage fetching users geolocation
 */
class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    /// Core Location Manager
    let manager = CLLocationManager()
    /// Coordinates publisher
    var coordinates = PassthroughSubject<CLLocationCoordinate2D, Error>() 
    
    override init() {
        super.init()
        
        /// Setting delegate for manager
        manager.delegate = self
    }
    
    /// Show pop-up to the user to allow or decline location service
    func attemptRequestPrompt() {
        manager.requestAlwaysAuthorization()
    }
    
    /// Get the actual location
    func getLocation() {
        manager.requestLocation()
    }
    
    /// when update happens we want to publish the change so the subscribers can update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        coordinates.send(location.coordinate)
    }
    
    /// when error occurs we want to usually handle this cleanly
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: Add logic if it fails to get coordinates (should we keep previous location or update it to say something else (design decision)
        
        /// Simple way to tell publisher that there was an error and end it
        //coordinates.send(completion: .failure(error))
    }
    
    /// when authorization changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // TODO: Clean up - we do not want to request location everytime authorization is changed (only when its granted)
        manager.requestLocation()
    }
}
