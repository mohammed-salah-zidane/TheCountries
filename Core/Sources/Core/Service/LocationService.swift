import Foundation
import CoreLocation

public final class LocationService: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    private var geocoder: CLGeocoder?
    /// We capture a single completion closure for each call to `getCurrentCountry`.
    private var completion: ((Result<Country, Error>) -> Void)?
    
    public override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        // Configure location manager
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.distanceFilter = 500
    }
    
    private func cleanup() {
        locationManager.stopUpdatingLocation()
        geocoder?.cancelGeocode()
        geocoder = nil
        completion = nil
    }
    
    private func completeOnce(_ result: Result<Country, Error>) {
        guard let completion = completion else { return }
        completion(result)
        self.completion = nil
    }
    
    @MainActor
    public func getCurrentCountry() async throws -> Country {
        // Clean up any previous state
        cleanup()
        
        // Request permission if not determined
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.completion = { [weak self] result in
                // Ensure cleanup after completion
                self?.cleanup()
                continuation.resume(with: result)
            }
            
            // Start location updates if authorized
            if locationManager.authorizationStatus == .authorizedWhenInUse ||
                locationManager.authorizationStatus == .authorizedAlways {
                locationManager.startUpdatingLocation()
            } else {
                cleanup()
                continuation.resume(throwing: LocationError.permissionDenied)
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            completion?(.failure(LocationError.geocodingFailed))
            return
        }
        
        // Stop location updates
        locationManager.stopUpdatingLocation()
        
        // Create new geocoder
        let geocoder = CLGeocoder()
        self.geocoder = geocoder
        
        // Reverse geocode the location
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                self.completion?(.failure(error))
                return
            }
            
            guard let placemark = placemarks?.first,
                  let countryCode = placemark.isoCountryCode,
                  let countryName = placemark.country else {
                self.completion?(.failure(LocationError.geocodingFailed))
                return
            }
            
            // Create Country object
            let country = Country(
                id: countryCode,
                name: CountryName(
                    common: countryName,
                    official: countryName
                ),
                capital: placemark.locality,
                currency: nil, // Not available from CLGeocoder
                languages: [],
                flagUrl: nil,
                coordinates: Coordinates(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                ),
                population: 0,
                area: nil,
                region: placemark.administrativeArea ?? "Unknown"
            )
            
            self.completion?(.success(country))
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(.failure(error))
        cleanup()
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if completion != nil {
                locationManager.startUpdatingLocation()
            }
        case .denied, .restricted:
            completion?(.failure(LocationError.permissionDenied))
            cleanup()
        case .notDetermined:
            // We do nothing here; once the user chooses,
            // the status will change again to one of the above states.
            break
        @unknown default:
            break
        }
    }
}

// MARK: - Error Types

public enum LocationError: LocalizedError {
    case permissionDenied
    case geocodingFailed
    
    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied"
        case .geocodingFailed:
            return "Failed to determine country from location"
        }
    }
}
