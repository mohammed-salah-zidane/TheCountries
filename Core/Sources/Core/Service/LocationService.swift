// LocationService implementation for country detection based on location
import Foundation
import CoreLocation

public final class LocationService: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    private var completion: ((Result<Country, Error>) -> Void)?
    
    public override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }
    
    public func getCurrentCountry() async throws -> Country {
        // Request permission if not determined
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.completion = { result in
                continuation.resume(with: result)
            }
            
            // Start location updates if authorized
            if locationManager.authorizationStatus == .authorizedWhenInUse ||
                locationManager.authorizationStatus == .authorizedAlways {
                locationManager.startUpdatingLocation()
            } else {
                completion?(.failure(LocationError.permissionDenied))
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // Stop updating location once we get a reading
        locationManager.stopUpdatingLocation()
        
        // Reverse geocode the location
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                self?.completion?(.failure(error))
                return
            }
            
            guard let placemark = placemarks?.first,
                  let countryCode = placemark.isoCountryCode,
                  let countryName = placemark.country else {
                self?.completion?(.failure(LocationError.geocodingFailed))
                return
            }
            
            // Create Country object with proper structure
            let country = Country(
                id: countryCode,
                name: CountryName(
                    common: countryName,
                    official: countryName
                ),
                capital: placemark.locality,
                currency: nil, // Currency not available from geocoding
                languages: [], // Languages not available from geocoding
                flagUrl: nil, // Flag URL not available from geocoding
                coordinates: Coordinates(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                ),
                population: 0, // Population not available from geocoding
                area: nil, // Area not available from geocoding
                region: placemark.administrativeArea ?? "Unknown"
            )
            
            self?.completion?(.success(country))
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(.failure(error))
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            completion?(.failure(LocationError.permissionDenied))
        case .notDetermined:
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
